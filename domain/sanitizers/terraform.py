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

    match = re.match(
        r"release_retention_policy\s*{\s*quantity_to_keep\s*=\s*(\d+)\s*unit\s*=\s*\"([^\"]+)\"\s*}",
        config,
    )
    if match:
        # If we get a single line lifecycle block, just replace it with a multi-line one
        return (
            "release_retention_policy {\n"
            f" quantity_to_keep = {match.group(1)}\n"
            f' unit = "{match.group(2)}"\n'
            "}"
        )

    return config


def fix_account_type(config):
    """
    Fix up invalid account_type values.
    """
    valid_types = [
        "AmazonWebServicesAccount",
        "AmazonWebServicesRoleAccount",
        "AmazonWebServicesOidcAccount",
        "AzureServicePrincipal",
        "AzureOIDC",
        "AzureSubscription",
        "GenericOidcAccount",
        "None",
        "SshKeyPair",
        "Token",
        "UsernamePassword",
    ]
    match = re.match(r'account_type\s*=\s*"([^"]+)"', config)

    # If we get an invalid account type, just remove it
    if match and match.group(1) not in valid_types:
        return config.replace(match.group(1), "")

    return config


def fix_duplicate_default_lifecycle(config):
    """
    The LLM kept trying to return multiple data lookups for the default lifecycle,
    so rename any duplicates.
    """

    # If we get a duplicate default lifecycle block, just remove it
    if (
        config.count('data "octopusdeploy_lifecycles" "lifecycle_default_lifecycle"')
        <= 1
    ):
        return config

    count = 0
    splits = config.splitlines()

    for i in range(len(splits)):
        line = splits[i]
        if line == 'data "octopusdeploy_lifecycles" "lifecycle_default_lifecycle" {':
            count += 1
            if count > 1:
                splits[i] = (
                    f'data "octopusdeploy_lifecycles" "lifecycle_default_lifecycle{count}" {{'
                )

    return "\n".join(splits)
