import asyncio
from domain.messages.spinnaker_messages import spinnaker_migration_prompt
from functools import reduce

from domain.response.copilot_response import CopilotResponse
from domain.tools.debug import get_params_message
from infrastructure.llm import llm_message_query, AZURE_GENERAL_QUERY_SMALL_LLM


# This is a very simple tool, passing through the original prompt to the LLM.
# We expose this tool to be able to control things like selecting the LLM.
def spinnaker_callback(github_user, log_query):
    def spinnaker_callback_implementation(original_query, keywords):

            debug_text = get_params_message(
                github_user,
                True,
                spinnaker_callback_implementation.__name__,
                original_query=original_query,
                keywords=keywords,
            )

            context = {"input": original_query}

            messages = [
                ("user", "Question: {input}"),
                ("user", "Answer:"),
            ]

            chat_response = [llm_message_query(messages, context, log_query, purpose=AZURE_GENERAL_QUERY_SMALL_LLM)]

            chat_response.extend(debug_text)

            return CopilotResponse("\n\n".join(chat_response))

    return spinnaker_callback_implementation

