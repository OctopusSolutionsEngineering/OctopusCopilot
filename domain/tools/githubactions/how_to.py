from domain.context.github_docs import get_docs_context
from domain.exceptions.request_failed import GitHubRequestFailed
from domain.messages.docs_messages import docs_prompt
from domain.response.copilot_response import CopilotResponse
from infrastructure.github import search_repo
from infrastructure.openai import llm_message_query


def how_to_callback(github_token, log_query):
    def how_to_callback_implementation(original_query, keywords):
        try:
            results = search_repo("OctopusDeploy/docs", "markdown", keywords, github_token)
        except GitHubRequestFailed as e:
            # Fallback to an unauthenticated search
            results = search_repo("OctopusDeploy/docs", "markdown", keywords)

        text = get_docs_context(results)
        messages = docs_prompt(text)

        context = {"input": original_query}

        chat_response = llm_message_query(messages, context, log_query)

        return CopilotResponse(chat_response)

    return how_to_callback_implementation
