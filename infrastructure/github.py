import asyncio
from urllib.parse import urlparse, urlencode, urlunsplit

import aiohttp
from expiring_dict import ExpiringDict

from domain.exceptions.request_failed import GitHubRequestFailed
from domain.sanitizers.url_sanitizer import quote_safe
from domain.validation.argument_validation import ensure_string_not_empty
from infrastructure.http_pool import http

# Token user lookup cache that expires in 15 minutes.
# This is really only for tests as Azure functions are going to launch a new instance for each request,
# and the cache will be empty.
token_lookup_cache = ExpiringDict(60 * 15)

# Semaphore to limit the number of concurrent requests to GitHub
sem = asyncio.Semaphore(10)


def get_github_auth_headers(get_token):
    """
    Build the headers used to make an Octopus API request
    :param get_token: The function used to get theGithub token
    :return: The headers required to call the Octopus API
    """

    headers = {
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28"
    }

    if get_token:
        headers["Authorization"] = "Bearer {}".format(get_token)

    return headers


def build_github_url(path, query=None):
    """
    Create a URL from the GitHub API URL, additional path, and query params
    :param path: The additional path
    :param query: Additional query params
    :return: The URL combining all the inputs
    """

    parsed = urlparse("https://api.github.com")
    query = urlencode(query) if query is not None else ""
    return urlunsplit((parsed.scheme, parsed.netloc, path, query, ""))


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

    api = build_github_url("user", "")

    resp = http.request("GET", api, headers=get_github_auth_headers(get_token))

    if resp.status != 200:
        raise GitHubRequestFailed(f"Request failed with " + resp.data.decode('utf-8'))

    json = resp.json()

    # Cache the user lookup result
    token_lookup_cache[get_token] = json

    return str(json["id"])


def search_repo(repo, language, keywords, get_token=None):
    # The docs at https://docs.github.com/en/rest/search/search?apiVersion=2022-11-28#search-code note that:
    # "This endpoint can be used without authentication if only public resources are requested."
    # However, this does not appear to be true, with issues like https://github.com/pbek/QOwnNotes/issues/2772#issuecomment-1513352222
    # noting:
    # "GitHub now demands an access token for the code search API and has a harsh quota on the amounts of searches per person"
    # I think the GitHub docs are incorrect, as I have not been able to perform a search without a token.
    query = f"{' '.join(keywords)} in:file language:{language} repo:{repo}"
    api = build_github_url("search/code", {"q": query})
    resp = http.request("GET", api, headers=get_github_auth_headers(get_token))

    if resp.status != 200:
        raise GitHubRequestFailed(f"Request failed with " + resp.data.decode('utf-8'))

    return resp.json()


async def get_latest_workflow_run_async(owner, repo, workflow_id, get_token):
    """
    Async function to get workflow run
    https://docs.github.com/en/rest/actions/workflow-runs?apiVersion=2022-11-28#list-workflow-runs-for-a-workflow
    """
    ensure_string_not_empty(owner, 'owner must be a non-empty string (get_latest_workflow_run_async).')
    ensure_string_not_empty(repo, 'repo must be a non-empty string (get_latest_workflow_run_async).')
    ensure_string_not_empty(workflow_id, 'workflow_id must be a non-empty string (get_latest_workflow_run_async).')
    ensure_string_not_empty(get_token, 'get_token must be a non-empty string (get_latest_workflow_run_async).')

    api = build_github_url(
        f"repos/{quote_safe(owner)}/{quote_safe(repo)}/actions/workflows/{quote_safe(workflow_id)}/runs",
        {"per_page": 1})

    async with sem:
        async with aiohttp.ClientSession(headers=get_github_auth_headers(get_token)) as session:
            async with session.get(str(api)) as response:
                return await response.json()


async def get_workflow_run_async(owner, repo, run_id, get_token):
    """
    Async function to get workflow run
    https://docs.github.com/en/rest/actions/workflow-runs?apiVersion=2022-11-28#get-a-workflow-run
    """
    ensure_string_not_empty(owner, 'owner must be a non-empty string (get_workflow_run).')
    ensure_string_not_empty(repo, 'repo must be a non-empty string (get_workflow_run).')
    ensure_string_not_empty(run_id, 'run_id must be a non-empty string (get_workflow_run).')
    ensure_string_not_empty(get_token, 'get_token must be a non-empty string (get_workflow_run).')

    api = build_github_url(f"/repos/{quote_safe(owner)}/{quote_safe(repo)}/actions/runs/{quote_safe(run_id)}")

    async with sem:
        async with aiohttp.ClientSession(headers=get_github_auth_headers(get_token)) as session:
            async with session.get(str(api)) as response:
                if response.status != 200:
                    body = await response.text()
                    raise GitHubRequestFailed(f"Request failed with " + body)
                return await response.json()


async def get_workflow_artifacts_async(owner, repo, run_id, get_token):
    """
    Async function to get workflow run artifacts
    https://docs.github.com/en/rest/actions/artifacts?apiVersion=2022-11-28#list-workflow-run-artifacts
    """
    ensure_string_not_empty(owner, 'owner must be a non-empty string (get_workflow_run).')
    ensure_string_not_empty(repo, 'repo must be a non-empty string (get_workflow_run).')
    ensure_string_not_empty(run_id, 'run_id must be a non-empty string (get_workflow_run).')
    ensure_string_not_empty(get_token, 'get_token must be a non-empty string (get_workflow_run).')

    api = build_github_url(f"/repos/{quote_safe(owner)}/{quote_safe(repo)}/actions/runs/{quote_safe(run_id)}/artifacts")

    async with sem:
        async with aiohttp.ClientSession(headers=get_github_auth_headers(get_token)) as session:
            async with session.get(str(api)) as response:
                if response.status != 200:
                    body = await response.text()
                    raise GitHubRequestFailed(f"Request failed with " + body)
                return await response.json()


async def get_open_pull_requests_async(owner, repo, get_token):
    """
    Async function to get open pull requests run
    https://docs.github.com/en/rest/pulls/pulls?apiVersion=2022-11-28#list-pull-requests
    """
    ensure_string_not_empty(owner, 'owner must be a non-empty string (get_open_pull_requests_async).')
    ensure_string_not_empty(repo, 'repo must be a non-empty string (get_open_pull_requests_async).')
    ensure_string_not_empty(get_token, 'get_token must be a non-empty string (get_open_pull_requests_async).')

    api = build_github_url(f"/repos/{quote_safe(owner)}/{quote_safe(repo)}/pulls", {"state": "open"})

    async with sem:
        async with aiohttp.ClientSession(headers=get_github_auth_headers(get_token)) as session:
            async with session.get(str(api)) as response:
                if response.status != 200:
                    body = await response.text()
                    raise GitHubRequestFailed(f"Request failed with " + body)
                return await response.json()


async def get_open_issues_async(owner, repo, get_token):
    """
    Async function to get open issues run
    https://docs.github.com/en/rest/issues/issues?apiVersion=2022-11-28#list-repository-issues
    """
    ensure_string_not_empty(owner, 'owner must be a non-empty string (get_open_issues_async).')
    ensure_string_not_empty(repo, 'repo must be a non-empty string (get_open_issues_async).')
    ensure_string_not_empty(get_token, 'get_token must be a non-empty string (get_open_issues_async).')

    api = build_github_url(f"/repos/{quote_safe(owner)}/{quote_safe(repo)}/issues", {"state": "open"})

    async with sem:
        async with aiohttp.ClientSession(headers=get_github_auth_headers(get_token)) as session:
            async with session.get(str(api)) as response:
                if response.status != 200:
                    body = await response.text()
                    raise GitHubRequestFailed(f"Request failed with " + body)
                issues = await response.json()
                # We don't want to show pull requests in the issues list, because every pull request is an issue
                # https://docs.github.com/en/rest/using-the-rest-api/issue-event-types?apiVersion=2022-11-28
                return list(filter(lambda x: "pull_request" not in x, issues))


async def get_run_jobs_async(owner, repo, run_id, github_token):
    """
    Async function to get open issues run
    https://docs.github.com/en/rest/actions/workflow-jobs?apiVersion=2022-11-28#list-jobs-for-a-workflow-run
    """
    ensure_string_not_empty(owner, 'owner must be a non-empty string (get_open_issues_async).')
    ensure_string_not_empty(repo, 'repo must be a non-empty string (get_open_issues_async).')
    ensure_string_not_empty(github_token, 'github_token must be a non-empty string (get_open_issues_async).')

    api = build_github_url(f"/repos/{quote_safe(owner)}/{quote_safe(repo)}/actions/runs/{quote_safe(run_id)}/jobs")

    async with sem:
        async with aiohttp.ClientSession(headers=get_github_auth_headers(github_token)) as session:
            async with session.get(str(api)) as response:
                if response.status != 200:
                    body = await response.text()
                    raise GitHubRequestFailed(f"Request failed with " + body)
                return await response.json()
