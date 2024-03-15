def build_deployments_and_releases_prompt(step_by_step=False):
    """
    Build a message prompt for the LLM that instructs it to parse the Octopus HCL context.
    :param step_by_step: True if the LLM should display its reasoning step by step before the answer. False for concise answers.
    :return: The messages to pass to the llm.
    """
    messages = [
        ("system",
         "You understand Terraform modules and JSON blobs defining Octopus Deploy resources. "
         + "The HCL provides details on projects, environments, channels, and tenants. "
         + "The JSON provides details on deployments and releases. "
         + "You must link the deployments and releases in the JSON to the projects, environments, channels, and tenants in the HCL."),
        ("user", "{input}"),
        # https://help.openai.com/en/articles/6654000-best-practices-for-prompt-engineering-with-the-openai-api
        # Put instructions at the beginning of the prompt and use ### or """ to separate the instruction and context
        ("user", "JSON: ###\n{json}\n###"),
        ("user", "HCL: ###\n{hcl}\n###")]

    # This message instructs the LLM to display its reasoning step by step before the answer. It can be a useful
    # debugging tool. It doesn't always work though, but you can rerun the query and try again.
    if step_by_step:
        messages.insert(0, ("system", "You are a verbose and helpful agent."))
        messages.append(("user", "Let's think step by step."))
    else:
        messages.insert(0, (
            "system", "You are a concise and helpful agent."))

    return messages
