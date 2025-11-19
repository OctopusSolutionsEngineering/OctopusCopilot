import asyncio
from functools import reduce

from domain.context.github_docs import get_docs_context
from domain.exceptions.none_on_exception import (
    none_on_exception_async,
)
from domain.github.generate_jwt import generate_jwt_from_env
from domain.messages.docs_messages import docs_prompt
from domain.response.copilot_response import CopilotResponse
from domain.tools.debug import get_params_message
from infrastructure.github import search_repo_async
from infrastructure.llm import llm_message_query

docs_repo = "OctopusDeploy/docs"
blog_repo = "OctopusDeploy/blog"


async def get_github_content(github_token, keywords, repo):
    # Try using the GitHub token first
    if github_token:
        results = await none_on_exception_async(
            lambda: search_repo_async(repo, "markdown", keywords, github_token)
        )

        if results:
            return results

    # Then authenticate with the GitHub App
    jwt = generate_jwt_from_env()
    if jwt:
        results = await none_on_exception_async(
            lambda: search_repo_async(repo, "markdown", keywords, jwt)
        )

        if results:
            return results

    # Then do an unauthenticated search
    return await none_on_exception_async(
        lambda: search_repo_async(repo, "markdown", keywords)
    )


def how_to_callback(github_token, github_user, log_query):
    def how_to_callback_implementation(original_query, keywords):
        async def inner_function():
            debug_text = get_params_message(
                github_user,
                True,
                how_to_callback_implementation.__name__,
                original_query=original_query,
                keywords=keywords,
            )

            # Get the content from the docs and blogs in parallel
            results = await asyncio.gather(
                get_github_content(github_token, keywords, docs_repo),
                get_github_content(github_token, keywords, blog_repo),
            )

            text = reduce(
                lambda acc, item: acc + "\n\n" + get_docs_context(item), results, ""
            )

            messages = docs_prompt(text)

            context = {"input": original_query}

            chat_response = [llm_message_query(messages, context, log_query)]

            chat_response.extend(debug_text)

            return CopilotResponse("\n\n".join(chat_response))

        # https://github.com/pytest-dev/pytest-asyncio/issues/658#issuecomment-1817927350
        # Should just have one asyncio.run()
        return asyncio.run(inner_function())

    return how_to_callback_implementation
