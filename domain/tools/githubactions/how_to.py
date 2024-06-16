from domain.context.github_docs import get_docs_context
from domain.exceptions.request_failed import GitHubRequestFailed
from domain.messages.docs_messages import docs_prompt
from domain.response.copilot_response import CopilotResponse
from domain.tools.debug import get_params_message
from infrastructure.github import search_repo
from infrastructure.openai import llm_message_query


def how_to_callback(github_token, github_user, log_query):
    def how_to_callback_implementation(original_query, keywords):
        debug_text = get_params_message(github_user, True, how_to_callback_implementation.__name__,
                                        original_query=original_query,
                                        keywords=keywords)

        try:
            results = search_repo("OctopusDeploy/docs", "markdown", keywords, github_token)
        except GitHubRequestFailed as e:
            # Fallback to an unauthenticated search
            results = search_repo("OctopusDeploy/docs", "markdown", keywords)

        text = get_docs_context(results)
        messages = docs_prompt(text)

        context = {"input": original_query}

        chat_response = [llm_message_query(messages, context, log_query)]

        chat_response.extend(debug_text)

        return CopilotResponse("\n\n".join(chat_response))

    return how_to_callback_implementation
