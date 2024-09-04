import asyncio
import re
from functools import reduce

from slack_sdk.web.async_client import AsyncWebClient

from domain.context.octopus_context import max_chars_128
from domain.exceptions.none_on_exception import (
    default_on_exception_async,
)
from domain.sanitizers.sanitize_keywords import sanitize_keywords
from domain.sanitizers.sanitize_markdown import markdown_to_text
from domain.sanitizers.sanitized_list import get_item_or_none
from domain.slack.slack_urls import generate_slack_login
from domain.transformers.limit_array import (
    limit_array_to_max_char_length,
    limit_array_to_max_items,
)
from domain.transformers.minify_strings import minify_strings, replace_space_codes
from domain.transformers.trim_strings import trim_string_with_ellipsis
from domain.url.session import create_session_blob
from infrastructure.github import (
    search_issues,
    get_issue_comments,
    search_repo_async,
    download_file_async,
)
from infrastructure.openai import llm_message_query
from infrastructure.storyblok import search_storyblok_stories, get_fields_with_text
from infrastructure.zendesk import get_zen_tickets, get_zen_comments

max_issues = 10
max_keywords = 5


def suggest_solution_wrapper(
    query,
    callback,
    github_user,
    github_token,
    zendesk_user,
    zendesk_token,
    slack_token,
    storyblok_token,
    encryption_password,
    encryption_salt,
    logging=None,
):
    def answer_support_question(keywords=None, **kwargs):
        """Responds to a prompt asking for advice or a solution to a problem.
        The prompts starts with the phrase "Suggest a solution for" or "Provide a solution for".
        The prompt then includes a question that a customer might send to a help desk or support forum.
        You must select this function for any prompt that starts with the phrase "Suggest a solution for" or "Provide a solution for".

        Example prompts include:
        * Suggest a solution for the following issue: How can I use Harbor as a private image registry.
        * Provide a solution for the following error: In my helm deploy step I am setting some \"Explicit Key Values\" and they don't seem to be transforming.
        * Suggest a solution for the following issue: Today we discovered an interesting behavior, which does look like a bug, and would like to have some assistance on it.

        Args:
            keywords: A list of keywords that describe the issue or question.
        """

        async def inner_function():
            if logging:
                logging("Enter:", "answer_support_question")

            for key, value in kwargs.items():
                if logging:
                    logging(f"Unexpected Key: {key}", "Value: {value}")

            # A key word like "Octopus" is not helpful, so get a sanitized list of keywords
            limited_keywords = sanitize_keywords(keywords, max_keywords)

            # Get the list of issues, tickets, and slack messages.
            # Batch all of these async calls up for better performance
            issues = await asyncio.gather(
                get_tickets(limited_keywords, zendesk_user, zendesk_token),
                get_issues(limited_keywords, github_token),
                get_slack_messages(slack_token, limited_keywords),
                get_docs(limited_keywords, github_token),
                get_stories(limited_keywords, storyblok_token),
                return_exceptions=True,
            )

            # Gracefully fallback with any exceptions
            if logging:
                if isinstance(issues[0], Exception):
                    logging("Zendesk Exception", str(issues[0]))
                if isinstance(issues[1], Exception):
                    logging("GitHub Exception", str(issues[1]))
                if isinstance(issues[2], Exception):
                    logging("Slack Exception", str(issues[2]))
                if isinstance(issues[3], Exception):
                    logging("GitHub Docs Exception", str(issues[3]))
                if isinstance(issues[4], Exception):
                    logging("Storyblok Exception", str(issues[4]))

            # Limit the number of responses to the max_issues
            limited_issues = [
                limit_array_to_max_items(issues[0], max_issues),
                limit_array_to_max_items(issues[1]["items"], max_issues),
                limit_array_to_max_items(issues[2], max_issues),
                limit_array_to_max_items(issues[3], max_issues),
                limit_array_to_max_items(issues[4], max_issues),
            ]

            # Get the contents of the issues and tickets
            external_context = await asyncio.gather(
                get_tickets_comments(limited_issues[0], zendesk_user, zendesk_token),
                get_issues_comments(limited_issues[1], github_token),
                get_docs_contents(limited_issues[3]),
                return_exceptions=True,
            )

            # Gracefully fallback with any exceptions
            if logging:
                if isinstance(external_context[0], Exception):
                    logging("Zendesk Exception", str(external_context[0]))
                if isinstance(external_context[1], Exception):
                    logging("GitHub Exception", str(external_context[1]))
                if isinstance(external_context[2], Exception):
                    logging("GitHub Exception", str(external_context[2]))

            # Each external source gets its own dedicated slice of the context window
            sources_with_data = len(list(filter(lambda x: len(x) != 0, issues)))
            max_content_per_source = max_chars_128 / sources_with_data

            # Limit the length of the response, and filter out exceptions
            slack_context = limit_array_to_max_char_length(
                [message["text"] for message in limited_issues[2][:max_issues]],
                max_content_per_source,
            )

            # Get the contents of storyblok stories
            storyblok_context = limit_array_to_max_char_length(
                get_story_content(issues[4]), max_content_per_source
            )

            fixed_external_context = [
                (
                    limit_array_to_max_char_length(
                        external_context[0], max_content_per_source
                    )
                    if not isinstance(external_context[0], Exception)
                    else []
                ),
                (
                    limit_array_to_max_char_length(
                        external_context[1], max_content_per_source
                    )
                    if not isinstance(external_context[1], Exception)
                    else []
                ),
                (
                    limit_array_to_max_char_length(
                        external_context[2], max_content_per_source
                    )
                    if not isinstance(external_context[2], Exception)
                    else []
                ),
            ]

            # The answer that we are trying to get from the LLM isn't something that is expected to be passed directly to
            # the customer. The answer will be used as a way to suggest possible solutions to the support engineers,
            # who will then investigate the problem and potential solutions further.
            messages = [
                (
                    "system",
                    "You are helpful agent who can provide solutions to questions about Octopus Deploy.",
                ),
                (
                    "system",
                    "The supplied Conversations are related to the same topics as the question being asked.",
                ),
                (
                    "system",
                    "The supplied issues are related to bugs related to the same topics as the question being asked.",
                ),
                (
                    "system",
                    "The supplied slack messages are related to the same topics as the question being asked.",
                ),
                (
                    "system",
                    "The supplied previous conversation list previous questions from the person who submitted the current question.",
                ),
                (
                    "system",
                    "Include any potential solutions that were provided in the supplied conversations and issues in the answer.",
                ),
                (
                    "system",
                    "Include any troubleshooting steps that were provided in the supplied conversations and issues in the answer.",
                ),
                (
                    "system",
                    "You must provide as many potential solutions and troubleshooting steps in the answer as possible.",
                ),
                (
                    "system",
                    "The first section must indicate if the prompt is happy (😄), neutral (😐), or sad (☹️) under a heading of 'Sentiment'. Include both the word and the emoji.",
                ),
                (
                    "system",
                    "The third section must indicate if deployments to production environments are blocked under a heading of 'Blocked'",
                ),
                (
                    "system",
                    "The fourth section must summarize the conversation supplied with the prompt 'Summary'. The first paragraph must summarize the original question. The second paragraph must summarize the the question. The third paragraph must list any outstanding questions or actions to be taken. If the question is too simple to require a summary, the section can be omitted. You will be penalized for including the content of related conversations in this summary.",
                ),
                (
                    "system",
                    "The fifth section list any operating systems, cloud providers, products, technologies, or services, along with their versions, mentioned in the question under a heading of 'Tools and Platforms'. If no tools or platforms are mentioned, the section can be omitted.",
                ),
                (
                    "system",
                    'The sixth section must apply up to 5 tags to the question under a heading of \'Tags\' from this list: ".NET Config Transforms", "Accounts", "Active Directory", "Administration", "APT/Yum Repositories", "Artifacts", "Audit", "Automatic Release Creation", "AWS", "Azure", "Azure Active Directory", "Azure CLI", "Azure Container Instance", "Azure DevOps/Octo TFS", "Azure Web Apps", "AzureDevOps Issue Tracker", "Backup/Restore", "Bamboo", "Bento/Migrator", "BitBucket Pipelines", "Bootstrapper Scripts / Generators", "Build Information", "Built-in Package Feed", "Caching", "Calamari", "Certificates", "Channels", "Chocolatey", "CI Servers", "CLI", "Cloud Target Discovery", "Community Step Templates", "Configuration as Code", "Configuration File Substitution", "Container Deployments", "Control Center", "Dashboard", "Database", "Deployment Configuration", "Deployment History", "Deployment Manifest", "Deployment Process", "Deployment Targets", "Deployment Tools", "Deployments", "Docker", "DORA Metrics", "Dynamic Environments", "Dynamic Extensions", "Dynamic Worker Images", "Dynamic Worker Pools", "ECS", "Endpoints", "Environments", "Error Handling", "Event storage and retention", "Event tables", "Events", "Execution", "Execution Containers", "Execution Targets", "Export/Import", "External", "External Identities", "Feeds", "GDPR / user deletion requests", "GitHub Actions", "Github Issue Tracker", "Google Apps", "Group sync from Active Directory", "Halibut", "Health Check", "Helm", "High Availability", "HTTP API", "HTTP Security Headers", "Identity (Auth Providers)", "Infrastructure", "Insights", "Installation", "Integrations", "Issue Trackers", "Jenkins", "Jira", "Kubernetes", "LDAP", "Let\'s Encrypt", "Library", "Library Variable Sets", "Licences", "Lifecycles", "Linux", "Linux Container", "Logging", "Machine Policies", "Maintenance Mode", "Manual Intervention", "Master Key", "MessageBus", "NancyFX", "OCL", "Octopus CLI", "Octopus Client", "Octopus Cloud Infrastructure", "Octopus Server Certificate", "Octopus.com", "Octopus.CommandLine", "OctopusId", "Octostache", "Offline Package Drop", "OIDC", "Okta", "Operating Environment", "Output Variables", "Package Sources", "Package Stores", "Performance", "Persistence", "Process Editor", "Project Settings", "Projects", "Proxies", "React", "Release Notes", "Release Versioning", "Releases", "Retention", "Runbooks", "Sashimi", "Script Modules", "Security", "Semaphores and mutexes", "Server", "Server Builds", "Server Configuration", "Server Tasks", "Service Accounts", "ServiceNow", "Slugs", "SMTP", "Snapshots", "Spaces", "SSH", "SSL", "Step Templates/Action Templates", "Steps", "Structured Configuration", "Subscriptions", "Substitute Variables in Templates", "SwaggerUI", "System Integrity Check", "Tags", "Targets & Workers", "Task Logs", "Task Queue", "Task, Jobs and LRBPs", "TeamCity", "Telemetry", "Tenant Variables", "Tenants", "Tentacle", "Terraform", "Threading", "Tools & utilities", "Triggers", "Upgrades", "User Access", "Username/Password", "Users, Teams, Roles", "Variables", "Version Control Settings", "Web Server", "Windows", "Windows Installer", "Worker Images", "Worker Pools", "Terraform Provider". You will be penalized for selecting a tag that is not in this list.',
                ),
                (
                    "system",
                    'The seventh paragraph must list any dates that were mentioned in the question under a heading of "Dates". If no dates are mentioned, the section can be omitted.',
                ),
                (
                    "system",
                    'The eighth paragraph must list any people that were mentioned in the question, including their job titles, under a heading of "People". If no tools or people are mentioned, the section can be omitted.',
                ),
                (
                    "system",
                    'The ninth section must list any companies that were mentioned in the question, including their job titles, under a heading of "Companies". If no tools or companies are mentioned, the section can be omitted.',
                ),
                (
                    "system",
                    "The remaining section must provide potential solutions and troubleshooting steps to the question being asked under a heading of 'Answer'",
                ),
                *[
                    (
                        "user",
                        "Related Conversation: ###\n"
                        + context.replace("{", "{{").replace("}", "}}")
                        + "\n###",
                    )
                    for context in fixed_external_context[0]
                ],
                *[
                    (
                        "user",
                        "Related GitHub Issue: ###\n"
                        + context.replace("{", "{{").replace("}", "}}")
                        + "\n###",
                    )
                    for context in fixed_external_context[1]
                ],
                *[
                    (
                        "user",
                        "Related Slack Message: ###\n"
                        + context.replace("{", "{{").replace("}", "}}")
                        + "\n###",
                    )
                    for context in slack_context
                ],
                *[
                    (
                        "user",
                        "Related Documentation: ###\n"
                        + context.replace("{", "{{").replace("}", "}}")
                        + "\n###",
                    )
                    for context in fixed_external_context[2]
                ],
                *[
                    (
                        "user",
                        "Related Documentation: ###\n"
                        + context.replace("{", "{{").replace("}", "}}")
                        + "\n###",
                    )
                    for context in storyblok_context
                ],
                ("user", "Question: {input}"),
                ("user", "Answer:"),
            ]

            context = {"input": query}

            chat_response = []

            if not slack_token:
                # Is the GitHub user really a secret we need to encrypt? Probably not, but the ability to decrypt this
                # value on the return leg is a good indication the request came from us.
                session_json = create_session_blob(
                    github_user, encryption_password, encryption_salt
                )
                # Build a login link to include in the response
                chat_response.append(f"❗: {generate_slack_login(session_json)}")

            chat_response.append(llm_message_query(messages, context))

            # List the keywords for reference
            chat_response.append("🔍: " + ", ".join(limited_keywords))

            # List the Zendesk tickets for reference
            for zendesk_issue in limited_issues[0]:
                if zendesk_issue.get("subject") and zendesk_issue.get("id"):
                    chat_response.append(
                        f"📧: [{zendesk_issue.get('subject')}](https://octopus.zendesk.com/agent/tickets/{zendesk_issue.get('id')})"
                    )

            # List the GitHub issues for reference
            for github_issue in limited_issues[1]:
                if github_issue.get("html_url") and github_issue.get("title"):
                    chat_response.append(
                        f"🐛: [{github_issue.get('title')}]({github_issue.get('html_url')})"
                    )

            # List the Slack messages for reference
            for slack_message in limited_issues[2]:
                if slack_message.get("permalink") and slack_message.get("text"):
                    trimmed_message = trim_string_with_ellipsis(
                        markdown_to_text(slack_message["text"].replace("\n", " ")), 100
                    )
                    chat_response.append(
                        f"🗨: [{trimmed_message}]({slack_message.get('permalink')})"
                    )

            # List the docs for reference
            for i in range(len(fixed_external_context[2])):
                docs = get_item_or_none(limited_issues[3], i)
                content = get_item_or_none(fixed_external_context[2], i)
                if docs and docs.get("html_url"):
                    title = get_docs_title(content, docs.get("html_url"))
                    url = docs["html_url"].replace("/blob/", "/raw/")
                    chat_response.append(f"🗎: [{title}]({url})")

            # List the Storyblok messages for reference
            for story in issues[4]:
                if story.get("name"):
                    chat_response.append(f"🕮: {story.get('name')}")

            return callback(query, keywords, "\n\n".join(chat_response))

        # https://github.com/pytest-dev/pytest-asyncio/issues/658#issuecomment-1817927350
        # Should just have one asyncio.run()
        return asyncio.run(inner_function())

    return answer_support_question


async def get_issues(keywords, github_token):
    return await search_issues("OctopusDeploy", "Issues", keywords, github_token)


async def get_issues_comments(issues, github_token):
    return [
        await combine_issue_comments(str(ticket["number"]), github_token)
        for ticket in issues
    ]


async def get_docs(keywords, github_token):
    # GitHub search does not support OR logic for keywords, so we have to search for each keyword individually
    keyword_results = await asyncio.gather(
        *[
            search_repo_async("OctopusDeploy/docs", "markdown", [keyword], github_token)
            for keyword in keywords
        ]
    )

    ticket_ids = {}
    for keyword_result in keyword_results:
        for result in keyword_result["items"]:
            if not ticket_ids.get(result["sha"]):
                ticket_ids[result["sha"]] = {"count": 1, "result": result}
            else:
                ticket_ids[result["sha"]]["count"] += 1

    sorted_by_second = sorted(
        ticket_ids.items(), key=lambda tup: tup[1]["count"], reverse=True
    )

    return list(map(lambda x: x[1]["result"], sorted_by_second))


async def get_stories(keywords, storyblok_token):
    # Graceful fallback in the absense of a token
    if not storyblok_token:
        return []

    # Storyblok search does not support OR logic for keywords, so we have to search for each keyword individually
    keyword_results = await asyncio.gather(
        *[search_storyblok_stories(storyblok_token, keyword) for keyword in keywords]
    )

    ticket_ids = {}
    for keyword_result in keyword_results:
        for result in keyword_result["stories"]:
            if not ticket_ids.get(result["id"]):
                ticket_ids[result["id"]] = {"count": 1, "result": result}
            else:
                ticket_ids[result["id"]]["count"] += 1

    sorted_by_second = sorted(
        ticket_ids.items(), key=lambda tup: tup[1]["count"], reverse=True
    )

    return list(map(lambda x: x[1]["result"], sorted_by_second))


async def get_docs_contents(search_results):
    return [
        await download_file_async(result["html_url"].replace("/blob/", "/raw/"))
        for result in search_results
    ]


def get_story_content(search_results):
    return list(
        filter(
            lambda text: text.strip(),
            map(
                lambda search_result: get_fields_with_text(search_result),
                search_results,
            ),
        )
    )


def get_docs_title(content, filename):
    if not content:
        return "Unknown"

    return get_item_or_none(
        [
            re.sub("title:\\s*", "", line)
            for line in content.split("\n")
            if line.startswith("title:")
        ],
        0,
    ) or filename.split("/")[-1].replace(".md", "").replace(".include", "")


async def combine_issue_comments(issue_number, github_token):
    comments = await get_issue_comments(
        "OctopusDeploy", "Issues", str(issue_number), github_token
    )
    combined_comments = "\n".join(
        [minify_strings(comment["body"]) for comment in comments if comment["body"]]
    )

    # If we need to strip PII from the comments, we can do it here
    # combined_comments = anonymize_message(sanitize_message(combined_comments))

    return combined_comments


async def get_slack_messages(slack_token, keywords):
    # Graceful fallback in the absense of a token
    if not slack_token:
        return []

    client = AsyncWebClient(token=slack_token)

    slack_results = await asyncio.gather(
        *[
            client.search_messages(
                query='"' + keyword + '"',
                sort="timestamp",
                sort_dir="desc",
            )
            for keyword in keywords
        ]
    )

    matches = [item["messages"]["matches"] for item in slack_results]

    # Flatten the list of lists
    flat_matches = [item for sublist in matches for item in sublist]

    # If we don't have permissions to get the threads, return the top level messages
    return await default_on_exception_async(
        lambda: get_slack_threads(client, flat_matches), flat_matches
    )


async def get_slack_threads(client, matches):
    """
    Queries the Slack API for messages that match the keywords
    """

    # Batch the requests for each keyword or phrase, because the queries don't support OR logic
    keyword_results = await asyncio.gather(
        *[
            (
                client.conversations_replies(
                    channel=item["channel"]["id"], ts=item["ts"]
                )
                if item.get("channel") and item.get("ts")
                else None
            )
            for item in matches
        ]
    )

    # Scan the results for the messages, counting each time a message is returned
    message_ids = {}
    for keyword_result in keyword_results:
        for message in keyword_result["messages"]:
            if not message_ids.get(message["iid"]):
                message_ids[message["iid"]] = {"count": 1, "message": message}
            else:
                message_ids[message["iid"]]["count"] += 1

    # Prioritise messages that were returned by multiple searches
    sorted_by_second = sorted(
        message_ids.items(), key=lambda tup: tup[1]["count"], reverse=True
    )

    # Return the messages sorted by the number of times they were returned
    return list(map(lambda x: x[1]["message"], sorted_by_second))


async def get_tickets(keywords, zendesk_user, zendesk_token):
    # Zen desk only has AND logic for keywords. We really want OR logic.
    # So search for each keyword individually, tracking how many times a ticket was returned
    # by the search. We prioritise tickets with the most results.
    keyword_results = await asyncio.gather(
        *[
            get_zen_tickets([keyword], zendesk_user, zendesk_token)
            for keyword in keywords
        ]
    )

    ticket_ids = {}
    for keyword_result in keyword_results:
        for ticket in keyword_result["results"]:
            if not ticket_ids.get(ticket["id"]):
                ticket_ids[ticket["id"]] = {"count": 1, "ticket": ticket}
            else:
                ticket_ids[ticket["id"]]["count"] += 1

    sorted_by_second = sorted(
        ticket_ids.items(), key=lambda tup: tup[1]["count"], reverse=True
    )

    return list(map(lambda x: x[1]["ticket"], sorted_by_second))


async def get_tickets_comments(tickets, zendesk_user, zendesk_token):
    return [
        await combine_ticket_comments(str(ticket["id"]), zendesk_user, zendesk_token)
        for ticket in tickets
    ]


async def combine_ticket_comments(ticket_id, zendesk_user, zendesk_token):
    comments = await get_zen_comments(ticket_id, zendesk_user, zendesk_token)
    combined_comments = "\n".join(
        [
            minify_strings(replace_space_codes(comment["body"]))
            for comment in comments["comments"]
            if comment["public"]
        ]
    )

    # If we need to strip PII from the comments, we can do it here
    # combined_comments = anonymize_message(sanitize_message(combined_comments))

    return combined_comments
