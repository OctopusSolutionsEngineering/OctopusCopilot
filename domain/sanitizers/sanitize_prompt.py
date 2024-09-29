def sanitize_prompt(prompt):
    """
    Help examples include @octopus-ai-app in the prompt. If this text is copied verbatim,
    this function will remove it.
    :param prompt: The prompt
    :return: The prompt with the agent name removed
    """
    if not prompt:
        return ""

    if prompt.startswith("@octopus-ai-app"):
        return prompt.replace("@octopus-ai-app", "", 1)

    return prompt
