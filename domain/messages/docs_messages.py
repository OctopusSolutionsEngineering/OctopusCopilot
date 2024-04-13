from domain.context.octopus_context import max_chars


def docs_prompt(context):
    """
    Builds the messages used when answering a question from documentation
    :param context: The raw documentation context
    :return: The LLM messages
    """
    return [('user', context[:max_chars].replace("{", "{{").replace("}", "}}")),
            ('user', "{input}")]
