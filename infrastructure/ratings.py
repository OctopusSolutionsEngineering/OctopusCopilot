import asyncio
import json

import aiohttp

from domain.exceptions.feedback import FeedbackRequestFailed
from domain.logging.app_logging import configure_logging
from domain.validation.argument_validation import ensure_string_not_empty
from infrastructure.octopus import logging_wrapper

logger = configure_logging(__name__)

# Semaphore to limit the number of concurrent requests to the feedback service
sem = asyncio.Semaphore(10)


@logging_wrapper
async def create_feedback_async(
    api_key, access_token, octopus_url, prompt, thumbs_up, comment
):
    ensure_string_not_empty(
        prompt, "prompt must be a non-empty string (create_feedback_async)."
    )

    ensure_string_not_empty(
        octopus_url,
        "octopus_url must be a non-empty string (create_feedback_async).",
    )

    headers = {
        "Authorization": "Bearer " + access_token,
        "X-Octopus-Server": octopus_url,
    }

    feedback = {
        "data": {
            "type": "feedback",
            "attributes": {
                "prompt": prompt,
                "comment": comment,
                "thumbsUp": thumbs_up,
            },
        }
    }

    api = "https://feedback-fsevb4dmecepamh0.a02.azurefd.net/api/feedback"

    async with sem:
        async with aiohttp.ClientSession(headers=headers) as session:
            async with session.post(
                api,
                data=json.dumps(feedback),
            ) as response:
                if response.status != 200:
                    body = await response.text()
                    raise FeedbackRequestFailed(f"Request to {api} failed with {body}")
                return await response.text()
