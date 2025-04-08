from domain.context.github_docs import get_docs_context
from domain.exceptions.none_on_exception import none_on_exception
from domain.github.generate_jwt import generate_jwt_from_env
from domain.messages.docs_messages import docs_prompt
from domain.response.copilot_response import CopilotResponse
from domain.tools.debug import get_params_message
from infrastructure.github import search_repo
from infrastructure.openai import llm_message_query


def get_github_content(github_token, keywords):
    # Try using the GitHub token first
    if github_token:
        results = none_on_exception(
            lambda: search_repo(
                "OctopusDeploy/docs", "markdown", keywords, github_token
            )
        )

        if results:
            return results

    # Then authenticate with the GitHub App
    jwt = generate_jwt_from_env()
    if jwt:
        results = none_on_exception(
            lambda: search_repo("OctopusDeploy/docs", "markdown", keywords, jwt)
        )

        if results:
            return results

    # Then do an unauthenticated search
    return none_on_exception(
        lambda: search_repo("OctopusDeploy/docs", "markdown", keywords)
    )


def how_to_callback(github_token, github_user, log_query):
    def how_to_callback_implementation(original_query, keywords):
        debug_text = get_params_message(
            github_user,
            True,
            how_to_callback_implementation.__name__,
            original_query=original_query,
            keywords=keywords,
        )

        results = get_github_content(github_token, keywords)
        text = get_docs_context(results)
        messages = docs_prompt(text)

        context = {"input": original_query}

        chat_response = [llm_message_query(messages, context, log_query)]

        chat_response.extend(debug_text)

        return CopilotResponse("\n\n".join(chat_response))

    return how_to_callback_implementation
