def build_test_prompt():
    """
    Build a basic message prompt for the LLM.
    :return: The messages to pass to the llm.
    """
    messages = [
        ("system", "You are a helpful agent"),
        ("user", "{input}")]

    return messages
