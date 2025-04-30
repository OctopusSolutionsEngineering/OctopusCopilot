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
        line = re.sub(r'[^a-zA-Z0-9.,_#"\'= \-{}\[\]]', r"_", yaml_config)

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

    if (
        config
        == "lifecycle { ignore_changes = [sensitive_value] prevent_destroy = true }"
    ):
        return "lifecycle {\n  ignore_changes = [sensitive_value]\n  prevent_destroy = true\n}"

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
