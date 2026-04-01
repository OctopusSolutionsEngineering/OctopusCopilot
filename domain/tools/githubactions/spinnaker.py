import hashlib
import os

from domain.exceptions.none_on_exception import none_on_exception
from domain.response.copilot_response import CopilotResponse
from domain.tools.debug import get_params_message
from infrastructure.llm import llm_message_query, AZURE_ANTHROPIC_GENERAL_QUERY_SMALL_LLM
from infrastructure.terraform_context import load_terraform_cache, cache_terraform


# This is a very simple tool, passing through the original prompt to the LLM.
# We expose this tool to be able to control things like selecting the LLM.
def spinnaker_callback(github_user, connection_string, log_query):
    def spinnaker_callback_implementation(original_query):
        debug_text = get_params_message(
            github_user,
            True,
            spinnaker_callback_implementation.__name__,
            original_query=original_query,
        )

        context = {"input": original_query}

        # The LLM used to convert Spinnaker pipelines
        purpose=AZURE_ANTHROPIC_GENERAL_QUERY_SMALL_LLM

        # Cache based on prompt and LLM
        query_sha = hashlib.sha256((original_query + "\n" + purpose).encode("utf-8")).hexdigest()

        cached_result = load_cached_configuration(query_sha, connection_string)

        if cached_result is not None:
            return CopilotResponse(cached_result)

        messages = [
            ("user", "Question: {input}"),
            ("user", "Answer:"),
        ]

        response = llm_message_query(
            messages, context, log_query, purpose=purpose
        )

        none_on_exception(
            lambda: cache_terraform(query_sha, response, connection_string)
        )

        chat_response = [response]

        chat_response.extend(debug_text)

        return CopilotResponse("\n\n".join(chat_response))

    return spinnaker_callback_implementation


def load_cached_configuration(cache_sha, connection_string):
    """Load a previously cached Terraform configuration, or return None if caching is disabled."""
    if (
        os.getenv("AISERVICES_CACHE_DISABLED_SPINNAKER_CONVERT", "false").casefold()
        == "true"
    ):
        return None
    return load_terraform_cache(cache_sha, connection_string)
