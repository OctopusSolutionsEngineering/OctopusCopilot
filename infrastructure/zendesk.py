import asyncio

import aiohttp

from domain.b64.b64_encoder import encode_string_b64
from domain.exceptions.request_failed import ZenDeskRequestFailed
from domain.sanitizers.sanitize_logs import anonymize_message, sanitize_message
from domain.sanitizers.url_sanitizer import quote_safe
from domain.transformers.minify_strings import minify_strings, replace_space_codes
from domain.validation.argument_validation import (
    ensure_string_not_empty,
    ensure_not_falsy,
)

# Semaphore to limit the number of concurrent requests to GitHub
zendesk_sem = asyncio.Semaphore(10)


def get_zen_authorization_header(zen_user, zen_token):
    return {
        "Authorization": f"Basic {encode_string_b64(f'{zen_user}/token:{zen_token}')}",
    }


async def get_zen_tickets(keywords, zen_user, zen_token):
    """
    Async function to search for tickets in Zendesk.
    https://developer.zendesk.com/api-reference/ticketing/ticket-management/search/
    """
    ensure_not_falsy(keywords, "keywords must be a list (get_zen_tickets).")
    ensure_string_not_empty(
        zen_user, "zen_user must be a non-empty string (get_zen_tickets)."
    )
    ensure_string_not_empty(
        zen_token, "zen_token must be a non-empty string (get_zen_tickets)."
    )

    keywords_list = quote_safe(" ".join(keywords))
    api = f"https://octopus.zendesk.com/api/v2/search?query={keywords_list}&sort_by=RELEVANCE&sort_order=DESC"

    async with zendesk_sem:
        async with aiohttp.ClientSession(
            headers=get_zen_authorization_header(zen_user, zen_token)
        ) as session:
            async with session.get(str(api)) as response:
                if response.status != 200:
                    body = await response.text()
                    raise ZenDeskRequestFailed(f"Request failed with " + body)
                return await response.json()


async def get_zen_comments(ticket_id, zen_user, zen_token):
    """
    Async function to get the comments associated with a ticket.
    https://developer.zendesk.com/api-reference/ticketing/tickets/ticket_comments/
    """
    ensure_string_not_empty(
        ticket_id, "ticket_id must be a non-empty string (get_zen_comments)."
    )
    ensure_string_not_empty(
        zen_user, "zen_user must be a non-empty string (get_zen_comments)."
    )
    ensure_string_not_empty(
        zen_token, "zen_token must be a non-empty string (get_zen_comments)."
    )

    api = f"https://octopus.zendesk.com/api/v2/tickets/{quote_safe(ticket_id)}/comments"

    async with zendesk_sem:
        async with aiohttp.ClientSession(
            headers=get_zen_authorization_header(zen_user, zen_token)
        ) as session:
            async with session.get(str(api)) as response:
                if response.status != 200:
                    body = await response.text()
                    raise ZenDeskRequestFailed(f"Request failed with " + body)
                return await response.json()


async def get_tickets_comments(tickets, zendesk_user, zendesk_token):
    return [
        await combine_ticket_comments(str(ticket["id"]), zendesk_user, zendesk_token)
        for ticket in tickets
    ]


async def combine_ticket_comments(ticket_id, zendesk_user, zendesk_token):
    comments = await get_zen_comments(ticket_id, zendesk_user, zendesk_token)
    combined_comments = [comments.get("subject", "")] + [
        minify_strings(replace_space_codes(comment.get("body", "")))
        for comment in comments.get("comments", [])
        if comment.get("public", False)
    ]

    # If we need to strip PII from the comments, we can do it here
    sanitized_contents = [
        anonymize_message(sanitize_message(contents)) for contents in combined_comments
    ]

    return "\n".join(sanitized_contents)
