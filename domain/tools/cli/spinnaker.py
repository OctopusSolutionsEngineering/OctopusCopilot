from infrastructure.llm import llm_message_query


def spinnaker_cli_callback(logging):
    def spinnaker_callback_implementation(original_query, spinnaker_json):

        context = {"input": original_query}

        messages = [
            ("user", "Question: {input}"),
            ("user", "Answer:"),
        ]

        chat_response = llm_message_query(messages, context, logging)

        return chat_response

    return spinnaker_callback_implementation

