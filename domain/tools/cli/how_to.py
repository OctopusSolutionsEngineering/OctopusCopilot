from domain.context.github_docs import get_docs_context
from domain.messages.docs_messages import docs_prompt
from infrastructure.github import search_repo
from infrastructure.llm import llm_message_query


def how_to_cli_callback(github_token, logging):
    def how_to_callback_implementation(original_query, keywords):
        results = search_repo("OctopusDeploy/docs", "markdown", keywords, github_token)
        text = get_docs_context(results)
        messages = docs_prompt(text)

        context = {"input": original_query}

        chat_response = llm_message_query(messages, context, logging)

        return chat_response

    return how_to_callback_implementation
