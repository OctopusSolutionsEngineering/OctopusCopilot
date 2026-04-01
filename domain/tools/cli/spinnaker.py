from infrastructure.llm import llm_message_query, AZURE_GENERAL_QUERY_SMALL_LLM, AZURE_ANTHROPIC_GENERAL_QUERY_SMALL_LLM


def spinnaker_cli_callback(logging):
    def spinnaker_callback_implementation(original_query):

        context = {"input": original_query}

        messages = [
            ("user", "Question: {input}"),
            ("user", "Answer:"),
        ]

        chat_response = llm_message_query(messages, context, logging, purpose=AZURE_GENERAL_QUERY_SMALL_LLM)
        #chat_response = llm_message_query(messages, context, logging, purpose=AZURE_ANTHROPIC_GENERAL_QUERY_SMALL_LLM)

        return chat_response

    return spinnaker_callback_implementation
