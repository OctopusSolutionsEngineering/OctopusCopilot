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
    return await asyncio.gather(
        *[
            combine_ticket_comments(str(ticket["id"]), zendesk_user, zendesk_token)
            for ticket in tickets
        ]
    )


async def combine_ticket_comments(ticket_id, zendesk_user, zendesk_token):
    comments = await get_zen_comments(ticket_id, zendesk_user, zendesk_token)
    combined_comments = [comments.get("subject", "")] + [
        minify_strings(replace_space_codes(comment.get("body", "")))
        for comment in comments.get("comments", [])
        if comment.get("public", False)
    ]

    # If we need to strip PII from the comments, we can do it here
    sanitized_contents = [
        anonymize_message(sanitize_message(contents))
        for contents in combined_comments
        if contents
    ]

    return "\n".join(sanitized_contents)


async def get_tickets(is_admin, keywords, ignore_tickets, zendesk_user, zendesk_token):
    # This is too important to leave to the caller to decide.
    # TODO: Remove this if tickets can be exposed to all users
    if not is_admin:
        return []

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
            if ignore_tickets and str(ticket["id"]) in ignore_tickets:
                continue

            if not ticket_ids.get(ticket["id"]):
                ticket_ids[ticket["id"]] = {"count": 1, "ticket": ticket}
            else:
                ticket_ids[ticket["id"]]["count"] += 1

    sorted_by_second = sorted(
        ticket_ids.items(), key=lambda tup: tup[1]["count"], reverse=True
    )

    tickets = map(lambda x: x[1]["ticket"], sorted_by_second)
    return list(filter(lambda x: x.get("type") == "incident", tickets))


async def get_no_tickets():
    """
    Getting tickets is limited to admin users at this point. It is nice to be able to switch off
    any interaction with the ZenDesk API without having to change the code. So for this we have
    an empty function that can be used in place of get_tickets
    :return: An empty array.
    """
    return []
