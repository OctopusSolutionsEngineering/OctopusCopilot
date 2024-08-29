import asyncio

from slack_sdk.web.async_client import AsyncWebClient

from domain.exceptions.none_on_exception import (
    default_on_exception_async,
)
from domain.slack.slack_urls import generate_slack_login
from domain.transformers.minify_strings import minify_strings, replace_space_codes
from domain.transformers.trim_strings import trim_string_with_ellipsis
from domain.url.session import create_session_blob
from infrastructure.github import search_issues, get_issue_comments
from infrastructure.openai import llm_message_query
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

            # A key word like "Octopus" is not helpful
            invalid_keywords = ["octopus", "octopus deploy", "octopusdeploy"]
            filtered_keywords = [
                keyword
                for keyword in keywords
                if keyword.casefold().strip() not in invalid_keywords
            ]
            limited_keywords = filtered_keywords[:max_keywords]

            # Get the list of issues and tickets
            issues = await asyncio.gather(
                get_tickets(limited_keywords, zendesk_user, zendesk_token),
                get_issues(limited_keywords, github_token),
                return_exceptions=True,
            )

            # Best effort attempt to get Get slack messages, but ignoring exceptions
            slack_messages = await default_on_exception_async(
                lambda: get_slack_messages(slack_token, limited_keywords), []
            )

            # Gracefully fallback with any exceptions
            if logging:
                if isinstance(issues[0], Exception):
                    logging("Zendesk Exception", str(issues[0]))
                if isinstance(issues[1], Exception):
                    logging("GitHub Exception", str(issues[1]))

            limited_issues = [
                issues[0][:max_issues] if not isinstance(issues[0], Exception) else [],
                (
                    issues[1]["items"][:max_issues]
                    if not isinstance(issues[1], Exception)
                    else []
                ),
            ]

            # Get the contents of the issues and tickets
            external_context = await asyncio.gather(
                get_tickets_comments(limited_issues[0], zendesk_user, zendesk_token),
                get_issues_comments(limited_issues[1], github_token),
                return_exceptions=True,
            )

            slack_context = [message["text"] for message in slack_messages[:max_issues]]

            # Gracefully fallback with any exceptions
            if logging:
                if isinstance(external_context[0], Exception):
                    logging("Zendesk Exception", str(external_context[0]))
                if isinstance(external_context[1], Exception):
                    logging("GitHub Exception", str(external_context[1]))

            fixed_external_context = [
                (
                    external_context[0]
                    if not isinstance(external_context[0], Exception)
                    else []
                ),
                (
                    external_context[1]
                    if not isinstance(external_context[1], Exception)
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
                    "The supplied conversations are related to the same topics as the question being asked.",
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
                *[
                    (
                        "user",
                        "Conversation: ###\n"
                        + context.replace("{", "{{").replace("}", "}}")
                        + "\n###",
                    )
                    for context in fixed_external_context[0]
                ],
                *[
                    (
                        "user",
                        "Issue: ###\n"
                        + context.replace("{", "{{").replace("}", "}}")
                        + "\n###",
                    )
                    for context in fixed_external_context[1]
                ],
                *[
                    (
                        "user",
                        "Slack Message: ###\n"
                        + context.replace("{", "{{").replace("}", "}}")
                        + "\n###",
                    )
                    for context in slack_context
                ],
                ("user", "Question: {input}"),
                ("user", "Answer:"),
            ]

            context = {"input": query}
            chat_response = [llm_message_query(messages, context)]

            chat_response.append("🔍: " + ", ".join(limited_keywords))

            if not slack_token:
                # Is the GitHub user really a secret we need to encrypt? Probably not, but the ability to decrypt this
                # value on the return leg is a good indication the request came from us.
                session_json = create_session_blob(
                    github_user, encryption_password, encryption_salt
                )
                chat_response.append(f"❗: {generate_slack_login(session_json)}")

            for github_issue in limited_issues[1]:
                if github_issue.get("html_url") and github_issue.get("title"):
                    chat_response.append(
                        f"🐛: [{github_issue.get('title')}]({github_issue.get('html_url')})"
                    )

            for zendesk_issue in limited_issues[0]:
                if zendesk_issue.get("subject") and zendesk_issue.get("id"):
                    chat_response.append(
                        f"📧: [{zendesk_issue.get('subject')}](https://octopus.zendesk.com/agent/tickets/{zendesk_issue.get('id')})"
                    )

            for slack_message in slack_messages:
                if slack_message.get("permalink") and slack_message.get("text"):
                    chat_response.append(
                        f"🗨: [{trim_string_with_ellipsis(slack_message['text'].replace('\n', ' '), 100)}]({slack_message.get('permalink')})"
                    )

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
    conversations = await asyncio.gather(
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

    # get the returned messages
    conversation_messages = [item["messages"] for item in conversations]

    # flatten the list of lists
    flat_conversations = [item for sublist in conversation_messages for item in sublist]

    return flat_conversations


async def get_tickets(keywords, zendesk_user, zendesk_token):
    ticket_ids = {}

    # Zen desk only has AND logic for keywords. We really want OR logic.
    # So search for each keyword individually, tracking how many times a ticket was returned
    # by the search. We prioritise tickets with the most results.
    keyword_results = await asyncio.gather(
        *[
            get_zen_tickets([keyword], zendesk_user, zendesk_token)
            for keyword in keywords
        ]
    )

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
