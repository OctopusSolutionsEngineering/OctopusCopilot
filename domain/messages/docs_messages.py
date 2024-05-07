from domain.context.octopus_context import max_chars
from domain.validation.argument_validation import ensure_string


def docs_prompt(context):
    """
    Builds the messages used when answering a question from documentation
    :param context: The raw documentation context
    :return: The LLM messages
    """

    ensure_string(context, 'context must be a string (docs_prompt).')

    return [('system', "You must prioritise the details in the Documentation context when answering the question."),
            ('user', 'Documentation: ###\n' + context[:max_chars].replace("{", "{{").replace("}", "}}\n###")),
            ('user', "Question: {input}"),
            ('user', "Answer:")]
