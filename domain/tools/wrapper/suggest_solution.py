import asyncio

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
            [('user', "Message: ###\n" + context + "\n###") for context in ticket_context],
            ('user', "Question: {input}"),
            ('user', "Answer:")]

        context = {"input": query}
        chat_response = [llm_message_query(messages, context)]

        return callback(query, keywords, chat_response)

    return suggest_solution


async def get_tickets(keywords, zendesk_user, zendesk_token, max_tickets=10):
    tickets = await get_zen_tickets(keywords, zendesk_user, zendesk_token)
    return [await get_comments(ticket['id'], zendesk_user, zendesk_token) for ticket in
            tickets['results'][:max_tickets]]


async def get_comments(ticket_id, zendesk_user, zendesk_token):
    comments = await get_zen_comments(ticket_id, zendesk_user, zendesk_token)
    return "\n".join([comment['body'] for comment in comments['comments']])
