from domain.context.github_docs import get_docs_context
from domain.defaults.defaults import get_default_argument
from domain.exceptions.request_failed import GitHubRequestFailed
from domain.messages.docs_messages import docs_prompt
from domain.response.copilot_response import CopilotResponse
from infrastructure.github import search_repo
from infrastructure.openai import llm_message_query


def how_to_callback(github_token, github_user, log_query):
    def how_to_callback_implementation(original_query, keywords):
        try:
            results = search_repo("OctopusDeploy/docs", "markdown", keywords, github_token)
        except GitHubRequestFailed as e:
            # Fallback to an unauthenticated search
            results = search_repo("OctopusDeploy/docs", "markdown", keywords)

        text = get_docs_context(results)
        messages = docs_prompt(text)

        context = {"input": original_query}

        chat_response = [llm_message_query(messages, context, log_query)]

        # Debug mode shows the entities extracted from the query
        debug_text = []
        debug = get_default_argument(github_user, "False", "Debug")
        if debug.casefold() == "true":
            debug_text.append(how_to_callback_implementation.__name__
                              + " was called with the following parameters:"
                              + f"\nOriginal Query: {original_query}"
                              + f"\nKeywords: {keywords}")

        chat_response.extend(debug_text)

        return CopilotResponse("\n\n".join(chat_response))

    return how_to_callback_implementation
