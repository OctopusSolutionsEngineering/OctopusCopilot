# Semaphore to limit the number of concurrent requests to GitHub
import asyncio

import aiohttp

from domain.exceptions.request_failed import StoryBlokRequestFailed
from domain.sanitizers.sanitize_markup import html_to_text
from domain.sanitizers.url_sanitizer import quote_safe
from domain.sanitizers.uuid_sanitizer import is_uuid
from domain.validation.argument_validation import ensure_string_not_empty

storyblok_sem = asyncio.Semaphore(10)


async def search_storyblok_stories(storyblok_token, search_term):
    """
    Async function to get stories with a search term
    https://www.storyblok.com/faq/does-storyblok-offer-a-search
    """
    ensure_string_not_empty(
        storyblok_token, "owner must be a non-empty string (storyblok_token)."
    )
    ensure_string_not_empty(
        search_term, "repo must be a non-empty string (storyblok_token)."
    )

    api = f"https://api.storyblok.com/v2/cdn/stories?token={quote_safe(storyblok_token)}&search_term={quote_safe(search_term)}"

    async with storyblok_sem:
        async with aiohttp.ClientSession() as session:
            async with session.get(str(api)) as response:
                if response.status != 200:
                    body = await response.text()
                    raise StoryBlokRequestFailed(f"Request failed with " + body)
                return await response.json()


def get_fields_with_text(story, keywords=None):
    """
    We don't know the structure of the stories, so loop through all fields and find the text.
    """
    text = ""

    if isinstance(story, list):
        for item in story:
            text += get_fields_with_text(item, keywords)

    if isinstance(story, dict):
        for keys in story.keys():
            text += get_fields_with_text(story[keys], keywords)

    if isinstance(story, str):
        plain_text = html_to_text(story)
        # So many fields are just UUIDs, so we want to ignore those
        uuid = is_uuid(plain_text)
        unique_text = plain_text not in text
        if unique_text and not uuid:
            text += plain_text + "\n"

    return text
