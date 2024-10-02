import asyncio
import json
import os
import tempfile
import zipfile
from urllib.parse import urlparse, urlencode, urlunsplit

import aiohttp
from expiring_dict import ExpiringDict

from domain.exceptions.request_failed import GitHubRequestFailed
from domain.sanitizers.sanitize_logs import anonymize_message, sanitize_message
from domain.sanitizers.url_sanitizer import quote_safe
from domain.transformers.minify_strings import minify_strings
from domain.url.build_url import build_url
from domain.validation.argument_validation import (
    ensure_string_not_empty,
    ensure_not_falsy,
)
from infrastructure.http_pool import http
from infrastructure.octopus import logging_wrapper

# Token user lookup cache that expires in 15 minutes.
# This is really only for tests as Azure functions are going to launch a new instance for each request,
# and the cache will be empty.
token_lookup_cache = ExpiringDict(60 * 15)

# Semaphore to limit the number of concurrent requests to GitHub
sem = asyncio.Semaphore(10)

# 5 keywords is a hard limit for GitHub searches
max_keywords_with_boolean = 5


@logging_wrapper
def exchange_github_code(code):
    # Exchange the code
    resp = http.request(
        "POST",
        build_url(
            "https://github.com",
            "/login/oauth/access_token",
            dict(
                client_id=os.environ.get("GITHUB_CLIENT_ID"),
                client_secret=os.environ.get("GITHUB_CLIENT_SECRET"),
                code=code,
            ),
        ),
        headers={"Accept": "application/json"},
    )

    if resp.status != 200:
        raise GitHubRequestFailed(f"Request failed with " + resp.data.decode("utf-8"))

    response_json = resp.json()

    # You can get 200 ok response with a bad request:
    # https://github.com/orgs/community/discussions/57068
    if "access_token" not in response_json:
        raise GitHubRequestFailed(f"Request failed with " + json.dumps(response_json))

    return response_json["access_token"]


@logging_wrapper
def get_github_auth_headers(get_token):
    """
    Build the headers used to make a GitHub API request
    :param get_token: The github token
    :return: The headers required to call the Octopus API
    """

    headers = {
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
    }

    if get_token:
        headers["Authorization"] = "Bearer {}".format(get_token)

    return headers


@logging_wrapper
def get_github_diff_headers(get_token):
    """
    Build the headers used to make a GitHub request for a commit diff
    :param get_token: The github token
    :return: The headers required to call the Octopus API
    """

    headers = {
        "Accept": "application/vnd.github.diff",
    }

    if get_token:
        headers["Authorization"] = "Bearer {}".format(get_token)

    return headers


@logging_wrapper
def build_github_api_url(path, query=None):
    """
    Create a URL from the GitHub API URL, additional path, and query params
    :param path: The additional path
    :param query: Additional query params
    :return: The URL combining all the inputs
    """

    parsed = urlparse("https://api.github.com")
    query = urlencode(query) if query is not None else ""
    return urlunsplit((parsed.scheme, parsed.netloc, path, query, ""))


@logging_wrapper
def build_github_url(path, query=None):
    """
    Create a URL from the GitHub URL, additional path, and query params
    :param path: The additional path
    :param query: Additional query params
    :return: The URL combining all the inputs
    """

    parsed = urlparse("https://github.com")
    query = urlencode(query) if query is not None else ""
    return urlunsplit((parsed.scheme, parsed.netloc, path, query, ""))


@logging_wrapper
def get_github_user(get_token):
    """
    Gets the GitHub username from the supplied token
    :param get_token: The function used to get theGithub token
    :return: The GitHub username
    """

    if get_token is None:
        return None

    # Copilot appears to send a new token every request, but this does cut down the number of API requests
    # used when running tests against a long-lived token.
    if get_token in token_lookup_cache:
        return str(token_lookup_cache[get_token]["id"])

    api = build_github_api_url("user", "")

    resp = http.request("GET", api, headers=get_github_auth_headers(get_token))

    if resp.status != 200:
        raise GitHubRequestFailed(f"Request failed with " + resp.data.decode("utf-8"))

    json = resp.json()

    # Cache the user lookup result
    token_lookup_cache[get_token] = json

    return str(json["id"])


@logging_wrapper
def search_repo(repo, language, keywords, get_token=None):
    # The docs at https://docs.github.com/en/rest/search/search?apiVersion=2022-11-28#search-code note that:
    # "This endpoint can be used without authentication if only public resources are requested."
    # However, this does not appear to be true, with issues like https://github.com/pbek/QOwnNotes/issues/2772#issuecomment-1513352222
    # noting:
    # "GitHub now demands an access token for the code search API and has a harsh quota on the amounts of searches per person"
    # I think the GitHub docs are incorrect, as I have not been able to perform a search without a token.
    query = f"{' '.join(keywords)} in:file language:{language} repo:{repo}"
    api = build_github_api_url("search/code", {"q": query})
    resp = http.request("GET", api, headers=get_github_auth_headers(get_token))

    if resp.status != 200:
        raise GitHubRequestFailed(f"Request failed with " + resp.data.decode("utf-8"))

    return resp.json()


@logging_wrapper
async def search_repo_async(repo, language, keywords, get_token=None):
    # The docs at https://docs.github.com/en/rest/search/search?apiVersion=2022-11-28#search-code note that:
    # "This endpoint can be used without authentication if only public resources are requested."
    # However, this does not appear to be true, with issues like https://github.com/pbek/QOwnNotes/issues/2772#issuecomment-1513352222
    # noting:
    # "GitHub now demands an access token for the code search API and has a harsh quota on the amounts of searches per person"
    # I think the GitHub docs are incorrect, as I have not been able to perform a search without a token.

    query = f"{' '.join(keywords)} in:file language:{language} repo:{repo}"
    api = build_github_api_url("search/code", {"q": query})

    async with sem:
        async with aiohttp.ClientSession(
            headers=get_github_auth_headers(get_token)
        ) as session:
            async with session.get(str(api)) as response:
                if response.status != 200:
                    body = await response.text()
                    raise GitHubRequestFailed(f"Request failed with " + body)
                return await response.json()


@logging_wrapper
def download_file(url):
    """
    Download a file
    """
    return http.request("GET", url).data.decode("utf-8")


@logging_wrapper
async def download_file_async(url):
    """
    Download a file, respecting the rate limits
    """

    async with sem:
        async with aiohttp.ClientSession() as session:
            async with session.get(str(url)) as response:
                if response.status != 200:
                    body = await response.text()
                    raise GitHubRequestFailed(f"Request failed with " + body)
                return await response.text()


@logging_wrapper
async def get_latest_workflow_run_async(owner, repo, workflow_id, get_token):
    """
    Async function to get workflow run
    https://docs.github.com/en/rest/actions/workflow-runs?apiVersion=2022-11-28#list-workflow-runs-for-a-workflow
    """
    ensure_string_not_empty(
        owner, "owner must be a non-empty string (get_latest_workflow_run_async)."
    )
    ensure_string_not_empty(
        repo, "repo must be a non-empty string (get_latest_workflow_run_async)."
    )
    ensure_string_not_empty(
        workflow_id,
        "workflow_id must be a non-empty string (get_latest_workflow_run_async).",
    )
    ensure_string_not_empty(
        get_token,
        "get_token must be a non-empty string (get_latest_workflow_run_async).",
    )

    api = build_github_api_url(
        f"repos/{quote_safe(owner)}/{quote_safe(repo)}/actions/workflows/{quote_safe(workflow_id)}/runs",
        {"per_page": 1},
    )

    async with sem:
        async with aiohttp.ClientSession(
            headers=get_github_auth_headers(get_token)
        ) as session:
            async with session.get(str(api)) as response:
                return await response.json()


@logging_wrapper
async def get_workflow_run_async(owner, repo, run_id, get_token):
    """
    Async function to get workflow run
    https://docs.github.com/en/rest/actions/workflow-runs?apiVersion=2022-11-28#get-a-workflow-run
    """
    ensure_string_not_empty(
        owner, "owner must be a non-empty string (get_workflow_run)."
    )
    ensure_string_not_empty(repo, "repo must be a non-empty string (get_workflow_run).")
    ensure_string_not_empty(
        run_id, "run_id must be a non-empty string (get_workflow_run)."
    )
    ensure_string_not_empty(
        get_token, "get_token must be a non-empty string (get_workflow_run)."
    )

    api = build_github_api_url(
        f"/repos/{quote_safe(owner)}/{quote_safe(repo)}/actions/runs/{quote_safe(run_id)}"
    )

    async with sem:
        async with aiohttp.ClientSession(
            headers=get_github_auth_headers(get_token)
        ) as session:
            async with session.get(str(api)) as response:
                if response.status != 200:
                    body = await response.text()
                    raise GitHubRequestFailed(f"Request failed with " + body)
                return await response.json()


@logging_wrapper
async def get_workflow_run_logs_async(owner, repo, run_id, github_token):
    """
    Async function to get workflow run logs
    https://docs.github.com/en/rest/actions/workflow-runs?apiVersion=2022-11-28#download-workflow-run-logs
    """
    ensure_string_not_empty(
        owner, "owner must be a non-empty string (get_workflow_run_logs_async)."
    )
    ensure_string_not_empty(
        repo, "repo must be a non-empty string (get_workflow_run_logs_async)."
    )
    ensure_string_not_empty(
        run_id, "run_id must be a non-empty string (get_workflow_run_logs_async)."
    )
    ensure_string_not_empty(
        github_token,
        "github_token must be a non-empty string (get_workflow_run_logs_async).",
    )

    api = build_github_api_url(
        f"/repos/{quote_safe(owner)}/{quote_safe(repo)}/actions/runs/{quote_safe(run_id)}/logs"
    )

    async with sem:
        async with aiohttp.ClientSession(
            headers=get_github_auth_headers(github_token)
        ) as session:
            async with session.get(str(api)) as response:
                try:
                    with tempfile.NamedTemporaryFile(delete=True, suffix=".zip") as tf:
                        while True:
                            chunk = await response.content.read(1024)  # 1 KiB at a time
                            if not chunk:
                                break
                            tf.write(chunk)
                        with tempfile.TemporaryDirectory() as temp_dir:
                            with zipfile.ZipFile(tf, "r") as zip_ref:
                                zip_ref.extractall(temp_dir)

                            logs = ""
                            for file in os.listdir(temp_dir):
                                # We're only interested in the top level files
                                if os.path.isfile(os.path.join(temp_dir, file)):
                                    with open(os.path.join(temp_dir, file), "r") as f:
                                        logs += f.read() + "\n"

                            return logs
                except Exception as e:
                    raise GitHubRequestFailed(f"Request failed with " + str(e))


@logging_wrapper
async def get_workflow_artifacts_async(owner, repo, run_id, get_token):
    """
    Async function to get workflow run artifacts
    https://docs.github.com/en/rest/actions/artifacts?apiVersion=2022-11-28#list-workflow-run-artifacts
    """
    ensure_string_not_empty(
        owner, "owner must be a non-empty string (get_workflow_run)."
    )
    ensure_string_not_empty(repo, "repo must be a non-empty string (get_workflow_run).")
    ensure_string_not_empty(
        run_id, "run_id must be a non-empty string (get_workflow_run)."
    )
    ensure_string_not_empty(
        get_token, "get_token must be a non-empty string (get_workflow_run)."
    )

    api = build_github_api_url(
        f"/repos/{quote_safe(owner)}/{quote_safe(repo)}/actions/runs/{quote_safe(run_id)}/artifacts"
    )

    async with sem:
        async with aiohttp.ClientSession(
            headers=get_github_auth_headers(get_token)
        ) as session:
            async with session.get(str(api)) as response:
                if response.status != 200:
                    body = await response.text()
                    raise GitHubRequestFailed(f"Request failed with " + body)
                return await response.json()


@logging_wrapper
async def get_open_pull_requests_async(owner, repo, get_token):
    """
    Async function to get open pull requests run
    https://docs.github.com/en/rest/pulls/pulls?apiVersion=2022-11-28#list-pull-requests
    """
    ensure_string_not_empty(
        owner, "owner must be a non-empty string (get_open_pull_requests_async)."
    )
    ensure_string_not_empty(
        repo, "repo must be a non-empty string (get_open_pull_requests_async)."
    )
    ensure_string_not_empty(
        get_token,
        "get_token must be a non-empty string (get_open_pull_requests_async).",
    )

    api = build_github_api_url(
        f"/repos/{quote_safe(owner)}/{quote_safe(repo)}/pulls", {"state": "open"}
    )

    async with sem:
        async with aiohttp.ClientSession(
            headers=get_github_auth_headers(get_token)
        ) as session:
            async with session.get(str(api)) as response:
                if response.status != 200:
                    body = await response.text()
                    raise GitHubRequestFailed(f"Request failed with " + body)
                return await response.json()


@logging_wrapper
async def get_open_issues_async(owner, repo, get_token):
    """
    Async function to get open issues run
    https://docs.github.com/en/rest/issues/issues?apiVersion=2022-11-28#list-repository-issues
    """
    ensure_string_not_empty(
        owner, "owner must be a non-empty string (get_open_issues_async)."
    )
    ensure_string_not_empty(
        repo, "repo must be a non-empty string (get_open_issues_async)."
    )
    ensure_string_not_empty(
        get_token, "get_token must be a non-empty string (get_open_issues_async)."
    )

    api = build_github_api_url(
        f"/repos/{quote_safe(owner)}/{quote_safe(repo)}/issues", {"state": "open"}
    )

    async with sem:
        async with aiohttp.ClientSession(
            headers=get_github_auth_headers(get_token)
        ) as session:
            async with session.get(str(api)) as response:
                if response.status != 200:
                    body = await response.text()
                    raise GitHubRequestFailed(f"Request failed with " + body)
                issues = await response.json()
                # We don't want to show pull requests in the issues list, because every pull request is an issue
                # https://docs.github.com/en/rest/using-the-rest-api/issue-event-types?apiVersion=2022-11-28
                return list(filter(lambda x: "pull_request" not in x, issues))


@logging_wrapper
async def get_run_jobs_async(owner, repo, run_id, github_token):
    """
    Async function to get open issues run
    https://docs.github.com/en/rest/actions/workflow-jobs?apiVersion=2022-11-28#list-jobs-for-a-workflow-run
    """
    ensure_string_not_empty(
        owner, "owner must be a non-empty string (get_open_issues_async)."
    )
    ensure_string_not_empty(
        repo, "repo must be a non-empty string (get_open_issues_async)."
    )
    ensure_string_not_empty(
        github_token, "github_token must be a non-empty string (get_open_issues_async)."
    )

    api = build_github_api_url(
        f"/repos/{quote_safe(owner)}/{quote_safe(repo)}/actions/runs/{quote_safe(run_id)}/jobs"
    )

    async with sem:
        async with aiohttp.ClientSession(
            headers=get_github_auth_headers(github_token)
        ) as session:
            async with session.get(str(api)) as response:
                if response.status != 200:
                    body = await response.text()
                    raise GitHubRequestFailed(f"Request failed with " + body)
                return await response.json()


@logging_wrapper
async def get_repo_contents(owner, repo, directory, github_token):
    """
    Async function to get open issues run
    https://docs.github.com/en/rest/actions/workflow-jobs?apiVersion=2022-11-28#list-jobs-for-a-workflow-run
    """
    ensure_string_not_empty(
        owner, "owner must be a non-empty string (get_repo_contents)."
    )
    ensure_string_not_empty(
        repo, "repo must be a non-empty string (get_repo_contents)."
    )
    ensure_string_not_empty(
        directory, "directory must be a non-empty string (get_repo_contents)."
    )
    ensure_string_not_empty(
        github_token, "github_token must be a non-empty string (get_repo_contents)."
    )

    api = build_github_api_url(
        f"/repos/{quote_safe(owner)}/{quote_safe(repo)}/contents/{directory}"
    )

    async with sem:
        async with aiohttp.ClientSession(
            headers=get_github_auth_headers(github_token)
        ) as session:
            async with session.get(str(api)) as response:
                if response.status != 200:
                    body = await response.text()
                    raise GitHubRequestFailed(f"Request failed with " + body)
                return await response.json()


@logging_wrapper
async def search_issues(owner, repo, keywords, github_token):
    """
    Async function to search issues
    https://docs.github.com/en/rest/search/search?apiVersion=2022-11-28#search-issues-and-pull-requests
    """
    ensure_string_not_empty(owner, "owner must be a non-empty string (search_issues).")
    ensure_string_not_empty(repo, "repo must be a non-empty string (search_issues).")
    ensure_not_falsy(keywords, "keywords must be a list of strings (search_issues).")
    ensure_string_not_empty(
        github_token, "github_token must be a non-empty string (search_issues)."
    )

    quoted_keywords = map(lambda x: f'"{x}"', keywords[:max_keywords_with_boolean])

    api = build_github_api_url(
        f"/search/issues",
        {"q": f"{' OR '.join(quoted_keywords)} repo:{owner}/{repo} is:issue"},
    )

    async with sem:
        async with aiohttp.ClientSession(
            headers=get_github_auth_headers(github_token)
        ) as session:
            async with session.get(str(api)) as response:
                if response.status != 200:
                    body = await response.text()
                    raise GitHubRequestFailed(f"Request failed with " + body)
                return await response.json()


@logging_wrapper
async def get_issue_comments_async(owner, repo, issue_number, github_token):
    """
    Async function to get issue comments
    https://docs.github.com/en/rest/search/search?apiVersion=2022-11-28#search-issues-and-pull-requests
    """
    ensure_string_not_empty(
        owner, "owner must be a non-empty string (get_issue_comments)."
    )
    ensure_string_not_empty(
        repo, "repo must be a non-empty string (get_issue_comments)."
    )
    ensure_string_not_empty(
        issue_number, "issue_number must be a non-empty string (get_issue_comments)."
    )
    ensure_string_not_empty(
        github_token, "github_token must be a non-empty string (get_issue_comments)."
    )

    api = build_github_api_url(
        f"/repos/{quote_safe(owner)}/{quote_safe(repo)}/issues/{quote_safe(issue_number)}/comments"
    )

    async with sem:
        async with aiohttp.ClientSession(
            headers=get_github_auth_headers(github_token)
        ) as session:
            async with session.get(str(api)) as response:
                if response.status != 200:
                    body = await response.text()
                    raise GitHubRequestFailed(f"Request failed with " + body)
                return await response.json()


@logging_wrapper
async def get_commit_async(owner, repo, commit, github_token):
    """
    Async function to get the details of a commit
    https://docs.github.com/en/rest/commits/commits?apiVersion=2022-11-28#get-a-commit
    """
    ensure_string_not_empty(
        owner, "owner must be a non-empty string (get_commit_async)."
    )
    ensure_string_not_empty(repo, "repo must be a non-empty string (get_commit_async).")
    ensure_string_not_empty(
        commit, "commit must be a non-empty string (get_commit_async)."
    )
    ensure_string_not_empty(
        github_token, "github_token must be a non-empty string (get_commit_async)."
    )

    api = build_github_api_url(
        f"/repos/{quote_safe(owner)}/{quote_safe(repo)}/commits/{quote_safe(commit)}"
    )

    async with sem:
        async with aiohttp.ClientSession(
            headers=get_github_auth_headers(github_token)
        ) as session:
            async with session.get(str(api)) as response:
                if response.status != 200:
                    body = await response.text()
                    raise GitHubRequestFailed(f"Request failed with " + body)
                return await response.json()


@logging_wrapper
async def get_commit_diff_async(owner, repo, commit, github_token):
    """
    Async function to get commit diff
    https://docs.github.com/en/rest/commits/commits?apiVersion=2022-11-28#get-a-commit
    """
    ensure_string_not_empty(
        owner, "owner must be a non-empty string (get_commit_async)."
    )
    ensure_string_not_empty(repo, "repo must be a non-empty string (get_commit_async).")
    ensure_string_not_empty(
        commit, "commit must be a non-empty string (get_commit_async)."
    )
    ensure_string_not_empty(
        github_token, "github_token must be a non-empty string (get_commit_async)."
    )

    api = build_github_url(
        f"/{quote_safe(owner)}/{quote_safe(repo)}/commit/{quote_safe(commit)}.diff"
    )

    async with sem:
        async with aiohttp.ClientSession(
            headers=get_github_diff_headers(github_token)
        ) as session:
            async with session.get(str(api)) as response:
                if response.status != 200:
                    body = await response.text()
                    raise GitHubRequestFailed(f"Request failed with " + body)
                return await response.text()


@logging_wrapper
async def get_issues_comments(issues, github_token):
    return await asyncio.gather(
        *[
            combine_issue_comments(str(ticket["number"]), github_token)
            for ticket in issues
        ]
    )


async def combine_issue_comments(issue_number, github_token):
    comments = await get_issue_comments_async(
        "OctopusDeploy", "Issues", str(issue_number), github_token
    )

    combined_comments = [
        minify_strings(comment["body"]) for comment in comments if comment.get("body")
    ]

    sanitized_contents = [
        anonymize_message(sanitize_message(contents)) for contents in combined_comments
    ]

    return "\n".join(sanitized_contents)


async def get_issues(keywords, github_token):
    issues = await search_issues("OctopusDeploy", "Issues", keywords, github_token)
    return issues["items"]
