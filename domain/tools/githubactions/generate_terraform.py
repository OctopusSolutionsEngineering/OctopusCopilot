from domain.response.copilot_response import CopilotResponse
from infrastructure.openai import llm_message_query


def generate_terraform_callback_wrapper():
    def generate_terraform_callback_implementation(query, messages):
        context = {"input": query}
        chat_response = [
            llm_message_query(messages, context, deployment="gpt-4.1-mini")
        ]

        # The LLM has been finetuned to respond only with the terraform. We wrap it up in a code block
        # to allow it to be displayed in the UI.
        return CopilotResponse("```\n" + "\n\n".join(chat_response) + "\n```")

    return generate_terraform_callback_implementation
