from domain.response.copilot_response import CopilotResponse
from infrastructure.openai import llm_message_query


def generate_terraform_callback_wrapper():
    def generate_terraform_callback_implementation(query, messages):
        context = {"input": query}
        chat_response = [
            llm_message_query(
                messages, context, deployment="gpt-4-1-mini-terraform-finetuned"
            )
        ]

        return CopilotResponse("\n\n".join(chat_response))

    return generate_terraform_callback_implementation
