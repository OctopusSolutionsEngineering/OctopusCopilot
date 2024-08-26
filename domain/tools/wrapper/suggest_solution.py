import asyncio

from domain.transformers.minify_strings import minify_strings
from infrastructure.github import search_issues, get_issue_comments
from infrastructure.openai import llm_message_query
from infrastructure.zendesk import get_zen_tickets, get_zen_comments

max_issues = 10
max_keywords = 5


def suggest_solution_wrapper(query, callback, github_token, zendesk_user, zendesk_token, logging=None):
    def suggest_solution(keywords=None, **kwargs):
        """Suggests a solution to a help desk query, ticket, question, or issue.
        Example prompts include:
        * Suggest a solution for the following issue: "How can I use Harbor as a private image registry."
        * Provide a solution for the following error: "In my helm deploy step I am setting some \"Explicit Key Values\" and they don't seem to be transforming."

        Args:
            keywords: A list of keywords that describe the issue or question.
        """

        if logging:
            logging("Enter:", "suggest_solution")

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        limited_keywords = keywords[:max_keywords]

        # Get the list of issues and tickets
        issues = asyncio.run(
            asyncio.gather(
                get_tickets(limited_keywords, zendesk_user, zendesk_token),
                get_issues(limited_keywords, github_token), return_exceptions=True))

        # Gracefully fallback with any exceptions
        if logging:
            if isinstance(issues[0], Exception):
                logging("Zendesk Exception", str(issues[0]))
            if isinstance(issues[1], Exception):
                logging("GitHub Exception", str(issues[1]))

        limited_issues = [issues[0][:max_issues] if not isinstance(issues[0], Exception) else [], issues[1]['items'][:max_issues] if not isinstance(issues[1], Exception) else []]

        # Get the contents of the issues and tickets
        external_context = asyncio.run(
            asyncio.gather(
                get_tickets_comments(limited_issues[0], zendesk_user, zendesk_token),
                get_issues_comments(limited_issues[1], github_token), return_exceptions=True))

        # Gracefully fallback with any exceptions
        if logging:
            if isinstance(external_context[0], Exception):
                logging("Zendesk Exception", str(external_context[0]))
            if isinstance(external_context[1], Exception):
                logging("GitHub Exception", str(external_context[1]))

        fixed_external_context = [external_context[0] if not isinstance(external_context[0], Exception) else [], external_context[1] if not isinstance(external_context[1], Exception) else []]

        # The answer that we are trying to get from the LLM isn't something that is expected to be passed directly to
        # the customer. The answer will be used as a way to suggest possible solutions to the support engineers,
        # who will then investigate the problem and potential solutions further.
        messages = [
            ('system', 'You are helpful agent who can provide solutions to questions about Octopus Deploy.'),
            ('system',
             'The supplied conversations are related to the same topics as the question being asked.'),
            ('system',
             'The supplied issues are related to bugs related to the same topics as the question being asked.'),
            ('system',
             'Include any potential solutions that were provided in the supplied conversations and issues in the answer.'),
            ('system',
             'Include any troubleshooting steps that were provided in the supplied conversations and issues in the answer.'),
            ('system',
             'You must provide as many potential solutions and troubleshooting steps in the answer as possible.'),
            *[('user', "Conversation: ###\n" + context.replace("{", "{{").replace("}", "}}") + "\n###") for context in
              fixed_external_context[0]],
            *[('user', "Issue: ###\n" + context.replace("{", "{{").replace("}", "}}") + "\n###") for context in
              fixed_external_context[1]],
            ('user', "Question: {input}"),
            ('user', "Answer:")]

        context = {"input": query}
        chat_response = [llm_message_query(messages, context)]

        chat_response.append("🔍: " + ", ".join(limited_keywords))

        for github_issue in limited_issues[1]:
            chat_response.append(f"🐛: [{github_issue['title']}]({github_issue['html_url']})")

        for zendesk_issue in limited_issues[0]:
            chat_response.append(
                f"📧: [{zendesk_issue['subject']}](https://octopus.zendesk.com/agent/tickets/{zendesk_issue['id']})")

        return callback(query, keywords, "\n\n".join(chat_response))

    return suggest_solution


async def get_issues(keywords, github_token):
    return await search_issues("OctopusDeploy", "Issues", keywords, github_token)


async def get_issues_comments(issues, github_token):
    return [await combine_issue_comments(str(ticket['number']), github_token) for ticket in
            issues]


async def combine_issue_comments(issue_number, github_token):
    comments = await get_issue_comments("OctopusDeploy", "Issues", str(issue_number), github_token)
    combined_comments = "\n".join(
        [minify_strings(comment['body']) for comment in comments if comment['body']])

    # If we need to strip PII from the comments, we can do it here
    # combined_comments = anonymize_message(sanitize_message(combined_comments))

    return combined_comments


async def get_tickets(keywords, zendesk_user, zendesk_token):
    ticket_ids = {}

    # Zen desk only has AND logic for keywords. We really want OR logic.
    # So search for each keyword individually, tracking how many times a ticket was returned
    # by the search. We prioritise tickets with the most results.
    keyword_results = await asyncio.gather(
        *[get_zen_tickets([keyword], zendesk_user, zendesk_token) for keyword in keywords])

    for keyword_result in keyword_results:
        for ticket in keyword_result['results']:
            if not ticket_ids.get(ticket['id']):
                ticket_ids[ticket['id']] = {'count': 1, 'ticket': ticket}
            else:
                ticket_ids[ticket['id']]['count'] += 1

    sorted_by_second = sorted(ticket_ids.items(), key=lambda tup: tup[1]['count'], reverse=True)

    return list(map(lambda x: x[1]['ticket'], sorted_by_second))


async def get_tickets_comments(tickets, zendesk_user, zendesk_token):
    return [await combine_ticket_comments(str(ticket['id']), zendesk_user, zendesk_token) for ticket in
            tickets]


async def combine_ticket_comments(ticket_id, zendesk_user, zendesk_token):
    comments = await get_zen_comments(ticket_id, zendesk_user, zendesk_token)
    combined_comments = "\n".join(
        [minify_strings(comment['body']) for comment in comments['comments'] if
         comment['public']])

    # If we need to strip PII from the comments, we can do it here
    # combined_comments = anonymize_message(sanitize_message(combined_comments))

    return combined_comments
