import re


def sanitize_kuberenetes_yaml_step_config(config):
    """
    Sanitize Kubernetes config by removing invalid masks information. This is because GTP4 kept introducing placeholders
    into K8s sample steps.
    """

    yaml_configs = re.findall(
        r'"Octopus\.Action\.KubernetesContainers\.CustomResourceYaml"\s*=\s*.*',
        config,
    )

    fixed_config = config
    for yaml_config in yaml_configs:

        # replace string that look like
        # name: *****
        # with
        # name: placeholder
        line = re.sub(r':\s*(")\*+(.*?")', r": \1placeholder\2", yaml_config)
        line = re.sub(r":\s*\*+", r": placeholder", line)

        fixed_config = fixed_config.replace(yaml_config, line)

    return fixed_config


def sanitize_name_attributes(config):
    """
    Sanitize the names assigned to resources.
    """

    yaml_configs = re.findall(
        r"name\s*=\s*.*",
        config,
    )

    fixed_config = config
    for yaml_config in yaml_configs:

        # replace string that look like
        # name: "Blue/Green deployment"
        # with
        # name: "Blue_Green deployment"
        line = re.sub(r'[^a-zA-Z0-9.,:_#"\'= \-${}\[\]]', r"_", yaml_config)

        fixed_config = fixed_config.replace(yaml_config, line)

    return fixed_config


def sanitize_account_type(config):
    """
    Sanitize Kubernetes config by fixing the account type capitalisation. This is because GTP4 kept trying to set the
    account_type of an account data resource to "AzureOidc"
    """

    return re.sub(
        r'account_type\s*=\s*"AzureOidc"', 'account_type = "AzureOIDC"', config
    )


def fix_single_line_lifecycle(config):
    """
    The LLM kept insisting on using a single line lifecycle block. This is not valid HCL2 syntax.
    """

    match = re.match(
        r"lifecycle { ignore_changes = \[([^]]+)] prevent_destroy = true }", config
    )
    if match:
        # If we get a single line lifecycle block, just replace it with a multi-line one
        return (
            "lifecycle {\n"
            f"  ignore_changes = [{match.group(1)}]\n"
            "  prevent_destroy = true\n"
            "}"
        )

    return config


def fix_single_line_retention_policy(config):
    """
    The LLM kept insisting on using a single line release_retention_policy block. This is not valid HCL2 syntax.
    """

    return re.sub(
        r"release_retention_policy\s*{\s*quantity_to_keep\s*=\s*(\d+)\s*unit\s*=\s*\"([^\"]+)\"\s*}",
        r"release_retention_policy {\n"
        r" quantity_to_keep = \1\n"
        r' unit = "\2"\n'
        "}",
        config,
    )


def fix_single_line_tentacle_retention_policy(config):
    """
    The LLM kept insisting on using a single line tentacle_retention_policy block. This is not valid HCL2 syntax.
    """

    return re.sub(
        r"tentacle_retention_policy\s*{\s*quantity_to_keep\s*=\s*(\d+)\s*unit\s*=\s*\"([^\"]+)\"\s*}",
        r"tentacle_retention_policy {\n"
        r" quantity_to_keep = \1\n"
        r' unit = "\2"\n'
        "}",
        config,
    )


def fix_bad_logic_characters(config):
    """
    The LLM kept on building expressions with underscores in place of brackets or other characters.
    This was always in the count attributes, which can be complex for stateless terraform configuration.
    So we need to fix this up.
    """

    return re.sub(
        r"count\s*=\s*(.*?), \[](_|\))(_|\)) (_|!)= 0 (_|\?) 0 : 1",
        r"count = \1, [])) != 0 ? 0 : 1",
        config,
    )


def fix_lifecycle(config):
    """
    We don't need to use lifecycle blocks in the generated terraform config.
    """

    return re.sub(
        r"lifecycle\s*{.*?}",
        "",
        config,
    )


def fix_properties_block(config):
    """
    The LLM kept trying to define a block like properties {}
    """

    return re.sub(r"properties\s*\{.*?}", "", config, flags=re.DOTALL)


def fix_execution_properties_block(config):
    """
    The LLM kept trying to define a block like execution_properties {}
    """

    return re.sub(r"execution_properties\s*\{.*?}", "", config, flags=re.DOTALL)


def remove_duplicate_definitions(config):
    """
    The LLM kept trying to return duplicate definitions for resources, data, variables, and outputs.
    This is not foolproof - we would need to parse the HCL2 syntax properly to do that.
    We assume the Terraform config is indented correctly and that each block ends with a closing bracket on the start of the line.
    If the indents are incorrect and there are duplicated blocks, this will return invalid Terraform config.
    However, in that scenario, we had invalid Terraform config to begin with, so we have lost nothing by trying to sanitize it.
    :param config: The generated Terraform config to sanitize.
    :return: The sanitized Terraform config with duplicate definitions removed.
    """
    block_types = [
        "resource",
        "data",
        "variable",
        "output",
    ]

    if not config:
        return ""

    fixed_config = config

    splits = config.splitlines()

    blocks = []

    # Step 1 - Find the blocks in the config
    current_block = None
    for line in splits:
        # The start of a block is appended to the current block
        if any(line.startswith(block_type) for block_type in block_types):
            current_block = []

        if current_block is not None:
            # If we have started a new block, append the line to it
            current_block.append(line)

        # If we reach the end of a block, append it to the blocks list
        if line == "}":
            if current_block is not None:
                blocks.append(current_block)
            current_block = None

    # Step 2 - Remove duplicate blocks
    for i in range(len(blocks)):
        for j in range(i + 1, len(blocks)):
            if blocks[i] == blocks[j]:
                duplicate_block = "\n".join(blocks[i])
                while fixed_config.count(duplicate_block) > 1:
                    # Remove the duplicate block
                    fixed_config = fixed_config.replace(duplicate_block, "", 1)

    return fixed_config.strip()
