def build_plain_text_prompt():
    """
    Build a message prompt for the LLM that instructs it to parse plain text
    :return: The messages to pass to the llm.
    """
    messages = [
        ("system", "You understand Octopus Deploy log output. "
         + "You are a concise and helpful agent. "
         + "Answer the question given the supplied deployment log output. "
         + "You must assume that the supplied deployment log and all items in it directly relate to the space, project, environment, tenant, and channel from the question."),
        ("user", "{input}"),
        # https://help.openai.com/en/articles/6654000-best-practices-for-prompt-engineering-with-the-openai-api
        # Put instructions at the beginning of the prompt and use ### or """ to separate the instruction and context
        ("user", "Deployment Log: ###\n{context}\n###")]

    return messages
