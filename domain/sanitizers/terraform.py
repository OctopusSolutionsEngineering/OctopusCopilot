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


def fix_empty_properties_block(config):
    """
    The LLM kept trying to define empty properties blocks like properties {}
    """

    return re.sub(r"properties\s*=\s*\{\s*}", "", config, flags=re.DOTALL)


def fix_empty_execution_properties_block(config):
    """
    The LLM kept trying to define empty properties blocks like execution_properties {}
    """

    return re.sub(r"execution_properties\s*=\s*\{\s*}", "", config, flags=re.DOTALL)


def fix_execution_properties_block(config):
    """
    The LLM kept trying to define a block like execution_properties {}
    """

    return re.sub(r"execution_properties\s*\{.*?}", "", config, flags=re.DOTALL)


def fix_default_value(config):
    """
    The default value must be a null value, not an empty string
    """

    return re.sub(r'\s*default_value\s*=\s*""', "", config)


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


def sanitize_inline_script(lines):
    # There are no file names for inline packages
    lines = list(
        resource_line
        for resource_line in lines
        if not resource_line.strip().startswith(
            '"Octopus.Action.Script.ScriptFileName"'
        )
    )

    resource_combined = "\n".join(lines)

    # There is no primary package for inline scripts
    resource_combined = re.sub(
        r"primary_package\s*=\s*\{.*?}",
        "",
        resource_combined,
        flags=re.DOTALL,
    )

    return resource_combined


def sanitize_package_script(lines):
    # There is no inline script or syntax for package scripts
    lines = list(
        resource_line
        for resource_line in lines
        if not resource_line.strip().startswith('"Octopus.Action.Script.ScriptBody"')
        and not resource_line.strip().startswith('"Octopus.Action.Script.Syntax"')
    )

    resource_combined = "\n".join(lines)
    return resource_combined


def fix_script_source(config):
    """
    LLMs would frequently mix up inline and package scripts. This function looks at the script source and strips out
    any unsupported settings. This kind of sanitization is not ideal - proper HCL2 parsing would be much better than
    assuming correctly indented HCL2 code. But this is better than nothing.
    """

    if not config:
        return ""

    # A quick out if there were no script steps
    if "Octopus.Action.Script.ScriptSource" not in config:
        return config

    splits = config.splitlines()

    output = []

    in_resource = False
    resource_lines = []

    for line in splits:
        if not in_resource and line.startswith("resource "):
            # We entered a resource block
            in_resource = True
            resource_lines = [line]
        elif in_resource:
            resource_lines.append(line)

            if line == "}":
                in_resource = False

                # Detect if this is a script resource
                is_script = any(
                    resource_line
                    for resource_line in resource_lines
                    if resource_line.strip().startswith(
                        '"Octopus.Action.Script.ScriptSource"'
                    )
                )

                if is_script:
                    script_type = next(
                        resource_line.split("=").pop().strip()
                        for resource_line in resource_lines
                        if resource_line.strip().startswith(
                            '"Octopus.Action.Script.ScriptSource"'
                        )
                    )

                    if script_type == '"Inline"':
                        output.append(sanitize_inline_script(resource_lines))

                    elif script_type == '"Package"':
                        output.append(sanitize_package_script(resource_lines))
                    else:
                        # Unknown script type, just output the resource as-is
                        output.extend(resource_lines)
        else:
            output.append(line)

    # Our assumptions about the indents of brackets failed, so do no processing
    if in_resource:
        return config

    return "\n".join(output)
