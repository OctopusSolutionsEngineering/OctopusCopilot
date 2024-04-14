from domain.context.octopus_context import max_chars


def docs_prompt(context):
    """
    Builds the messages used when answering a question from documentation
    :param context: The raw documentation context
    :return: The LLM messages
    """
    return [('system', "You must prioritise the details in the Documentation context when answering the question."),
            ('user', 'Documentation: ###\n' + context[:max_chars].replace("{", "{{").replace("}", "}}\n###")),
            ('user', "{input}")]
