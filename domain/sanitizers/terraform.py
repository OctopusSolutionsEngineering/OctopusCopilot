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


def sanitize_slugs(config):
    """
    Claude would often try to create slugs with asterisks, like:
    slug = "deploy-*****-kustomize"

    This is not valid. We just remove these slugs.
    """

    return re.sub(r'slug\s*=\s*"[^"]*?\*+[^"]*?"', "", config)


def sanitize_primary_package(config):
    """
    Claude would often generate half of the primary_package block, but not the whole thing.
    We can fix this up by replacing the incomplete block with a complete one. It is not perfect - we
    don't know the feed that the package is coming from - but at least it makes the terraform configuration valid.
    """

    return re.sub(
        r'^\s*", id = null, package_id = "(.*?)", properties = { SelectionMode = "immediate" } }',
        r'      primary_package = { acquisition_location = "Server", feed_id = "data.octopusdeploy_feeds.feed_octopus_server__built_in_.feeds[0].id", id = null, package_id = "\1", properties = { SelectionMode = "immediate" } }',
        config,
        flags=re.MULTILINE,
    )


def sanitize_account_type(config):
    """
    Sanitize Kubernetes config by fixing the account type capitalisation. This is because GTP4 kept trying to set the
    account_type of an account data resource to "AzureOidc"
    """

    return re.sub(
        r'account_type\s*=\s*"AzureOidc"', 'account_type = "AzureOIDC"', config
    )


def replace_passwords(config):
    """
    Replace any passwords data with a placeholder value.
    """

    return re.sub(
        r'password\s*=\s*".*?"',
        'password = "CHANGE ME"',
        config,
    )


def replace_resource_names_with_digit(config):
    """
    LLMs seemed to struggle with the rule to build resources that start with a character rather than a digit.
    """

    fixed_config = config
    for match in re.finditer(r'(resource|data)\s+".*?"\s+"([0-9].*?)"', config):
        fixed_config = fixed_config.replace(match.group(2), f"_{match.group(2)}")

    return fixed_config


def replace_certificate_data(config):
    """
    Replace any certificate data with a placeholder value.
    """

    return re.sub(
        r'certificate_data\s*=\s*".*?"',
        'certificate_data = "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"',
        config,
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
        r"release_retention_policy\s*{\s*quantity_to_keep\s*=\s*(\d+),?\s*unit\s*=\s*\"([^\"]+)\"\s*}",
        r"release_retention_policy {\n"
        r" quantity_to_keep = \1\n"
        r' unit = "\2"\n'
        "}",
        config,
    )


def fix_single_line_lifecycle_phase(config):
    """
    The LLM kept insisting on using a single line phase block in the lifecycle. This is not valid HCL2 syntax.
    """

    return re.sub(
        r"phase { automatic_deployment_targets\s*=\s*(.*?)\s*,?\s*optional_deployment_targets\s*=\s*(.*?)\s*,?\s*name\s*=\s*\"(.*?)\"\s*,?\s*is_optional_phase\s*=\s*(.*?)\s*,?\s*minimum_environments_before_promotion\s*=\s*(.*?)\s*}",
        r"phase {\n"
        r" automatic_deployment_targets = \1\n"
        r" optional_deployment_targets = \2\n"
        r' name = "\3"\n'
        r" is_optional_phase = \4\n"
        r" minimum_environments_before_promotion = \5\n"
        "}",
        config,
    )


def fix_single_line_variable(config):
    """
    The LLM kept insisting on using a single line for variables
    """

    return re.sub(
        r'variable\s*"(.*?)"\s*{\s*type\s*=\s*(.*?)\s*nullable\s*=\s*(.*?)\s*sensitive\s*=\s*(.*?)\s*description\s*=\s*"(.*?)"\s*default\s*=\s*"(.*?)"\s*}',
        r'variable "\1" {\n'
        r"type = \2\n"
        r"nullable = \3\n"
        r"sensitive = \4\n"
        r'description = "\5"\n'
        r'default = "\6"\n'
        r"}",
        config,
    )


def fix_empty_teams(config):
    """
    The LLM kept insisting on using adding "Octopus.Action.Manual.ResponsibleTeamIds" = ""
    """

    return re.sub(
        r'"Octopus.Action.Manual.ResponsibleTeamIds"\s*=\s*""',
        "",
        config,
    )


def fix_bad_feed_data(config):
    """
    The LLM kept building feed blocks with unmatched curly quotes
    """

    return re.sub(
        r'data "octopusdeploy_feeds" "(.*?)" \{([^{}]*?)\n\s*}\n}',
        r'data "octopusdeploy_feeds" "\1" {\2\n}',
        config,
        flags=re.DOTALL,
    )


def fix_bad_maven_feed_resource(config):
    """
    The LLM kept building feed blocks with unmatched curly quotes
    """

    return re.sub(
        r'resource "octopusdeploy_maven_feed" "(.*?)" \{(.*?)\n\s*lifecycle \{(.*?)\n}',
        r'resource "octopusdeploy_maven_feed" "\1" {\2\n  lifecycle {\3\n  }\n}',
        config,
        flags=re.DOTALL,
    )


def fix_single_line_tentacle_retention_policy(config):
    """
    The LLM kept insisting on using a single line tentacle_retention_policy block. This is not valid HCL2 syntax.
    """

    return re.sub(
        r"tentacle_retention_policy\s*{\s*quantity_to_keep\s*=\s*(\d+),?\s*unit\s*=\s*\"([^\"]+)\"\s*}",
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


def fix_double_comma(config):
    """
    The LLM kept trying to define a block like
    parameters      = [{ default_sensitive_value = null,, display_settings = { "Octopus.ControlType" = "MultiLineText" }, help_text = "The array to sort", id = "a1b2c3d4-e5f6-7890-abcd-ef1234567890", label = "Array", name = "Array" }]
    """

    return re.sub(
        r"default_sensitive_value\s*=\s*null,,",
        "default_sensitive_value = null,",
        config,
        flags=re.DOTALL,
    )


def add_space_id_variable(config):
    """
    The LLM kept forgetting to include the space_id variable in the generated terraform config. This is required for the terraform provider to work.
    """

    if 'variable "octopus_space_id"' not in config:
        space_id_variable = 'variable "octopus_space_id" {\n  type = string\n}\n\n'
        return space_id_variable + config

    return config


def fix_variable_type(config):
    """
    The LLM kept trying to define a variable type like type = "string". This is not valid HCL2 syntax. It should be type = string without the quotes.
    """

    return re.sub(
        r'type\s*=\s*"string"',
        "type = string",
        config,
        flags=re.DOTALL,
    )


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


def fix_empty_strings(config):
    """
    The default value must be a null value, not an empty string
    """

    properties = ["help_text", "default_value", "label"]
    for prop in properties:
        config = re.sub(rf'\s*{prop}\s*=\s*""', "", config)
    return config


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

    filename_exists = any(
        resource_line
        for resource_line in lines
        if resource_line.strip().startswith('"Octopus.Action.Script.ScriptFileName"')
    )

    # Add a default file name if one does not exist
    if not filename_exists:
        source_index = next(
            (
                i
                for i, v in enumerate(lines)
                if v.strip().startswith('"Octopus.Action.Script.ScriptSource"')
            ),
            -1,
        )
        if source_index != -1:
            lines.insert(
                source_index + 1,
                '  "Octopus.Action.Script.ScriptFileName" = "MyScript.ps1"',
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
                    output.extend(resource_lines)
        else:
            output.append(line)

    # Our assumptions about the indents of brackets failed, so do no processing
    if in_resource:
        return config

    return "\n".join(output)
