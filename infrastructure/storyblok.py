# Semaphore to limit the number of concurrent requests to GitHub
import asyncio

import aiohttp

from domain.exceptions.request_failed import StoryBlokRequestFailed
from domain.sanitizers.url_sanitizer import quote_safe
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
    We don't know the structure of the stories, so loop through all fields and find anything that looks like
    long form text.
    """
    text = ""
    for keys in story.keys():
        if isinstance(story[keys], str) and len(story[keys]) > 250:
            # only get the text content if the keywords are in the text
            if not keywords or any(keyword in story[keys] for keyword in keywords):
                text += story[keys] + "\n"
        if isinstance(story[keys], dict):
            text += get_fields_with_text(story[keys]) + "\n"
    return text
