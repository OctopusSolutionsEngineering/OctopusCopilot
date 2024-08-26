import asyncio

from domain.transformers.minify_strings import minify_strings
from infrastructure.github import search_issues, get_issue_comments
from infrastructure.openai import llm_message_query
from infrastructure.zendesk import get_zen_tickets, get_zen_comments


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

        external_context = asyncio.run(
            asyncio.gather(
                get_tickets(keywords, zendesk_user, zendesk_token),
                get_issues(keywords, github_token)))

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
              external_context[0]],
            *[('user', "Issue: ###\n" + context.replace("{", "{{").replace("}", "}}") + "\n###") for context in
              external_context[1]],
            ('user', "Question: {input}"),
            ('user', "Answer:")]

        context = {"input": query}
        chat_response = llm_message_query(messages, context)

        return callback(query, keywords, chat_response)

    return suggest_solution


async def get_issues(keywords, github_token, max_keywords=5, max_issues=10):
    issues = await search_issues("OctopusDeploy", "Issues", keywords, github_token)
    return [await combine_issue_comments(str(ticket['number']), github_token) for ticket in
            issues['items'][:max_issues]]


async def combine_issue_comments(issue_number, github_token):
    comments = await get_issue_comments("OctopusDeploy", "Issues", str(issue_number), github_token)
    combined_comments = "\n".join(
        [minify_strings(comment['body']) for comment in comments])

    # If we need to strip PII from the comments, we can do it here
    # combined_comments = anonymize_message(sanitize_message(combined_comments))

    return combined_comments


async def get_tickets(keywords, zendesk_user, zendesk_token, max_keywords=5, max_tickets=10):
    ticket_ids = {}

    # Zen desk only has AND logic for keywords. We really want OR logic.
    # So search for each keyword individually, tracking how many times a ticket was returned
    # by the search. We prioritise tickets with the most results.
    keyword_results = await asyncio.gather(
        *[get_zen_tickets([keyword], zendesk_user, zendesk_token) for keyword in keywords[:max_keywords]])

    for keyword_result in keyword_results:
        for ticket in keyword_result['results'][:max_tickets]:
            if not ticket_ids.get(ticket['id']):
                ticket_ids[ticket['id']] = 1
            else:
                ticket_ids[ticket['id']] += 1

    sorted_by_second = sorted(ticket_ids.items(), key=lambda tup: tup[1], reverse=True)

    return [await combine_ticket_comments(str(ticket[0]), zendesk_user, zendesk_token) for ticket in
            sorted_by_second[:max_tickets]]


async def combine_ticket_comments(ticket_id, zendesk_user, zendesk_token):
    comments = await get_zen_comments(ticket_id, zendesk_user, zendesk_token)
    combined_comments = "\n".join(
        [minify_strings(comment['body']) for comment in comments['comments'] if
         comment['public']])

    # If we need to strip PII from the comments, we can do it here
    # combined_comments = anonymize_message(sanitize_message(combined_comments))

    return combined_comments
