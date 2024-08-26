import asyncio

from domain.sanitizers.sanitize_logs import anonymize_message, sanitize_message
from domain.transformers.minify_strings import minify_strings
from infrastructure.openai import llm_message_query
from infrastructure.zendesk import get_zen_tickets, get_zen_comments


def suggest_solution_wrapper(query, callback, zendesk_user, zendesk_token, logging=None):
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

        ticket_context = asyncio.run(get_tickets(keywords, zendesk_user, zendesk_token))

        messages = [
            ('system', 'You are helpful agent who can provide helpful solutions to questions about Octopus Deploy.'),
            ('system',
             'The supplied conversations related to the same topics as the question being asked.'),
            *[('user', "Message: ###\n" + context.replace("{", "{{").replace("}", "}}") + "\n###") for context in
              ticket_context],
            ('user', "Question: {input}"),
            ('user', "Answer:")]

        context = {"input": query}
        chat_response = llm_message_query(messages, context)

        return callback(query, keywords, chat_response)

    return suggest_solution


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

    return [await get_comments(str(ticket[0]), zendesk_user, zendesk_token) for ticket in
            sorted_by_second[:max_tickets]]


async def get_comments(ticket_id, zendesk_user, zendesk_token):
    comments = await get_zen_comments(ticket_id, zendesk_user, zendesk_token)
    return "\n".join(
        [minify_strings(anonymize_message(sanitize_message(comment['body']))) for comment in comments['comments'] if
         comment['public']])
