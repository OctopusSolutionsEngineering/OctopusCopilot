import os
import hashlib
import re
import uuid

from lxml.html.diff import fixup_ins_del_tags

MOCK_CERTIFICATE_DATA = (
    "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"
)
MOCK_CERTIFICATE_PASSWORD = "Password01!"
# Matches the start of a heredoc, capturing the string that marks the end of the heredoc
HEREDOC_START_REGEX = re.compile(r"<<-?\s*([A-Za-z_][A-Za-z0-9_]*)\s*$")
OCTOPUS_RESOURCE_PREFIX = 'resource "octopusdeploy_'
OCTOPUS_DATA_PREFIX = 'data "octopusdeploy_'


def sanitize_kubernetes_yaml_step_config(config):
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
        # replace masks that follow part of a value, like
        # name: ledger-*****
        # with
        # name: ledger-placeholder
        line = re.sub(r"(?<=[\w-])\*{3,}", "placeholder", line)

        fixed_config = fixed_config.replace(yaml_config, line)

    return fixed_config


def sanitize_name_attributes(config):
    """
    Sanitize the names assigned to resources.
    """

    # \b requires "name" to start at a word boundary, so "username", "hostname",
    # "servicename" etc. are excluded — only a standalone "name" attribute matches.
    # Observed failure: without the boundary, this regex also matched inside
    # "username = ..." lines and stripped backslashes from Windows-style
    # DOMAIN\user account usernames (e.g. "SVC\\telemetry" became "SVC__telemetry"),
    # corrupting a value the prompt supplied verbatim.
    yaml_configs = re.findall(
        r"\bname\s*=\s*.*",
        config,
    )

    fixed_config = config
    for yaml_config in yaml_configs:

        # replace string that look like
        # name: "Blue/Green deployment"
        # with
        # name: "Blue_Green deployment"
        #
        # Brackets and ampersands are left alone. The Octopus API accepts them in
        # the name of a project, environment, lifecycle, channel, project group,
        # runbook and worker pool, so replacing them corrupts a name the prompt
        # asked for. Forward and back slashes are still replaced, because the API
        # rejects a name containing a slash.
        # Letters outside ASCII (Équipe, Café, emoji) are accepted by the API too, so only
        # the ASCII characters that are not in the allowed set are replaced.
        # An escaped quote (\") is kept as it is: the backslash is the HCL escape, not part of the name, and
        # replacing it leaves a bare quote that ends the string early.
        line = re.sub(
            r'\\"|[\x00-\x1f!%*+/;<>?@\\^`|~\x7f]',
            lambda match: match.group(0) if match.group(0) == '\\"' else "_",
            yaml_config,
        )

        # Octopus trims the name, so leading and trailing spaces make the provider report an inconsistent result:
        # Provider produced inconsistent result after apply ... .name was cty.StringVal("  My Name  "), but now ...
        quoted = re.match(r'^(\bname\s*=\s*")(.*?)("\s*)$', line)
        if quoted and quoted.group(2) != quoted.group(2).strip():
            line = quoted.group(1) + quoted.group(2).strip() + quoted.group(3)

        fixed_config = fixed_config.replace(yaml_config, line)

    return fixed_config


def fix_empty_namespace(config):
    """
    Fix this issue:

    When applying changes to
    octopusdeploy_process_step.process_step_deploy_job_to_dev_delete_job_manifest[0],
    provider "provider[\"registry.opentofu.org/octopusdeploy/octopusdeploy\"]"
    produced an unexpected new value: .execution_properties: element
    "Octopus.Action.KubernetesContainers.Namespace" has vanished.
    """

    return re.sub(
        r'"Octopus.Action.KubernetesContainers.Namespace"\s*=\s*""', "", config
    )


def fix_unescaped_variables(config):
    """
    Fix issues when strings contain unescaped variables, like ${not a terraform variable}.
    Ignore strings that start with "${", as these are intentional in the generated terraform.
    :param config:
    :return:
    """

    def replace_unescaped_variables(line):
        if re.match(r'".*?"\s*=\s*"[^$].*?\$\{.*?"', line) is not None:
            return re.sub(r"\${", r"$${", line)
        return line

    if not config:
        return config

    return "\n".join(
        [replace_unescaped_variables(line) for line in config.splitlines() if line]
    )


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

    replacement = r'      primary_package = { acquisition_location = "Server", feed_id = "data.octopusdeploy_feeds.feed_octopus_server__built_in_.feeds[0].id", id = null, package_id = "\1", properties = { SelectionMode = "immediate" } }'

    config = re.sub(
        r'^\s*", id = null, package_id = "(.*?)", properties = { SelectionMode = "immediate" } }',
        replacement,
        config,
        flags=re.MULTILINE,
    )

    # The same truncated block, with each attribute on its own line
    return re.sub(
        r'^[ \t]*"[ \t]*\n\s*id\s*=\s*null\s*\n\s*package_id\s*=\s*"(.*?)"\s*\n\s*properties\s*=\s*{ SelectionMode = "immediate" }\s*\n\s*}',
        replacement,
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
    Replace any passwords with a placeholder value.
    """

    return re.sub(
        r'password\s*=\s*".*?"',
        'password = "CHANGE ME"',
        config,
    )


def replace_access_and_secret_keys(config):
    """
    Replace any secret_key properties with a placeholder value.
    access_key is an AWS access key ID, not a secret, so it is left as the
    literal value the prompt supplied. Observed failure: this function used
    to also replace access_key, which meant a correctly-named AWS account
    still ended up with a "CHANGE ME" access_key instead of the prompt's
    literal value.
    """

    return re.sub(
        r'(secret_key)\s*=\s*".*?"',
        r'\1 = "CHANGE ME"',
        config,
    )


def replace_invalid_azure_guids(config):
    """
    The provider validates application_id, subscription_id and tenant_id on Azure service principal and
    OpenID Connect accounts as UUIDs. Prompts like `subscription ID "not-a-guid"` or `tenant ID "12345"`
    make the plan fail, so any literal value that is not a UUID is replaced with the all-zero placeholder.
    Only literal values inside those two resource types are touched; interpolations are left alone.
    """

    placeholder = "00000000-0000-0000-0000-000000000000"
    uuid_pattern = re.compile(r"^[0-9a-fA-F]{8}-(?:[0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$")
    attribute_pattern = re.compile(r'^(\s*(?:application_id|subscription_id|tenant_id)\s*=\s*)"([^"\n]*)"', re.MULTILINE)
    header_pattern = re.compile(r'resource\s+"octopusdeploy_azure_(?:service_principal|openid_connect)"\s+"[^"]*"\s*\{')

    def fix_block(block):
        def fix_attribute(match):
            value = match.group(2)
            if "$" in value or uuid_pattern.match(value):
                return match.group(0)
            return f'{match.group(1)}"{placeholder}"'

        return attribute_pattern.sub(fix_attribute, block)

    result = []
    position = 0
    for header in header_pattern.finditer(config):
        if header.start() < position:
            continue
        depth = 1
        end = header.end()
        while end < len(config) and depth > 0:
            if config[end] == "{":
                depth += 1
            elif config[end] == "}":
                depth -= 1
            end += 1
        result.append(config[position:header.start()])
        result.append(fix_block(config[header.start():end]))
        position = end
    result.append(config[position:])
    return "".join(result)


def add_missing_project_group_resources(config):
    """
    The project group lookup pattern is a data source plus a count-guarded resource, with the project referencing
    `octopusdeploy_project_group.<label>[0].id` as the fallback. LLMs sometimes emit the data source and the
    reference but drop the resource, which fails the plan with "Reference to undeclared resource". The missing
    resource is recreated from the `project_group_<label>_name` variable default.
    """

    referenced = set(re.findall(r"octopusdeploy_project_group\.(\w+)\[0\]", config))
    declared = set(re.findall(r'resource\s+"octopusdeploy_project_group"\s+"(\w+)"', config))

    additions = []
    for label in sorted(referenced - declared):
        variable_match = re.search(
            rf'variable\s+"{re.escape(label)}_name"\s*\{{[^}}]*?default\s*=\s*"([^"]*)"',
            config,
            re.DOTALL,
        )
        if not variable_match or f'data "octopusdeploy_project_groups" "{label}"' not in config:
            continue
        additions.append(
            f'resource "octopusdeploy_project_group" "{label}" {{\n'
            f'  count = "${{length(data.octopusdeploy_project_groups.{label}.project_groups) != 0 ? 0 : 1}}"\n'
            f'  name  = "${{var.{label}_name}}"\n'
            f"}}\n"
        )

    if not additions:
        return config

    return config.rstrip("\n") + "\n" + "\n".join(additions)


def remove_postcondition_from_created_project_groups(config):
    """
    Only the "Default Project Group" lookup may carry a postcondition, because it must already exist. A lookup
    for a group the configuration creates (a matching octopusdeploy_project_group resource exists) would fail
    the plan with "Failed to resolve a project group" on a space that does not have the group yet, so the
    lifecycle block is removed from that data source.
    """

    declared = set(re.findall(r'resource\s+"octopusdeploy_project_group"\s+"(\w+)"', config))
    result = config

    for label in declared:
        header = re.search(rf'data\s+"octopusdeploy_project_groups"\s+"{re.escape(label)}"\s*\{{', result)
        if not header:
            continue

        depth = 1
        block_end = header.end()
        while block_end < len(result) and depth > 0:
            if result[block_end] == "{":
                depth += 1
            elif result[block_end] == "}":
                depth -= 1
            block_end += 1
        if depth > 0:
            continue

        block = result[header.start():block_end]
        lifecycle = re.search(r"\n[ \t]*lifecycle\s*\{", block)
        if not lifecycle:
            continue

        depth = 1
        lifecycle_end = lifecycle.end()
        while lifecycle_end < len(block) and depth > 0:
            if block[lifecycle_end] == "{":
                depth += 1
            elif block[lifecycle_end] == "}":
                depth -= 1
            lifecycle_end += 1
        if depth > 0:
            continue

        block = block[:lifecycle.start()] + block[lifecycle_end:]
        result = result[:header.start()] + block + result[block_end:]

    return result


def _find_closing_brace(text, position):
    """
    Returns the index just past the brace that closes a block whose opening brace precedes `position`, or None if
    the block is unterminated.
    """

    depth = 1
    while position < len(text) and depth > 0:
        if text[position] == "{":
            depth += 1
        elif text[position] == "}":
            depth -= 1
        position += 1
    return position if depth == 0 else None


def _remove_lifecycle_block(block):
    lifecycle = re.search(r"\n[ \t]*lifecycle\s*\{", block)
    if not lifecycle:
        return block

    lifecycle_end = _find_closing_brace(block, lifecycle.end())
    if lifecycle_end is None:
        return block

    return block[:lifecycle.start()] + block[lifecycle_end:]


def _resolve_project_group_name(block, config):
    """
    Returns the (name, variable_name) of a project group data source's partial_name. variable_name is set when the
    name is a reference to a variable.
    """

    partial_name = re.search(r'partial_name\s*=\s*"([^"]*)"', block)
    if not partial_name:
        return None, None

    variable_reference = re.fullmatch(r"\$\{var\.(\w+)\}", partial_name.group(1))
    if not variable_reference:
        return partial_name.group(1), None

    variable_name = variable_reference.group(1)
    variable_match = re.search(
        rf'variable\s+"{re.escape(variable_name)}"\s*\{{[^}}]*?default\s*=\s*"([^"]*)"',
        config,
        re.DOTALL,
    )
    return (variable_match.group(1) if variable_match else None), variable_name


def convert_prompt_named_project_group_lookup(config):
    """
    Only the "Default Project Group" lookup may be a lookup-only data source with a postcondition. When the LLM
    emits that form for a group the prompt named, the group does not exist in a new space and the plan fails
    with "Failed to resolve a project group". Such lookups are converted to the create pattern: the postcondition
    is removed, a count-guarded resource is added, and a direct `project_groups[0].id` reference becomes the
    lookup-or-create expression.
    """

    result = config

    for header in list(re.finditer(r'data\s+"octopusdeploy_project_groups"\s+"(\w+)"\s*\{', config)):
        label = header.group(1)
        start = result.find(header.group(0))
        if start == -1:
            continue

        end = _find_closing_brace(result, start + len(header.group(0)))
        if end is None:
            continue

        block = result[start:end]
        if "postcondition" not in block:
            continue

        name, variable_name = _resolve_project_group_name(block, result)
        if not name or name.strip().casefold() == "default project group":
            continue

        result = result[:start] + _remove_lifecycle_block(block) + result[end:]

        lookup = f"data.octopusdeploy_project_groups.{label}.project_groups"
        if not re.search(rf'resource\s+"octopusdeploy_project_group"\s+"{re.escape(label)}"', result):
            name_expression = f"${{var.{variable_name}}}" if variable_name else name
            result = (
                result.rstrip("\n")
                + f'\nresource "octopusdeploy_project_group" "{label}" {{\n'
                + f'  count = "${{length({lookup}) != 0 ? 0 : 1}}"\n'
                + f'  name  = "{name_expression}"\n'
                + "}\n"
            )

        result = result.replace(
            f'"${{{lookup}[0].id}}"',
            f'"${{length({lookup}) != 0 ? {lookup}[0].id : octopusdeploy_project_group.{label}[0].id}}"',
        )

    return result


def replace_secrets(config):
    """
    Replace the value of any property called "secret" with a GUID. Properties like "secret_key" or
    "client_secret" are left alone, as is any text that happens to contain the word "secret".
    """

    return re.sub(
        r'(?<![\w.])secret\s*=\s*".*?"',
        lambda match: f'secret = "{uuid.uuid4()}"',
        config,
    )


def replace_token(config):
    """
    Replace any tokens with a placeholder value.
    """

    return re.sub(
        r'token\s*=\s*".*?"',
        'token = "CHANGEME"',
        config,
    )


def replace_json_key(config):
    """
    The Google Cloud account json_key is a sensitive value. The OPA policy rejects the whole plan when a sensitive
    value is not a placeholder, so a service account key supplied in the prompt is replaced.
    """

    return re.sub(
        r'(?<![\w.])json_key\s*=\s*"(?:[^"\\]|\\.)*"',
        'json_key = "Change Me!"',
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
        f'certificate_data = "${MOCK_CERTIFICATE_DATA}"',
        config,
    )


def replace_private_key_data(config):
    """
    Replace any private key file and passphrase data with placeholder values.
    """

    config = re.sub(
        r'private_key_file\s*=\s*".*?"',
        f'private_key_file = "{MOCK_CERTIFICATE_DATA}"',
        config,
    )
    return re.sub(
        r'private_key_passphrase\s*=\s*".*?"',
        f'private_key_passphrase = "{MOCK_CERTIFICATE_PASSWORD}"',
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


def fix_single_line_lifecycle2(config):
    """
    The LLM kept insisting generating a one line lifecycle block
    """

    return re.sub(
        r"lifecycle\s*\{\s*postcondition\s*\{\n([^{}]+)\n}}",
        r"lifecycle {\n postcondition {\n\1\n}\n}",
        config,
    )


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


def fix_use_guided_infrastructure(config):
    """
    The LLM kept insisting on using adding use_guided_infrastructure = false
    """

    return re.sub(
        r"use_guided_infrastructure\s*=\s*(true|false)",
        "",
        config,
    )


def fix_bad_feed_data(config):
    """
    The LLM kept building feed blocks with unmatched curly quotes
    """

    return re.sub(
        r'data\s*"octopusdeploy_feeds"\s*"(.*?)"\s*\{([^{}]*?)\n\s*}\n}',
        r'data "octopusdeploy_feeds" "\1" {\2\n}',
        config,
    )


def trim_descriptions(config):
    """
    Octopus will trim whitespace around descriptions, leading to errors like:
    When applying changes to octopusdeploy_project.project_my_tenanted_lambda[0],
    provider "provider[\"registry.opentofu.org/octopusdeploy/octopusdeploy\"]"
    produced an unexpected new value: .description: was cty.StringVal("This
    project provides an example AWS Lambda deployment using an AWS OIDC Account,
    and SBOM scanning to an AWS Lambda function.\n\n"), but now
    cty.StringVal("This project provides an example AWS Lambda deployment using
    an AWS OIDC Account, and SBOM scanning to an AWS Lambda function.").
    """

    return re.sub(
        r'(description|default)\s*=\s*"(?:\\n)*(.*?)(?:\\n)*"',
        r'\1 = "\2"',
        config,
        flags=re.DOTALL,
    )


def fix_bad_maven_feed_resource(config):
    """
    The LLM kept building feed blocks with unmatched curly quotes
    """

    return re.sub(
        r'resource "octopusdeploy_(.*?)_feed" "(.*?)" \{(.*?)\n\s*lifecycle \{([^{}]*?)\n}',
        r'resource "octopusdeploy_\1_feed" "\2" {\3\n  lifecycle {\4\n  }\n}',
        config,
        flags=re.DOTALL,
    )


def fix_maven_feed_acquisition_options(config):
    """
    Maven feeds do not support the NotAcquired package acquisition location. The LLM copies the
    Docker feed value, and the provider returns:
    When applying changes to octopusdeploy_maven_feed.feed_octopus_maven_feed[0],
    produced an unexpected new value: .package_acquisition_location_options[0]:
    was cty.StringVal("ExecutionTarget"), but now cty.StringVal("Server").
    """

    lines = config.split("\n")
    in_maven_feed = False
    depth = 0
    for i, line in enumerate(lines):
        if not in_maven_feed and re.match(
            r'\s*resource\s+"octopusdeploy_maven_feed"\s+"[^"]*"\s*\{', line
        ):
            in_maven_feed = True
            depth = 0
        if in_maven_feed:
            lines[i] = re.sub(
                r"^(\s*package_acquisition_location_options\s*=\s*)\[.*?\]",
                r'\1["Server", "ExecutionTarget"]',
                line,
            )
            depth += line.count("{") - line.count("}")
            if depth <= 0:
                in_maven_feed = False
    return "\n".join(lines)


CHECK_TARGETS_AVAILABLE_TEMPLATE_URL = (
    "https://library.octopus.com/step-templates/81444e7f-d77a-47db-b287-0f1ab5793880"
)


def fix_check_targets_available_template_url(config):
    """
    The LLM confuses the Check Targets Available community step template with the Block Release
    Progression template (78a182b3-5369-4e13-9292-b7f991295ad1). The wrong template does not declare
    the CheckTargets.Octopus.Role parameter, which then fails with:
    .parameters: element "CheckTargets.Octopus.Role" has vanished.
    """

    return re.sub(
        r'(data\s+"octopusdeploy_community_step_template"\s+"[^"]*check_targets_available"\s*\{[^}]*?website\s*=\s*")[^"]*(")',
        r"\g<1>" + CHECK_TARGETS_AVAILABLE_TEMPLATE_URL + r"\g<2>",
        config,
        flags=re.DOTALL,
    )


CHECK_SMTP_SERVER_CONFIGURED_TEMPLATE_URL = (
    "https://library.octopus.com/step-templates/ad8126be-37af-4297-b46e-fce02ba3987a"
)


def fix_check_smtp_server_configured_template_url(config):
    """
    The LLM sometimes invents a GUID (e.g. ad8126be-3f3b-4b3b-8b3b-3b3b3b3b3b3b) for the Check SMTP Server
    Configured community step template website. The lookup then returns no steps, community_action_template_id
    evaluates to null, and the plan fails with:
    Error: Missing Configuration for Required Attribute ... community_action_template_id
    """

    return re.sub(
        r'(data\s+"octopusdeploy_community_step_template"\s+"[^"]*check_smtp_server_configured"\s*\{[^}]*?website\s*=\s*")[^"]*(")',
        r"\g<1>" + CHECK_SMTP_SERVER_CONFIGURED_TEMPLATE_URL + r"\g<2>",
        config,
        flags=re.DOTALL,
    )


VALID_GUIDED_FAILURE_MODES = ["EnvironmentDefault", "On", "Off"]


def fix_default_guided_failure_mode(config):
    """
    The project default_guided_failure_mode must be EnvironmentDefault, On or Off. The LLM sometimes returns
    "Default", which fails with:
    Error converting value "Default" to type
    'Octopus.Server.MessageContracts.Features.Projects.GuidedFailureMode'. Path 'DefaultGuidedFailureMode'
    """

    def replace_mode(match):
        if match.group(2) in VALID_GUIDED_FAILURE_MODES:
            return match.group(0)
        return f'{match.group(1)}"EnvironmentDefault"'

    return re.sub(
        r'(default_guided_failure_mode\s*=\s*)"([^"]*)"',
        replace_mode,
        config,
    )


def add_missing_project_description_default(config):
    """
    The LLM sometimes writes the project description into the description attribute of the
    project_<name>_description variable and omits the default, which fails the plan with:
    Error: No value for required variable ... "project_<name>_description" is not set, and has no default value.
    Reuse the description text as the default.
    """

    def add_default(match):
        body = match.group(2)
        if re.search(r"^\s*default\s*=", body, re.MULTILINE):
            return match.group(0)
        description = re.search(
            r'^\s*description\s*=\s*"((?:[^"\\]|\\.)*)"', body, re.MULTILINE
        )
        default = description.group(1) if description else "Project description"
        return f'{match.group(1)}{body}\n  default     = "{default}"\n}}'

    return re.sub(
        r'(variable\s+"project_[A-Za-z0-9_-]+_description"\s*\{)(.*?)\n\}',
        add_default,
        config,
        flags=re.DOTALL,
    )


def fix_underscore_quoted_strings(config):
    """
    The LLM sometimes surrounds a quoted string in a comparison with underscores, like
    item.name == _"Gold_", which is invalid HCL2:
    Error: Invalid 'for' expression
    """

    return re.sub(
        r'(==|!=)\s*_"([^"\n]*?)_"',
        r'\1 "\2"',
        config,
    )


def fix_community_step_template_count(config):
    """
    A community step template is only created when the space does not already have the step template, so the
    count must test the space's octopusdeploy_step_template data source. The LLM sometimes tests the community
    step template data source instead. That is non-empty whenever the template exists in the community library,
    which sets the count to 0 and breaks the [0] reference in the step:
    Error: Invalid index ... octopusdeploy_community_step_template.communitysteptemplate_x is empty tuple
    """

    def fix_count(match):
        suffix = match.group(2)
        if not re.search(
            rf'data\s+"octopusdeploy_step_template"\s+"steptemplate_{re.escape(suffix)}"',
            config,
        ):
            return match.group(0)

        return (
            f"{match.group(1)}"
            f'count = "${{data.octopusdeploy_step_template.steptemplate_{suffix}.step_template != null ? 0 : 1}}"'
        )

    return re.sub(
        r'(resource\s+"octopusdeploy_community_step_template"\s+"communitysteptemplate_(\w+)"\s*\{\s*\n\s*)count\s*=\s*"[^\n]*"',
        fix_count,
        config,
    )


BARE_INTERPOLATION_REGEX = re.compile(r"(?<!\$)\$\{([A-Za-z_][A-Za-z0-9_]*)\}")
# An Octopus variable name written as ${DNS.Zone}: Terraform references never start with a capital letter
OCTOPUS_VARIABLE_INTERPOLATION_REGEX = re.compile(
    r"(?<!\$)\$\{([A-Z][A-Za-z0-9_]*(?:\.[A-Za-z0-9_-]+)+)\}"
)
# A CloudFormation pseudo parameter written as ${AWS::AccountId} in an inline template
CLOUDFORMATION_PSEUDO_PARAMETER_REGEX = re.compile(r"(?<!\$)\$\{(AWS::[A-Za-z]+)\}")


def escape_bare_interpolations(config):
    """
    A Terraform template held in a string, like the Terraform step's template or a project variable, sometimes
    contains ${TF_VAR_region}. A bare identifier is not a valid Terraform reference, so the whole file fails with:
    Error: Invalid reference ... A reference to a resource type must be followed by at least one attribute access
    Escape it as $${TF_VAR_region}. A bare identifier is left alone where it is the iterator of a for expression.
    A capitalised dotted name like ${DNS.Zone} is an Octopus variable (fails with: Reference to undeclared resource),
    so it becomes the Octostache template #{DNS.Zone}.
    """

    def escape(match):
        name = match.group(1)
        if re.search(rf"\bfor\s+(?:\w+\s*,\s*)?{re.escape(name)}\s+in\b", config):
            return match.group(0)
        return "$" + match.group(0)

    config = OCTOPUS_VARIABLE_INTERPOLATION_REGEX.sub(
        lambda match: "#{" + match.group(1) + "}", config
    )
    config = CLOUDFORMATION_PSEUDO_PARAMETER_REGEX.sub(r"$${\1}", config)
    return BARE_INTERPOLATION_REGEX.sub(escape, config)


def fix_created_worker_pool_fallback(config):
    """
    When the prompt asks for a new worker pool, the LLM sometimes falls back to the Default Worker Pool data source
    when the lookup finds nothing. A fresh space has no pool called Default Worker Pool, so the plan fails with:
    Error: Invalid index ... data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools is empty list
    The pool the configuration creates is the correct fallback.
    """

    def replace_fallback(match):
        name = match.group(2)
        if not re.search(
            rf'resource\s+"octopusdeploy_static_worker_pool"\s+"{re.escape(name)}"', config
        ):
            return match.group(0)
        return f"{match.group(1)}octopusdeploy_static_worker_pool.{name}[0].id}}"

    return re.sub(
        r"(\$\{length\(data\.octopusdeploy_worker_pools\.(\w+)\.worker_pools\)\s*!=\s*0\s*\?\s*"
        r"data\.octopusdeploy_worker_pools\.\2\.worker_pools\[0\]\.id\s*:\s*)"
        r"data\.octopusdeploy_worker_pools\.(?!\2\.)\w+\.worker_pools\[0\]\.id\}",
        replace_fallback,
        config,
    )


HOSTED_UBUNTU_WORKER_POOL_DATA = """data "octopusdeploy_worker_pools" "workerpool_hosted_ubuntu" {
  ids          = null
  partial_name = "Hosted Ubuntu"
  skip         = 0
  take         = 1
  lifecycle {
    postcondition {
      error_message = "Failed to resolve a worker pool called \\"Hosted Ubuntu\\". This resource must exist in the space before this Terraform configuration is applied."
      condition     = length(self.worker_pools) != 0
    }
  }
}
"""


def fix_lookup_worker_pool_default_fallback(config):
    """
    When the prompt asks to look up an existing worker pool that does not exist, the LLM falls back to the Default
    Worker Pool data source. A fresh space has no pool called Default Worker Pool, so the plan fails with:
    Error: Invalid index ... data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools is empty list
    Hosted Ubuntu is the pool that always exists, so use it as the fallback for lookup-only pools.
    """

    hosted_ubuntu = "workerpool_hosted_ubuntu"

    def replace_fallback(match):
        name = match.group(2)
        # Hosted Ubuntu with a Default Worker Pool fallback is the pattern from the system prompt. Replacing the
        # fallback would leave both branches indexing the same lookup.
        if name == hosted_ubuntu or re.search(
            rf'resource\s+"octopusdeploy_\w*worker_pool"\s+"{re.escape(name)}"', config
        ):
            return match.group(0)
        return f"{match.group(1)}data.octopusdeploy_worker_pools.{hosted_ubuntu}.worker_pools[0].id}}"

    result = re.sub(
        r"(\$\{length\(data\.octopusdeploy_worker_pools\.(\w+)\.worker_pools\)\s*!=\s*0\s*\?\s*"
        r"data\.octopusdeploy_worker_pools\.\2\.worker_pools\[0\]\.id\s*:\s*)"
        r"data\.octopusdeploy_worker_pools\.workerpool_default_worker_pool\.worker_pools\[0\]\.id\}",
        replace_fallback,
        config,
    )

    if result != config and not re.search(
        rf'data\s+"octopusdeploy_worker_pools"\s+"{hosted_ubuntu}"', result
    ):
        result = result.rstrip("\n") + "\n" + HOSTED_UBUNTU_WORKER_POOL_DATA

    return result


BARE_DATA_REFERENCE_REGEX = re.compile(
    r"\$\{data\.(octopusdeploy_\w+)\.(\w+)\.(\w+)\[0\]\.id\}"
)


def fix_bare_data_lookup_reference(config):
    """
    The LLM declares a lookup data source plus a counted resource that creates the thing when the lookup finds
    nothing, then references only the data source, like feed_id = "${data.octopusdeploy_feeds.x.feeds[0].id}".
    In a fresh space the lookup is empty and the plan fails with:
    Error: Invalid index ... data.octopusdeploy_feeds.x.feeds is empty list of object
    Where a counted resource with the same label exists, use the lookup-or-create form.
    """

    def replace(match):
        data_type, label, collection = match.groups()
        resource = re.search(
            rf'resource\s+"(octopusdeploy_\w+)"\s+"{re.escape(label)}"\s*\{{\s*\n\s*count\b',
            config,
        )
        if not resource:
            return match.group(0)
        return (
            f"${{length(data.{data_type}.{label}.{collection}) != 0 ? "
            f"data.{data_type}.{label}.{collection}[0].id : "
            f"{resource.group(1)}.{label}[0].id}}"
        )

    return BARE_DATA_REFERENCE_REGEX.sub(replace, config)


def remove_worker_pool_from_target_steps(config):
    """
    A step that runs on deployment targets cannot also have a worker pool or a worker container image. Octopus flips
    RunOnServer and the apply fails with: Provider produced inconsistent result after apply ...
    "Octopus.Action.RunOnServer": was cty.StringVal("false"), but now cty.StringVal("true")
    or is rejected outright: A step can't have a worker container image when the execution location is a
    deployment target (when property Octopus.Action.RunOnServer set to false)
    """

    if not config or '"Octopus.Action.RunOnServer"' not in config:
        return config

    def process_resource(resource_lines):
        if not resource_lines[0].startswith('resource "octopusdeploy_process_step"'):
            return resource_lines

        block = "\n".join(resource_lines)
        if not re.search(r'"Octopus\.Action\.RunOnServer"\s*=\s*"false"', block):
            return resource_lines

        lines = [
            line
            for line in resource_lines
            if not re.match(r"^\s*worker_pool_(variable|id)\s*=", line)
        ]

        return remove_balanced_attribute(
            "\n".join(lines), CONTAINER_START_REGEX
        ).split("\n")

    return process_resource_blocks(config, process_resource)


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


def fix_single_line_connectivity_policy(config):
    """
    The LLM kept insisting on using a single line tentacle_retention_policy block. This is not valid HCL2 syntax.
    """

    return re.sub(
        r'connectivity_policy\s*{\s*allow_deployments_to_no_targets\s*=\s*(.*?)\s*exclude_unhealthy_targets\s*=\s*(.*?)\s*skip_machine_behavior\s*=\s*"(.*?)"\s*target_roles\s*=\s*(.*?)\s*}',
        r"connectivity_policy {\n"
        r" allow_deployments_to_no_targets = \1\n"
        r" exclude_unhealthy_targets = \2\n"
        r' skip_machine_behavior = "\3"\n'
        r" target_roles = \4\n"
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


VALID_VARIABLE_TYPES = [
    "AmazonWebServicesAccount",
    "AzureAccount",
    "GoogleCloudAccount",
    "UsernamePasswordAccount",
    "Certificate",
    "Sensitive",
    "String",
    "WorkerPool",
    "GenericOidcAccount",
]


def fix_invalid_octopus_variable_type(config):
    """
    The LLM sometimes gives an octopusdeploy_variable a type for an account the provider has no variable type
    for, like "Token", which fails with:
    Error: Invalid Attribute Value Match ... Attribute type value must be one of: ["AmazonWebServicesAccount" ...]
    A token, SSH or other account is referenced by its ID in a String variable.
    """

    def process_resource(lines):
        fixed = []
        for line in lines:
            match = re.match(r'^(\s*type\s*=\s*)"([^"]*)"\s*$', line)
            if match and match.group(2) not in VALID_VARIABLE_TYPES:
                line = f'{match.group(1)}"String"'
            fixed.append(line)
        return fixed

    return process_resource_blocks(
        config, process_resource, 'resource "octopusdeploy_variable"'
    )


def fix_literal_variable_template_id(config):
    """
    A tenant variable resource must reference the template it sets. The LLM sometimes hard-codes a GUID, which
    fails the apply with: Error: Template not found ... Template <guid> not found in library variable set ...
    A tenant common variable gets the first template of its library variable set, and a tenant project variable
    the first template of its project.
    """

    def process_resource(owner_regex, owner_type):
        def process(lines):
            text = "\n".join(lines)
            owner = re.search(owner_regex, text)
            literal = re.search(r'(template_id\s*=\s*)"([^"$]*)"', text)
            if not owner or not literal:
                return lines
            reference = f"${{{owner_type}.{owner.group(1)}[0].template[0].id}}"
            return text.replace(
                literal.group(0), f'{literal.group(1)}"{reference}"'
            ).split("\n")

        return process

    config = process_resource_blocks(
        config,
        process_resource(
            r"library_variable_set_id\s*=\s*\"[^\"\n]*?octopusdeploy_library_variable_set\.(\w+)",
            "octopusdeploy_library_variable_set",
        ),
        'resource "octopusdeploy_tenant_common_variable"',
    )
    return process_resource_blocks(
        config,
        process_resource(
            r"project_id\s*=\s*\"[^\"\n]*?octopusdeploy_project\.(\w+)",
            "octopusdeploy_project",
        ),
        'resource "octopusdeploy_tenant_project_variable"',
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
    # An empty feed or account username fails the provider with:
    # Attribute username string length must be at least 1, got: 0
    config = re.sub(r'\s*(?<![\w.])username\s*=\s*""', "", config)
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
    resource_combined = remove_primary_package(resource_combined)

    return resource_combined


PRIMARY_PACKAGE_START_REGEX = re.compile(r"primary_package\s*=\s*\{")
CONTAINER_START_REGEX = re.compile(r"(?<![\w])container\s*=\s*\{")


def remove_balanced_attribute(text, start_regex):
    """
    Remove every attribute whose value is an object starting at start_regex, matching the closing bracket by
    counting brackets. Stopping at the first closing bracket is wrong, as that is often the end of a ${...}
    interpolation or of a nested object, which left behind fragments like:
    ", id = null, package_id = "storefront.web", properties = { SelectionMode = "immediate" } }
    """

    while True:
        match = start_regex.search(text)
        if not match:
            return text

        depth = 1
        end = match.end()
        while end < len(text) and depth > 0:
            if text[end] == "{":
                depth += 1
            elif text[end] == "}":
                depth -= 1
            end += 1

        if depth > 0:
            # The brackets are unbalanced, so there is no safe way to remove the block
            return text

        text = text[: match.start()] + text[end:]


def remove_primary_package(text):
    return remove_balanced_attribute(text, PRIMARY_PACKAGE_START_REGEX)


TEMPLATED_STEP_HEADER_REGEX = re.compile(
    r'resource\s+"octopusdeploy_process_templated_step"\s+"(?P<label>\w+)"\s*\{'
)
# Built in step types the LLM looks up as if they were step templates, by a word in the data source label
BUILT_IN_STEP_TEMPLATE_TYPES = (
    ("manual", "Octopus.Manual"),
    ("cloudformation", "Octopus.AwsRunCloudFormation"),
)
STEP_TEMPLATE_REFERENCE_REGEX = re.compile(r"data\.octopusdeploy_step_template\.(\w+)\.")
TEMPLATED_STEP_PARAMETERS_REGEX = re.compile(r"(?m)^[ \t]*parameters[ \t]*=[ \t]*\{")


def built_in_step_type(block):
    """Returns the built in step type that the step templates a templated step block looks up stand for, if any."""

    for reference in STEP_TEMPLATE_REFERENCE_REGEX.finditer(block):
        for word, step_type in BUILT_IN_STEP_TEMPLATE_TYPES:
            if word in reference.group(1).lower():
                return step_type
    return None


def fix_manual_intervention_templated_step(config):
    """
    The LLM writes a manual intervention or an AWS CloudFormation step as an octopusdeploy_process_templated_step that
    looks its template up with an invented data source, which fails the plan with:
    Error: Reference to undeclared resource ... There is no data resource "octopusdeploy_step_template"
    These are built in step types, so they are an octopusdeploy_process_step of type Octopus.Manual or
    Octopus.AwsRunCloudFormation, without the template attributes or the template parameters.
    """

    if not config or "octopusdeploy_process_templated_step" not in config:
        return config

    result = config
    position = 0
    while True:
        header = TEMPLATED_STEP_HEADER_REGEX.search(result, position)
        if not header:
            return result

        depth = 1
        end = header.end()
        while end < len(result) and depth > 0:
            if result[end] == "{":
                depth += 1
            elif result[end] == "}":
                depth -= 1
            end += 1

        block = result[header.start() : end]
        step_type = built_in_step_type(block) if depth == 0 else None
        if not step_type:
            position = header.end()
            continue

        label = header.group("label")
        block = block.replace(
            'resource "octopusdeploy_process_templated_step"',
            'resource "octopusdeploy_process_step"',
            1,
        )
        block = re.sub(r"^[ \t]*template_(?:id|version)[ \t]*=.*\n", "", block, flags=re.MULTILINE)
        block = remove_balanced_attribute(block, TEMPLATED_STEP_PARAMETERS_REGEX)
        if not re.search(r"^[ \t]*type[ \t]*=", block, re.MULTILINE):
            block = re.sub(
                r"^([ \t]*)(name[ \t]*=.*\n)",
                rf'\1\2\1type                  = "{step_type}"\n',
                block,
                count=1,
                flags=re.MULTILINE,
            )
        result = result[: header.start()] + block + result[end:]
        result = re.sub(
            rf"octopusdeploy_process_templated_step\.{re.escape(label)}(?!\w)",
            f"octopusdeploy_process_step.{label}",
            result,
        )
        position = header.start() + len(block)


COMMUNITY_TEMPLATE_DATA_REGEX = re.compile(
    r'data\s+"octopusdeploy_community_step_template"\s+"communitysteptemplate_(?P<suffix>\w+)"\s*\{'
)
COMMUNITY_TEMPLATE_WEBSITE_REGEX = re.compile(
    r'website\s*=\s*"https://library\.octopus\.com/step-templates/(?P<guid>[0-9a-fA-F-]{36})"'
)
FABRICATED_GUID_TAIL_REGEX = re.compile(r"^(?:([0-9a-fA-F]{2})\1{5}|([0-9a-fA-F]{4})\2{2})$")
UNVERIFIED_COMMUNITY_STEP_SCRIPT = (
    'echo "The community step template could not be verified, so this script step stands in for it."'
)


def is_fabricated_guid(guid):
    """A GUID the LLM made up ends in a repeating pattern like 3e3e3e3e3e3e or 3b3b3b3b3b3b."""

    return bool(FABRICATED_GUID_TAIL_REGEX.match(guid.split("-")[-1]))


def replace_unverified_community_templated_step(config):
    """
    The LLM invents the GUID in the website of a community step template (e.g. 8f3e3e3e-3e3e-3e3e-3e3e-3e3e3e3e3e3e
    for Verify Argo CD Application Healthy). The lookup returns no steps, community_action_template_id is null and the
    plan fails with:
    Error: Missing Configuration for Required Attribute ... community_action_template_id
    The templated step that uses the template becomes a script step, which the later cleanup of unused step template
    lookups then leaves without the template resources.
    """

    if not config or "octopusdeploy_community_step_template" not in config:
        return config

    suffixes = []
    for data_match in COMMUNITY_TEMPLATE_DATA_REGEX.finditer(config):
        end = find_block_end(config, data_match.end())
        website = COMMUNITY_TEMPLATE_WEBSITE_REGEX.search(config[data_match.end() : end]) if end else None
        if website and is_fabricated_guid(website.group("guid")):
            suffixes.append(data_match.group("suffix"))

    result = config
    for suffix in suffixes:
        position = 0
        while True:
            header = TEMPLATED_STEP_HEADER_REGEX.search(result, position)
            if not header:
                break
            end = find_block_end(result, header.end())
            block = result[header.start() : end] if end else ""
            if not end or not re.search(rf"_{re.escape(suffix)}(?!\w)", block):
                position = header.end()
                continue

            label = header.group("label")
            block = block.replace(
                'resource "octopusdeploy_process_templated_step"', 'resource "octopusdeploy_process_step"', 1
            )
            block = re.sub(r"^[ \t]*template_(?:id|version)[ \t]*=.*\n", "", block, flags=re.MULTILINE)
            block = remove_balanced_attribute(block, TEMPLATED_STEP_PARAMETERS_REGEX)
            block = re.sub(r"^[ \t]*type[ \t]*=.*\n", "", block, flags=re.MULTILINE)
            block = re.sub(
                r"^([ \t]*)(name[ \t]*=.*\n)",
                rf'\1\2\1type                  = "Octopus.Script"\n',
                block,
                count=1,
                flags=re.MULTILINE,
            )
            block = re.sub(r"^[ \t]*execution_properties\s*=\s*\{[^}]*\}[ \t]*\n", "", block, flags=re.MULTILINE)
            block = block.rstrip()
            block = (
                block[:-1].rstrip()
                + "\n  execution_properties = {\n"
                + '    "Octopus.Action.Script.ScriptSource" = "Inline"\n'
                + '    "Octopus.Action.Script.Syntax" = "Bash"\n'
                + f'    "Octopus.Action.Script.ScriptBody" = "{UNVERIFIED_COMMUNITY_STEP_SCRIPT.replace(chr(34), chr(92) + chr(34))}"\n'
                + '    "Octopus.Action.RunOnServer" = "true"\n'
                + "  }\n}"
            )
            result = result[: header.start()] + block + result[end:]
            result = re.sub(
                rf"octopusdeploy_process_templated_step\.{re.escape(label)}(?!\w)",
                f"octopusdeploy_process_step.{label}",
                result,
            )
            position = header.start() + len(block)

    return result


CLOUDFORMATION_DOTTED_PROPERTIES = (
    ("Octopus.Action.Aws.CloudFormation.StackName", "Octopus.Action.Aws.CloudFormationStackName"),
    ("Octopus.Action.Aws.CloudFormation.TemplateParameters", "Octopus.Action.Aws.CloudFormationTemplateParameters"),
    ("Octopus.Action.Aws.CloudFormation.Template", "Octopus.Action.Aws.CloudFormationTemplate"),
)


def fix_cloudformation_dotted_property_names(config):
    """
    The LLM writes the CloudFormation step properties with a dot (Octopus.Action.Aws.CloudFormation.StackName). The
    server only reads the names without it (Octopus.Action.Aws.CloudFormationStackName), so the step fails with:
    Octopus API error: [Please provide the CloudFormation stack name.]
    Octopus.Action.Aws.CloudFormation.ChangeSet.Arn is a real property and is left alone.
    """

    result = config
    for wrong, right in CLOUDFORMATION_DOTTED_PROPERTIES:
        result = result.replace(f'"{wrong}"', f'"{right}"')
    return result


TARGET_ROLES_LIST_REGEX = re.compile(r'(?m)^([ \t]*)"Octopus\.Action\.TargetRoles"[ \t]*=[ \t]*\[([^\]\n]*)\][ \t]*\n')


def fix_target_roles_list(config):
    """
    The LLM writes the target roles of a step as a list, but the step properties map holds strings only:
    Error: Incorrect attribute value type ... element "Octopus.Action.TargetRoles": string required, but have tuple.
    An empty list is dropped (the step has no target role) and a list of roles becomes a comma separated string.
    """

    def fix_list(match):
        roles = re.findall(r'"([^"]*)"', match.group(2))
        if not roles:
            return ""
        return f'{match.group(1)}"Octopus.Action.TargetRoles" = "{",".join(roles)}"\n'

    return TARGET_ROLES_LIST_REGEX.sub(fix_list, config)


PACKAGE_DEPLOY_ON_TARGET_TYPES = (
    "Octopus.TentaclePackage",
    "Octopus.WindowsService",
    "Octopus.IIS",
    "Octopus.TomcatDeploy",
)
DEFAULT_TARGET_ROLE = "deploy-target"
STEP_TYPE_REGEX = re.compile(r'(?m)^[ \t]*type[ \t]*=[ \t]*"([^"]+)"')
STEP_TARGET_ROLES_REGEX = re.compile(r'"Octopus\.Action\.TargetRoles"[ \t]*=[ \t]*"[^"]+"')
EMPTY_PROPERTIES_REGEX = re.compile(r"(?m)^([ \t]*)properties[ \t]*=[ \t]*\{[ \t]*\}[ \t]*$")
OPEN_PROPERTIES_REGEX = re.compile(r"(?m)^([ \t]*)properties[ \t]*=[ \t]*\{[ \t]*$")
EXECUTION_PROPERTIES_LINE_REGEX = re.compile(r"(?m)^([ \t]*)execution_properties[ \t]*=")


def add_target_role_to_step_block(block):
    role = f'"Octopus.Action.TargetRoles" = "{DEFAULT_TARGET_ROLE}"'

    empty = EMPTY_PROPERTIES_REGEX.search(block)
    if empty:
        indent = empty.group(1)
        return block[: empty.start()] + f"{indent}properties = {{\n{indent}  {role}\n{indent}}}" + block[empty.end() :]

    opened = OPEN_PROPERTIES_REGEX.search(block)
    if opened:
        return block[: opened.end()] + f"\n{opened.group(1)}  {role}" + block[opened.end() :]

    execution = EXECUTION_PROPERTIES_LINE_REGEX.search(block)
    if execution:
        indent = execution.group(1)
        return (
            block[: execution.start()]
            + f"{indent}properties = {{\n{indent}  {role}\n{indent}}}\n"
            + block[execution.start() :]
        )

    return None


def add_missing_target_role_to_package_steps(config):
    """
    A package deployment step (Deploy a Package, Windows Service, IIS, Tomcat) runs on deployment targets, and Octopus
    rejects it without a target role:
    Octopus API error: [Please select one or more target tags that 'Deploy Pkg' step will apply to.]
    When the prompt names no role the step gets a default one. As the step runs on the target it loses any worker pool
    and container image, and is not run on the server.
    """

    if not config or "octopusdeploy_process_step" not in config:
        return config

    result = config
    position = 0
    while True:
        header = PROCESS_STEP_HEADER_REGEX.search(result, position)
        if not header:
            return result
        end = find_block_end(result, header.end())
        if end is None:
            return result

        block = result[header.start() : end]
        step_type = STEP_TYPE_REGEX.search(block)
        if (
            not step_type
            or step_type.group(1) not in PACKAGE_DEPLOY_ON_TARGET_TYPES
            or STEP_TARGET_ROLES_REGEX.search(block)
        ):
            position = header.end()
            continue

        updated = add_target_role_to_step_block(block)
        if updated is None:
            position = header.end()
            continue

        updated = re.sub(r'("Octopus\.Action\.RunOnServer"[ \t]*=[ \t]*)"true"', r'\1"false"', updated)
        updated = re.sub(r"(?m)^[ \t]*worker_pool_(?:variable|id)[ \t]*=.*\n", "", updated)
        updated = remove_balanced_attribute(updated, CONTAINER_START_REGEX)
        result = result[: header.start()] + updated + result[end:]
        position = header.start() + len(updated)


S3_PACKAGE_OPTIONS_PROPERTY = "Octopus.Action.Aws.S3.PackageOptions"
UNSUPPORTED_S3_PROPERTIES = ("Octopus.Action.Aws.S3.PublicAccess", "Octopus.Action.Aws.S3.ObjectWriterOwnership")
PACKAGE_ID_REGEX = re.compile(r'package_id\s*=\s*"([^"$]+)"')


def add_missing_s3_package_options(config):
    """
    The LLM leaves the package options out of an Upload a package to an AWS S3 bucket step, and invents PublicAccess and
    ObjectWriterOwnership properties instead:
    Octopus API error: [Must provide package options]
    The step gets the options an upload of the entire package needs, with a public-read canned ACL where the LLM asked
    for public access, and the invented properties are removed.
    """

    if not config or "Octopus.AwsUploadS3" not in config:
        return config

    result = config
    position = 0
    while True:
        header = PROCESS_STEP_HEADER_REGEX.search(result, position)
        if not header:
            return result
        end = find_block_end(result, header.end())
        if end is None:
            return result

        block = result[header.start() : end]
        step_type = STEP_TYPE_REGEX.search(block)
        execution = EXECUTION_PROPERTIES_REGEX.search(block)
        if (
            not step_type
            or step_type.group(1) != "Octopus.AwsUploadS3"
            or S3_PACKAGE_OPTIONS_PROPERTY in block
            or not execution
        ):
            position = header.end()
            continue

        public = re.search(r'"Octopus\.Action\.Aws\.S3\.PublicAccess"\s*=\s*"True"', block, re.IGNORECASE)
        package_id = PACKAGE_ID_REGEX.search(block)
        indent = execution.group(1)
        options = (
            f'{indent}  "{S3_PACKAGE_OPTIONS_PROPERTY}" = jsonencode({{\n'
            f'{indent}    "bucketKeyBehaviour" = "Custom"\n'
            f'{indent}    "storageClass" = "STANDARD"\n'
            f'{indent}    "cannedAcl" = "{"public-read" if public else "private"}"\n'
            f'{indent}    "bucketKey" = "{package_id.group(1) if package_id else "package"}"\n'
            f'{indent}    "bucketKeyPrefix" = ""\n'
            f'{indent}    "variableSubstitutionPatterns" = ""\n'
            f'{indent}    "structuredVariableSubstitutionPatterns" = ""\n'
            f'{indent}    "metadata" = []\n'
            f'{indent}    "tags" = []\n'
            f"{indent}  }})\n"
        )
        block = block[: execution.end()] + options + block[execution.end() :]
        for unsupported in UNSUPPORTED_S3_PROPERTIES:
            block = re.sub(rf'(?m)^[ \t]*"{re.escape(unsupported)}"[ \t]*=.*\n', "", block)
        result = result[: header.start()] + block + result[end:]
        position = header.start() + len(block)


RELEASE_NOTES_TEMPLATE_RESOURCE_REGEX = re.compile(
    r'(?m)^[ \t]*resource\s+"octopusdeploy_project_release_notes_template"\s+"\w+"\s*\{'
)
QUOTED_STRING_PATTERN = r'"(?:[^"\\]|\\.)*"'
PROJECT_REFERENCE_REGEX = re.compile(r"octopusdeploy_project\.(\w+)")


def move_release_notes_template_to_project(config):
    """
    The LLM invents an octopusdeploy_project_release_notes_template resource for a release notes template:
    Error: Invalid resource type ... The provider octopusdeploy/octopusdeploy does not support resource type
    "octopusdeploy_project_release_notes_template".
    The template is the release_notes_template argument of the project, so the resource is removed and its template
    is set on the project that it referred to, unless the project already has one.
    """

    if not config or "octopusdeploy_project_release_notes_template" not in config:
        return config

    result = config
    while True:
        header = RELEASE_NOTES_TEMPLATE_RESOURCE_REGEX.search(result)
        if not header:
            return result
        end = find_block_end(result, header.end())
        if end is None:
            return result

        block = result[header.start() : end]
        template = re.search(rf"(?m)^[ \t]*(?:template|release_notes_template)[ \t]*=[ \t]*({QUOTED_STRING_PATTERN})", block)
        project = PROJECT_REFERENCE_REGEX.search(block)
        result = result[: header.start()] + result[end:].lstrip("\n")

        if not template or not project:
            continue

        project_header = re.search(
            rf'resource\s+"octopusdeploy_project"\s+"{re.escape(project.group(1))}"\s*\{{[ \t]*\n', result
        )
        if not project_header:
            continue
        project_end = find_block_end(result, project_header.end())
        if project_end is None or "release_notes_template" in result[project_header.end() : project_end]:
            continue
        indent_match = re.match(r"[ \t]*", result[project_header.end() :])
        indent = indent_match.group(0) if indent_match else ""
        result = (
            result[: project_header.end()]
            + f"{indent}release_notes_template = {template.group(1)}\n"
            + result[project_header.end() :]
        )


VERSIONING_STRATEGY_REGEX = re.compile(
    r'(?m)^[ \t]*resource\s+"octopusdeploy_project_versioning_strategy"\s+"\w+"\s*\{'
)


def remove_duplicate_versioning_strategies(config):
    """
    A project has one versioning strategy, but the LLM sometimes declares a second one for the same project (for
    example while working out a release notes template). Only the first is kept.
    """

    if not config or config.count("octopusdeploy_project_versioning_strategy") < 2:
        return config

    result = config
    seen = set()
    position = 0
    while True:
        header = VERSIONING_STRATEGY_REGEX.search(result, position)
        if not header:
            return result
        end = find_block_end(result, header.end())
        if end is None:
            return result

        project = PROJECT_REFERENCE_REGEX.search(result[header.start() : end])
        key = project.group(1) if project else None
        if key is not None and key in seen:
            result = result[: header.start()] + result[end:].lstrip("\n")
            position = header.start()
            continue
        if key is not None:
            seen.add(key)
        position = end


POLLING_TARGET_HEADER_REGEX = re.compile(
    r'(?m)^[ \t]*resource\s+"octopusdeploy_polling_tentacle_deployment_target"\s+"\w+"\s*\{'
)
TENTACLE_URL_REGEX = re.compile(r'(tentacle_url\s*=\s*")([^"]*)(")')
VALID_POLLING_SUBSCRIPTION_REGEX = re.compile(r"^poll://[a-z0-9]{20}/$")


def fix_polling_tentacle_uri(config):
    """
    Octopus only accepts the URL of a polling tentacle written as poll:// followed by 20 lowercase letters or digits
    and a trailing slash. The LLM writes poll://abc123/ or an https address, which fails the apply:
    Octopus API error: [A polling tentacle URI should look like 'poll://nvpv4doqf2f3id45t1xn/']
    An invalid URL is replaced with a valid subscription derived from it, so the same text always gives the same one.
    """

    if not config or "octopusdeploy_polling_tentacle_deployment_target" not in config:
        return config

    def fix_url(match):
        if VALID_POLLING_SUBSCRIPTION_REGEX.match(match.group(2)):
            return match.group(0)
        digest = hashlib.sha1(match.group(2).encode("utf-8")).hexdigest()[:20]
        return f"{match.group(1)}poll://{digest}/{match.group(3)}"

    result = config
    position = 0
    while True:
        header = POLLING_TARGET_HEADER_REGEX.search(result, position)
        if not header:
            return result
        end = find_block_end(result, header.end())
        if end is None:
            return result
        block = TENTACLE_URL_REGEX.sub(fix_url, result[header.start() : end])
        result = result[: header.start()] + block + result[end:]
        position = header.start() + len(block)


def fix_deployment_target_trigger_type(config):
    """
    The LLM names the deployment target trigger resource octopusdeploy_deployment_target_trigger, which the provider
    does not have (the arguments it writes are right):
    Error: Invalid resource type ... does not support resource type "octopusdeploy_deployment_target_trigger".
    The resource is octopusdeploy_project_deployment_target_trigger.
    """

    return config.replace(
        "octopusdeploy_deployment_target_trigger", "octopusdeploy_project_deployment_target_trigger"
    )


VALID_TRIGGER_EVENT_CATEGORIES = (
    "MachineCleanupFailed",
    "MachineAdded",
    "MachineDeploymentRelatedPropertyWasUpdated",
    "MachineDisabled",
    "MachineEnabled",
    "MachineHealthy",
    "MachineUnavailable",
    "MachineUnhealthy",
    "MachineHasWarnings",
)
# Event group names the LLM writes as event categories, and the category that stands for them
TRIGGER_EVENT_CATEGORY_ALIASES = {
    "MachineAvailableForDeployment": "MachineHealthy",
    "MachineHealthChanged": "MachineHealthy",
    "MachineUnavailableForDeployment": "MachineUnavailable",
    "MachineCritical": "MachineUnhealthy",
    "Machine": "MachineAdded",
}
EVENT_CATEGORIES_REGEX = re.compile(r"(event_categories\s*=\s*)\[([^\]]*)\]")


def fix_trigger_event_categories(config):
    """
    The LLM puts event group names (MachineAvailableForDeployment, MachineHealthChanged) in the event_categories of a
    deployment target trigger, which only accepts categories:
    invalid value for event_categories. MachineAvailableForDeployment not in [MachineCleanupFailed MachineAdded ...]
    Group names are replaced by the category closest to them, unknown names are dropped, and a trigger left without
    a category triggers when a machine is added.
    """

    if not config or "event_categories" not in config:
        return config

    def fix_categories(match):
        names = re.findall(r'"([^"]*)"', match.group(2))
        fixed = []
        for name in names:
            name = TRIGGER_EVENT_CATEGORY_ALIASES.get(name, name)
            if name in VALID_TRIGGER_EVENT_CATEGORIES and name not in fixed:
                fixed.append(name)
        if not fixed:
            fixed = ["MachineAdded"]
        return match.group(1) + "[" + ", ".join(f'"{name}"' for name in fixed) + "]"

    return EVENT_CATEGORIES_REGEX.sub(fix_categories, config)


def remove_worker_pool_from_package_steps_with_roles(config):
    """
    A package deployment step (Deploy a Package, Windows Service, IIS, Tomcat) with target roles runs on the targets. The
    LLM also gives it a worker pool, so the server sets Octopus.Action.RunOnServer, which the config does not have:
    Provider produced inconsistent result after apply ... .execution_properties: new element
    "Octopus.Action.RunOnServer" has appeared.
    The worker pool and container image go, and the step is not run on the server. A step that sets RunOnServer to
    "true" itself is left alone.
    """

    if not config or "octopusdeploy_process_step" not in config:
        return config

    result = config
    position = 0
    while True:
        header = PROCESS_STEP_HEADER_REGEX.search(result, position)
        if not header:
            return result
        end = find_block_end(result, header.end())
        if end is None:
            return result

        block = result[header.start() : end]
        step_type = STEP_TYPE_REGEX.search(block)
        if (
            not step_type
            or step_type.group(1) not in PACKAGE_DEPLOY_ON_TARGET_TYPES
            or not STEP_TARGET_ROLES_REGEX.search(block)
            or not re.search(r"(?m)^[ \t]*worker_pool_(?:variable|id)[ \t]*=", block)
            or re.search(r'"Octopus\.Action\.RunOnServer"\s*=\s*"true"', block)
        ):
            position = header.end()
            continue

        updated = re.sub(r"(?m)^[ \t]*worker_pool_(?:variable|id)[ \t]*=.*\n", "", block)
        updated = remove_balanced_attribute(updated, CONTAINER_START_REGEX)
        if '"Octopus.Action.RunOnServer"' in updated:
            updated = re.sub(r'("Octopus\.Action\.RunOnServer"\s*=\s*)"[^"]*"', r'\1"false"', updated)
        else:
            execution = EXECUTION_PROPERTIES_REGEX.search(updated)
            if execution:
                updated = (
                    updated[: execution.end()]
                    + f'{execution.group(1)}  "Octopus.Action.RunOnServer" = "false"\n'
                    + updated[execution.end() :]
                )
        result = result[: header.start()] + updated + result[end:]
        position = header.start() + len(updated)


def fix_package_pre_deploy_script_property(config):
    """
    The LLM writes the pre-deployment script of a package step as Octopus.Action.Script.PreDeployPackageOnWorker, which
    the server drops, so the apply fails and the retry loses the lifecycle, steps and variables:
    Error: Provider produced inconsistent result after apply ... .execution_properties: element
    "Octopus.Action.Script.PreDeployPackageOnWorker" has vanished.
    The server keeps the script as Octopus.Action.Script.PrePackageOnWorker.
    """

    return config.replace(
        '"Octopus.Action.Script.PreDeployPackageOnWorker"',
        '"Octopus.Action.Script.PrePackageOnWorker"',
    )


PROCESS_STEP_HEADER_REGEX = re.compile(r'resource\s+"octopusdeploy_process_step"\s+"\w+"\s*\{')
EXECUTION_PROPERTIES_REGEX = re.compile(r"^([ \t]*)execution_properties\s*=\s*\{[ \t]*\n", re.MULTILINE)


def fix_arm_template_source(config):
    """
    An Azure Resource Manager template step with an inline template needs Octopus.Action.Azure.TemplateSource, and
    the LLM sometimes leaves it out, which fails the apply and drops the step:
    Octopus API error: There was a problem with your request. [Please provide the template source.]
    """

    if not config or "Octopus.AzureResourceGroup" not in config:
        return config

    result = config
    position = 0
    while True:
        header = PROCESS_STEP_HEADER_REGEX.search(result, position)
        if not header:
            return result
        end = find_block_end(result, header.end())
        if end is None:
            return result

        block = result[header.start() : end]
        if (
            re.search(r'type\s*=\s*"Octopus\.AzureResourceGroup"', block)
            and '"Octopus.Action.Azure.ResourceGroupTemplate"' in block
            and '"Octopus.Action.Azure.TemplateSource"' not in block
        ):
            properties = EXECUTION_PROPERTIES_REGEX.search(block)
            if properties:
                indent = properties.group(1) + "  "
                block = (
                    block[: properties.end()]
                    + f'{indent}"Octopus.Action.Azure.TemplateSource" = "Inline"\n'
                    + block[properties.end() :]
                )
                result = result[: header.start()] + block + result[end:]
                end = header.start() + len(block)

        position = end


LIFECYCLE_HEADER_REGEX = re.compile(r'resource\s+"octopusdeploy_lifecycle"\s+"\w+"\s*\{')
PHASE_HEADER_REGEX = re.compile(r"\bphase\s*\{")
EMPTY_PHASE_TARGETS_REGEX = re.compile(
    r"(?P<automatic>automatic_deployment_targets\s*=\s*\[\s*\])|(?P<optional>optional_deployment_targets\s*=\s*\[\s*\])"
)


def environment_reference_for_name(config, environment_name):
    """
    Returns the expression for the id of the octopusdeploy_environment resource called environment_name, using the
    lookup-or-create form when the configuration declares a local with the matches, or None where no resource matches.
    """

    for header in re.finditer(
        r'resource\s+"octopusdeploy_environment"\s+"(?P<label>\w+)"\s*\{', config
    ):
        end = find_block_end(config, header.end())
        if end is None:
            continue
        body = config[header.end() : end]
        if not re.search(
            rf'^[ \t]*name[ \t]*=[ \t]*"{re.escape(environment_name)}"[ \t]*$', body, re.MULTILINE
        ):
            continue

        label = header.group("label")
        if re.search(rf"\b{re.escape(label)}_matches\b", config):
            return (
                f"${{length(local.{label}_matches) != 0 ? local.{label}_matches[0].id : "
                f"octopusdeploy_environment.{label}[0].id}}"
            )
        if re.search(r"^[ \t]*count[ \t]*=", body, re.MULTILINE):
            return f"${{octopusdeploy_environment.{label}[0].id}}"
        return f"${{octopusdeploy_environment.{label}.id}}"

    return None


def fix_lifecycle_phase_without_environments(config):
    """
    The LLM names the phases of a lifecycle but leaves both the automatic and the optional environment lists empty.
    Octopus reads a phase with no environments as "all remaining environments", and a lifecycle with more than one
    of them fails to create, which also loses the custom lifecycle from the project:
    Octopus API error: [Only one phase in the deployment process can be configured to use all remaining environments.]
    A phase called like a declared environment gets that environment as its optional target.
    """

    if not config or "octopusdeploy_lifecycle" not in config:
        return config

    result = config
    position = 0
    while True:
        lifecycle = LIFECYCLE_HEADER_REGEX.search(result, position)
        if not lifecycle:
            return result
        lifecycle_end = find_block_end(result, lifecycle.end())
        if lifecycle_end is None:
            return result

        block = result[lifecycle.start() : lifecycle_end]
        new_block = block
        phase_position = 0
        while True:
            phase = PHASE_HEADER_REGEX.search(new_block, phase_position)
            if not phase:
                break
            phase_end = find_block_end(new_block, phase.end())
            if phase_end is None:
                break

            phase_text = new_block[phase.start() : phase_end]
            name = re.search(r'^[ \t]*name[ \t]*=[ \t]*"([^"\n]*)"', phase_text, re.MULTILINE)
            empties = {
                key: match for match in EMPTY_PHASE_TARGETS_REGEX.finditer(phase_text)
                for key in ("automatic", "optional") if match.group(key)
            }
            reference = (
                environment_reference_for_name(result, name.group(1))
                if name and len(empties) == 2
                else None
            )
            if reference:
                optional = empties["optional"]
                phase_text = (
                    phase_text[: optional.start()]
                    + f'optional_deployment_targets = ["{reference}"]'
                    + phase_text[optional.end() :]
                )
                new_block = new_block[: phase.start()] + phase_text + new_block[phase_end:]
                phase_end = phase.start() + len(phase_text)
            phase_position = phase_end

        result = result[: lifecycle.start()] + new_block + result[lifecycle_end:]
        position = lifecycle.start() + len(new_block)


PROJECT_NAME_VARIABLE_REGEX = re.compile(
    r'(variable\s+"project_(?!group_)\w+_name"\s*\{[^{}]*?\bdefault\s*=\s*")([^"\n]*)(")'
)
PROJECT_RESOURCE_NAME_REGEX = re.compile(
    r'(resource\s+"octopusdeploy_project"\s+"\w+"\s*\{(?:(?!\n\}).)*?\n[ \t]*name[ \t]*=[ \t]*")([^"\n$]*)(")',
    re.DOTALL,
)


def replace_slash_in_project_name(config):
    """
    The Octopus server rejects a project name with a forward slash, which aborts the apply at the project resource and
    loses its process, steps and variables:
    Octopus API error: There was a problem with your request. [Name 'Shop (EU/US) v3' contains invalid characters.]
    A slash is replaced with a dash, which the instructions already ask for but a weaker model does not always do.
    """

    def dash(match):
        return match.group(1) + match.group(2).replace("/", "-") + match.group(3)

    config = PROJECT_NAME_VARIABLE_REGEX.sub(dash, config)
    return PROJECT_RESOURCE_NAME_REGEX.sub(dash, config)


def find_block_end(text, open_brace_end):
    """
    Return the index just past the bracket that closes the block whose opening bracket ends at open_brace_end,
    or None where the brackets are unbalanced.
    """

    depth = 1
    end = open_brace_end
    while end < len(text) and depth > 0:
        if text[end] == "{":
            depth += 1
        elif text[end] == "}":
            depth -= 1
        end += 1
    return end if depth == 0 else None


UNUSED_STEP_TEMPLATE_DATA_REGEX = re.compile(
    r'(?:^|\n)[ \t]*data\s+"octopusdeploy_step_template"\s+"(?P<label>\w+)"\s*\{'
)


COMMUNITY_STEP_TEMPLATE_BLOCK_REGEX = re.compile(
    r'(?:^|\n)[ \t]*(?P<kind>resource|data)\s+"octopusdeploy_community_step_template"\s+"(?P<label>\w+)"\s*\{'
)


def remove_block(text, match):
    """Removes the block that starts at match, or returns None where its brackets are unbalanced."""

    end = find_block_end(text, match.end())
    return None if end is None else text[: match.start()] + text[end:]


def remove_unused_step_template_data(config):
    """
    The LLM declares a data source for a step template it then does not use (or that is no longer used after a manual
    intervention or CloudFormation step is made a built in step). octopusdeploy_step_template is not a data source the
    provider has. The community step template resource and data source that were declared for it go too.
    """

    # Community step templates that no step references any more go first, as they refer to the step template data source
    result = remove_unused_community_step_templates(config)
    return remove_unused_step_template_lookups(result)


def remove_unused_step_template_lookups(config):
    result = config
    position = 0
    while True:
        match = UNUSED_STEP_TEMPLATE_DATA_REGEX.search(result, position)
        if not match:
            return result
        end = find_block_end(result, match.end())
        label = match.group("label")
        if end is None or re.search(
            rf"data\.octopusdeploy_step_template\.{re.escape(label)}(?!\w)", result[:match.start()] + result[end:]
        ):
            position = match.end()
            continue
        result = result[: match.start()] + result[end:]
        position = match.start()


def remove_unused_community_step_templates(config):
    result = config
    position = 0
    while True:
        match = next(
            (
                found
                for found in COMMUNITY_STEP_TEMPLATE_BLOCK_REGEX.finditer(result, position)
                if found.group("kind") == "resource"
            ),
            None,
        )
        if not match:
            return result
        label = match.group("label")
        end = find_block_end(result, match.end())
        outside = result[: match.start()] + (result[end:] if end else "")
        if end is None or re.search(
            rf"(?<!data\.)octopusdeploy_community_step_template\.{re.escape(label)}(?!\w)", outside
        ):
            position = match.end()
            continue
        result = remove_block(result, match)
        for data_match in COMMUNITY_STEP_TEMPLATE_BLOCK_REGEX.finditer(result):
            if data_match.group("kind") == "data" and data_match.group("label") == label:
                data_end = find_block_end(result, data_match.end())
                if data_end is not None and not re.search(
                    rf"data\.octopusdeploy_community_step_template\.{re.escape(label)}(?!\w)",
                    result[: data_match.start()] + result[data_end:],
                ):
                    result = remove_block(result, data_match)
                break
        position = max(match.start() - 1, 0)


EXTERNAL_FEED_TRIGGER_HEADER_REGEX = re.compile(
    r'resource\s+"octopusdeploy_external_feed_create_release_trigger"\s+"\w+"\s*\{'
)


def remove_unsupported_trigger_description(config):
    """
    octopusdeploy_external_feed_create_release_trigger has no description argument, and the LLM adds one:
    Error: Unsupported argument ... An argument named "description" is not expected here.
    """

    result = config
    position = 0
    while True:
        header = EXTERNAL_FEED_TRIGGER_HEADER_REGEX.search(result, position)
        if not header:
            return result
        end = find_block_end(result, header.end())
        if end is None:
            return result

        depth = 1
        kept = []
        for line in result[header.end() : end].split("\n"):
            if depth == 1 and re.match(r"\s*description\s*=", line):
                continue
            depth += line.count("{") - line.count("}")
            kept.append(line)
        body = "\n".join(kept)
        result = result[: header.end()] + body + result[end:]
        position = header.end() + len(body)


PRIMARY_PACKAGE_HEADER_REGEX = re.compile(r"\bprimary_package\s*=?\s*\{")
PACKAGE_ID_REGEX = re.compile(r'\bpackage_id\s*=\s*"(?P<id>[^"\n]+)"')
TRIGGER_PACKAGE_REFERENCE_REGEX = re.compile(r'(\bpackage_reference\s*=\s*)"(?P<ref>[^"\n]+)"')


def fix_trigger_primary_package_reference(config):
    """
    A step with a primary package has an empty package reference name, but the LLM uses the package ID in the trigger:
    Error: The specified package reference 'Trigger.App' for trigger 'New Package Release' does not exist on the
    action 'Deploy App'.
    The reference is only replaced when it is a primary package ID and not also the key of a packages map entry.
    """

    primary_ids = set()
    for header in PRIMARY_PACKAGE_HEADER_REGEX.finditer(config):
        end = find_block_end(config, header.end())
        if end is None:
            continue
        id_match = PACKAGE_ID_REGEX.search(config[header.end() : end])
        if id_match:
            primary_ids.add(id_match.group("id"))
    if not primary_ids:
        return config

    result = config
    position = 0
    while True:
        header = EXTERNAL_FEED_TRIGGER_HEADER_REGEX.search(result, position)
        if not header:
            return result
        end = find_block_end(result, header.end())
        if end is None:
            return result

        def replace_reference(match):
            reference = match.group("ref")
            if reference in primary_ids and not re.search(
                rf'^\s*"?{re.escape(reference)}"?\s*=\s*\{{', result, re.MULTILINE
            ):
                return match.group(1) + '""'
            return match.group(0)

        body = TRIGGER_PACKAGE_REFERENCE_REGEX.sub(replace_reference, result[header.end() : end])
        result = result[: header.end()] + body + result[end:]
        position = header.end() + len(body)


PARENTHESIS_OCTOPUS_VARIABLE_REGEX = re.compile(r"\$\((Octopus\.[A-Za-z0-9_]+(?:\.[A-Za-z0-9_]+)*)\)")


def fix_parenthesis_octopus_variable_syntax(config):
    """
    The LLM writes system variables in scripts with PowerShell subexpression syntax, like $(Octopus.Environment.Name),
    which is never replaced by Octopus and fails at runtime. The Octopus syntax is #{Octopus.Environment.Name}.
    """

    return PARENTHESIS_OCTOPUS_VARIABLE_REGEX.sub(r"#{\1}", config)


VARIABLE_CONDITION_REGEX = re.compile(r'(\bcondition\s*=\s*)"Variable"')
VARIABLE_CONDITION_EXPRESSION_REGEX = re.compile(r'"Octopus\.Step\.ConditionVariableExpression"\s*=\s*"(?P<expression>[^"\n]*)"')


def fix_variable_condition_without_expression(config):
    """
    The LLM sets condition = "Variable" but omits the expression (or leaves it empty), and Octopus rejects the step:
    Octopus API error: ... [Please add a variable expression for your variable run condition.]
    The condition falls back to Success, which is the default.
    """

    result = config
    position = 0
    while True:
        header = PROCESS_STEP_HEADER_REGEX.search(result, position)
        if not header:
            return result
        end = find_block_end(result, header.end())
        if end is None:
            return result

        body = result[header.end() : end]
        expression = VARIABLE_CONDITION_EXPRESSION_REGEX.search(body)
        if VARIABLE_CONDITION_REGEX.search(body) and (expression is None or not expression.group("expression").strip()):
            body = VARIABLE_CONDITION_REGEX.sub(r'\1"Success"', body)
        result = result[: header.end()] + body + result[end:]
        position = header.end() + len(body)


DONOR_PACKAGE_BLOCK_REGEX = re.compile(r"(?m)^([ \t]*)donor_package[ \t]*\{")


def fix_donor_package_attribute(config):
    """
    donor_package of octopusdeploy_project_versioning_strategy is an attribute, but the LLM writes it as a block:
    Error: Unsupported block type ... Blocks of type "donor_package" are not expected here.
    Did you mean to define argument "donor_package"? If so, use the equals sign to assign it a value.
    """

    result = config
    position = 0
    while True:
        header = VERSIONING_STRATEGY_REGEX.search(result, position)
        if not header:
            return result
        end = find_block_end(result, header.end())
        if end is None:
            return result

        body = DONOR_PACKAGE_BLOCK_REGEX.sub(r"\1donor_package = {", result[header.end() : end])
        result = result[: header.end()] + body + result[end:]
        position = header.end() + len(body)


UNESCAPED_TEMPLATE_DIRECTIVE_REGEX = re.compile(r"(?<!%)%\{(?!~?\s*(?:if|else|endif|for|endfor)\b)")


def escape_invalid_template_directives(config):
    """
    A percent sign followed by a brace starts a Terraform template directive, so literal text in a variable value like
    "%{not.a.directive}" fails the init:
    Error: Invalid template control keyword ... "not" is not a valid template control keyword.
    The literal form is %%{. Real directives (if, else, endif, for, endfor) are left alone.
    """

    return UNESCAPED_TEMPLATE_DIRECTIVE_REGEX.sub("%%{", config)


WORKER_POOL_ATTRIBUTE_REGEX = re.compile(r"(?m)^[ \t]*worker_pool_(?:variable|id)[ \t]*=")
RUN_ON_SERVER_PROPERTY_REGEX = re.compile(r'"Octopus\.Action\.RunOnServer"')


def add_run_on_server_to_worker_pool_steps(config):
    """
    A step with a worker pool but without Octopus.Action.RunOnServer fails the apply and the recovery loses the steps:
    Error: Provider produced inconsistent result after apply ... .execution_properties: new element
    "Octopus.Action.RunOnServer" has appeared.
    The server runs a step with a worker pool on the server, so the property is added as true.
    """

    result = config
    position = 0
    while True:
        header = PROCESS_STEP_HEADER_REGEX.search(result, position)
        if not header:
            return result
        end = find_block_end(result, header.end())
        if end is None:
            return result

        block = result[header.start() : end]
        execution = EXECUTION_PROPERTIES_REGEX.search(block)
        if (
            not execution
            or not WORKER_POOL_ATTRIBUTE_REGEX.search(block)
            or RUN_ON_SERVER_PROPERTY_REGEX.search(block)
        ):
            position = header.end()
            continue

        updated = (
            block[: execution.end()]
            + f'{execution.group(1)}  "Octopus.Action.RunOnServer" = "true"\n'
            + block[execution.end() :]
        )
        result = result[: header.start()] + updated + result[end:]
        position = header.start() + len(updated)


CHANNEL_HEADER_REGEX = re.compile(r'resource\s+"octopusdeploy_channel"\s+"(?P<label>\w+)"\s*\{')
CHANNEL_REFERENCE_REGEX = re.compile(r"octopusdeploy_channel\.(?P<label>\w+)")
DEPENDS_ON_REGEX = re.compile(r"(?P<head>\bdepends_on\s*=\s*\[)(?P<items>[^\]]*)(?P<tail>\])")
STEPS_ORDER_REFERENCE_REGEX = re.compile(r"octopusdeploy_process_steps_order\.")


def remove_steps_order_dependency_from_referenced_channels(config):
    """
    A channel that depends on the steps order, with a step that is scoped to that channel, is a cycle:
    Error: Cycle: octopusdeploy_process_step.x, octopusdeploy_process_steps_order.y, octopusdeploy_channel.z
    The steps order dependency is removed from the channels that a step refers to.
    """

    referenced = set()
    position = 0
    while True:
        header = PROCESS_STEP_HEADER_REGEX.search(config, position)
        if not header:
            break
        end = find_block_end(config, header.end())
        if end is None:
            break
        referenced.update(match.group("label") for match in CHANNEL_REFERENCE_REGEX.finditer(config[header.end() : end]))
        position = end

    if not referenced:
        return config

    result = config
    position = 0
    while True:
        header = CHANNEL_HEADER_REGEX.search(result, position)
        if not header:
            return result
        end = find_block_end(result, header.end())
        if end is None:
            return result

        body = result[header.end() : end]
        if header.group("label") in referenced:

            def remove_steps_order(match):
                items = [item for item in match.group("items").split(",") if item.strip()]
                kept = [item for item in items if not STEPS_ORDER_REFERENCE_REGEX.search(item)]
                return match.group("head") + ",".join(kept) + match.group("tail")

            body = DEPENDS_ON_REGEX.sub(remove_steps_order, body)
        result = result[: header.end()] + body + result[end:]
        position = header.end() + len(body)


STEP_ENVIRONMENTS_REGEX = re.compile(r"(?m)^([ \t]*)environments([ \t]*=[ \t]*)")
STEP_EXCLUDED_ENVIRONMENTS_REGEX = re.compile(r"(?m)^[ \t]*excluded_environments[ \t]*=[ \t]*")


def find_attribute_value_end(text, start):
    """
    Returns the index after the value that starts at start: a null, or a list closed by its matching bracket.
    """

    if text.startswith("null", start):
        return start + 4
    if not text.startswith("[", start):
        return None

    depth = 0
    for index in range(start, len(text)):
        if text[index] == "[":
            depth += 1
        elif text[index] == "]":
            depth -= 1
            if depth == 0:
                return index + 1
    return None


def attribute_has_items(text, start):
    end = find_attribute_value_end(text, start)
    if end is None:
        return False
    value = text[start:end]
    return value != "null" and bool(value[1:-1].strip())


def remove_environments_when_excluded_environments_are_set(config):
    """
    A step cannot include and exclude environments at the same time:
    Octopus API error: ... [You cannot both conditionally include and exclude environments for a deployment step.]
    The excluded environments are the explicit request ("skipped in Dev and Test"), so the included list is dropped.
    """

    result = config
    position = 0
    while True:
        header = PROCESS_STEP_HEADER_REGEX.search(result, position)
        if not header:
            return result
        end = find_block_end(result, header.end())
        if end is None:
            return result

        block = result[header.start() : end]
        included = STEP_ENVIRONMENTS_REGEX.search(block)
        excluded = STEP_EXCLUDED_ENVIRONMENTS_REGEX.search(block)
        if (
            not included
            or not excluded
            or not attribute_has_items(block, included.end())
            or not attribute_has_items(block, excluded.end())
        ):
            position = header.end()
            continue

        value_end = find_attribute_value_end(block, included.end())
        updated = block[: included.end()] + "null" + block[value_end:]
        result = result[: header.start()] + updated + result[end:]
        position = header.start() + len(updated)


STRAY_BRACKET_BEFORE_INTERPOLATION_END_REGEX = re.compile(r"(\[\d+\](?:\.\w+)+)\](\})")


def fix_stray_bracket_before_interpolation_end(config):
    """
    The LLM sometimes closes an indexed reference with an extra bracket before the end of the interpolation:
    "${length(x.projects) != 0 ? null : octopusdeploy_process.p[0].id]}"
    Error: Extra characters after interpolation expression ... Expected a closing brace to end the interpolation.
    """

    return STRAY_BRACKET_BEFORE_INTERPOLATION_END_REGEX.sub(r"\1\2", config)


STEPS_ORDER_HEADER_REGEX = re.compile(r'resource\s+"octopusdeploy_process_steps_order"\s+"(?P<label>\w+)"\s*\{')
CHANNEL_RULE_REGEX = re.compile(r"(?m)^[ \t]*rule\s*\{")
PROJECT_REFERENCE_LABEL_REGEX = re.compile(r"octopusdeploy_project\.project_(?P<label>\w+?)(?:\[|\.|\b)")


def add_steps_order_dependency_to_channels_with_rules(config):
    """
    A channel version rule names a step, so the channel must be created after the deployment process:
    Octopus API error: ... [Channel version rule references step 'Deploy Lib' which does not exist in the deployment
    process.]
    The channel gets a depends_on for the steps order of its project.
    """

    labels = [match.group("label") for match in STEPS_ORDER_HEADER_REGEX.finditer(config)]
    if not labels:
        return config

    result = config
    position = 0
    while True:
        header = CHANNEL_HEADER_REGEX.search(result, position)
        if not header:
            return result
        end = find_block_end(result, header.end())
        if end is None:
            return result

        body = result[header.end() : end]
        if not CHANNEL_RULE_REGEX.search(body):
            position = header.end()
            continue

        label = None
        project = PROJECT_REFERENCE_LABEL_REGEX.search(body)
        if project and f"process_step_order_{project.group('label')}" in labels:
            label = f"process_step_order_{project.group('label')}"
        elif len(labels) == 1:
            label = labels[0]
        if not label or f"octopusdeploy_process_steps_order.{label}" in body:
            position = header.end()
            continue

        reference = f"octopusdeploy_process_steps_order.{label}"
        depends_on = DEPENDS_ON_REGEX.search(body)
        if depends_on:
            items = depends_on.group("items").strip()
            replacement = depends_on.group("head") + (f"{items}, {reference}" if items else reference) + depends_on.group("tail")
            body = body[: depends_on.start()] + replacement + body[depends_on.end() :]
        else:
            body = f"\n  depends_on = [{reference}]" + body
        result = result[: header.end()] + body + result[end:]
        position = header.end() + len(body)


DEFAULT_CHANNEL_NAME_REGEX = re.compile(r'(?m)^[ \t]*name[ \t]*=[ \t]*"Default"[ \t]*$')


def remove_default_channel_resources(config):
    """
    Every project already has a channel called Default, so a channel resource with that name fails the apply:
    Octopus API error: ... [A channel with this name already exists for this project. Please choose a different name.]
    The resource and the references to it in depends_on lists are removed.
    """

    result = config
    labels = []
    position = 0
    while True:
        header = CHANNEL_HEADER_REGEX.search(result, position)
        if not header:
            break
        end = find_block_end(result, header.end())
        if end is None:
            break
        if DEFAULT_CHANNEL_NAME_REGEX.search(result[header.end() : end]):
            labels.append(header.group("label"))
            result = result[: header.start()] + result[end:]
            position = header.start()
        else:
            position = end

    for label in labels:
        reference = re.compile(rf"octopusdeploy_channel\.{re.escape(label)}(?:\[\d+\])?(?!\w)")

        def remove_reference(match):
            items = [item for item in match.group("items").split(",") if item.strip()]
            kept = [item for item in items if not reference.search(item)]
            return match.group("head") + ",".join(kept) + match.group("tail")

        result = DEPENDS_ON_REGEX.sub(remove_reference, result)
    return result


ENVIRONMENT_DATA_HEADER_REGEX = re.compile(r'data\s+"octopusdeploy_environments"\s+"(?P<label>\w+)"\s*\{')
ENVIRONMENT_PARTIAL_NAME_REGEX = re.compile(r'partial_name\s*=\s*"(?P<name>(?:[^"\\\n]|\\.)*)"')


def enforce_exact_environment_name_matches(config):
    """
    partial_name is a substring match, so the lookup of the environment Dev also finds Development, the count of the
    environment resource becomes 0 and the lifecycle, steps and triggers silently use Development instead of Dev.
    Every lookup is filtered to the exact name in a local, and every use of the lookup goes through that local.
    """

    if not config or "octopusdeploy_environments" not in config:
        return config

    result = config
    new_locals = []
    for header in list(ENVIRONMENT_DATA_HEADER_REGEX.finditer(config)):
        label = header.group("label")
        end = find_block_end(result, result.index(header.group(0)) + len(header.group(0)))
        start = result.index(header.group(0))
        if end is None:
            continue
        block = result[start:end]
        partial = ENVIRONMENT_PARTIAL_NAME_REGEX.search(block)
        if not partial or not partial.group("name"):
            continue

        if not re.search(rf"\b{label}_matches\s*=", result):
            new_locals.append(
                f"  {label}_matches = [for env in data.octopusdeploy_environments.{label}.environments : "
                f'env if env.name == "{partial.group("name")}"]'
            )

        updated = re.sub(r"(\btake\s*=\s*)\d+", r"\g<1>100", block)
        result = result[:start] + updated + result[end:]
        result = result.replace(
            f"length(data.octopusdeploy_environments.{label}.environments)", f"length(local.{label}_matches)"
        )
        result = result.replace(f"data.octopusdeploy_environments.{label}.environments[0]", f"local.{label}_matches[0]")

    if new_locals:
        result = result.rstrip("\n") + "\n\nlocals {\n" + "\n".join(new_locals) + "\n}\n"
    return result


ENVIRONMENT_RESOURCE_HEADER_REGEX = re.compile(r'resource\s+"octopusdeploy_environment"\s+"(?P<label>\w+)"\s*\{')
ENVIRONMENT_NAME_REGEX = re.compile(r'(?m)^[ \t]*name[ \t]*=[ \t]*"(?P<name>[^"\n]*)"[ \t]*$')


def remove_case_insensitive_duplicate_environments(config):
    """
    Octopus names are case insensitive and trimmed, so environments called Dev and dev are one environment and the
    second fails the apply:
    Octopus API error: ... [An environment with this name already exists in this space. Please choose a different name.]
    The later duplicate is removed and references to it point to the first one.
    """

    seen = {}
    duplicates = {}
    for header in ENVIRONMENT_RESOURCE_HEADER_REGEX.finditer(config):
        end = find_block_end(config, header.end())
        if end is None:
            continue
        name = ENVIRONMENT_NAME_REGEX.search(config[header.end() : end])
        if not name:
            continue
        key = name.group("name").strip().lower()
        if key in seen:
            duplicates[header.group("label")] = seen[key]
        else:
            seen[key] = header.group("label")

    result = config
    for removed, kept in duplicates.items():
        header = re.search(rf'resource\s+"octopusdeploy_environment"\s+"{re.escape(removed)}"\s*\{{', result)
        if not header:
            continue
        block_removed = remove_block(result, header)
        if block_removed is None:
            continue
        result = re.sub(
            rf"octopusdeploy_environment\.{re.escape(removed)}(?!\w)", f"octopusdeploy_environment.{kept}", block_removed
        )
    return result


def fix_steps_order_project_id(config):
    """
    octopusdeploy_process_steps_order takes a process_id, but the LLM sometimes writes project_id:
    Error: Missing required argument ... The argument "process_id" is required
    Error: Unsupported argument ... An argument named "project_id" is not expected here.
    """

    result = config
    position = 0
    while True:
        header = STEPS_ORDER_HEADER_REGEX.search(result, position)
        if not header:
            return result
        end = find_block_end(result, header.end())
        if end is None:
            return result

        body = result[header.end() : end]
        if not re.search(r"(?m)^[ \t]*process_id[ \t]*=", body):
            body = re.sub(r"(?m)^([ \t]*)project_id([ \t]*=)", r"\1process_id\2", body, count=1)
        result = result[: header.end()] + body + result[end:]
        position = header.end() + len(body)


NAME_VARIABLE_HEADER_REGEX = re.compile(r'variable\s+"(?P<label>\w+_name)"\s*\{')
VARIABLE_DEFAULT_STRING_REGEX = re.compile(r'(?m)^([ \t]*default[ \t]*=[ \t]*")((?:[^"\\\n]|\\.)*)(")[ \t]*$')


def trim_name_variable_defaults(config):
    """
    Octopus trims the names of resources, and the name of a project or project group is read from a variable whose
    default holds the name, so surrounding spaces in the default make the provider report an inconsistent result:
    Provider produced inconsistent result after apply ... .name was cty.StringVal("  My Name  "), but now ...
    """

    result = config
    position = 0
    while True:
        header = NAME_VARIABLE_HEADER_REGEX.search(result, position)
        if not header:
            return result
        end = find_block_end(result, header.end())
        if end is None:
            return result

        body = VARIABLE_DEFAULT_STRING_REGEX.sub(
            lambda match: match.group(1) + match.group(2).strip() + match.group(3), result[header.end() : end]
        )
        result = result[: header.end()] + body + result[end:]
        position = header.end() + len(body)


STEP_NAME_ATTRIBUTE_REGEX = re.compile(r'(?m)^([ \t]*name[ \t]*=[ \t]*")((?:[^"\\\n]|\\.)*)(")[ \t]*$')
STEP_NAME_REFERENCE_REGEX = re.compile(r"^\$\{\s*(?:var|local|data|octopusdeploy_)")


def replace_template_characters_in_step_names(config):
    """
    The name of a step only accepts letters, numbers, periods, commas, dashes, underscores and hashes, so a name like
    "Echo ${Name}" fails the step:
    Octopus API error: ... ['Echo ${Name}' contains invalid characters. Names can only contain letters, numbers, ...]
    The dollar sign and the braces are replaced with underscores, except in a reference to a variable or local.
    """

    result = config
    position = 0
    while True:
        header = PROCESS_STEP_HEADER_REGEX.search(result, position)
        if not header:
            return result
        end = find_block_end(result, header.end())
        if end is None:
            return result

        body = result[header.end() : end]
        name = STEP_NAME_ATTRIBUTE_REGEX.search(body)
        if name and not STEP_NAME_REFERENCE_REGEX.match(name.group(2)) and re.search(r"[${}]", name.group(2)):
            fixed = re.sub(r"[${}]", "_", name.group(2))
            body = body[: name.start(2)] + fixed + body[name.end(2) :]
        result = result[: header.end()] + body + result[end:]
        position = header.end() + len(body)


NULL_CHANNEL_FALLBACK_REGEX = re.compile(
    r"(?P<lookup>data\.octopusdeploy_channels\.(?P<label>\w+)\.channels\[0\]\.id\s*:\s*)null(?=\s*\})"
)


def fix_null_channel_fallback(config):
    """
    A step is scoped to a channel with a lookup that falls back to null when the channel is not found, and the channel
    is created by the same configuration, so the apply scopes the step to nothing:
    Octopus API error: ... [value (Parameter 'Tiny types should never be empty or whitespace. ...')]
    The fallback is the channel resource.
    """

    def replace(match):
        label = match.group("label")
        header = re.search(rf'resource\s+"octopusdeploy_channel"\s+"{re.escape(label)}"\s*\{{', config)
        if not header:
            return match.group(0)
        end = find_block_end(config, header.end())
        body = config[header.end() : end] if end is not None else ""
        index = "[0]" if re.search(r"(?m)^[ \t]*count[ \t]*=", body) else ""
        return f"{match.group('lookup')}octopusdeploy_channel.{label}{index}.id"

    return NULL_CHANNEL_FALLBACK_REGEX.sub(replace, config)


VARIABLE_RESOURCE_HEADER_REGEX = re.compile(r'resource\s+"octopusdeploy_variable"\s+"(?P<label>\w+)"\s*\{')
VARIABLE_OWNER_REGEX = re.compile(r"(?m)^[ \t]*owner_id[ \t]*=[ \t]*(?P<value>.+?)[ \t]*$")
VARIABLE_NAME_REGEX = re.compile(r'(?m)^[ \t]*name[ \t]*=[ \t]*"(?P<value>(?:[^"\\\n]|\\.)*)"[ \t]*$')


def remove_duplicate_variables_with_same_name_and_scope(config):
    """
    Two variables of a project with the same name and scope fail the apply:
    Octopus API error: ... [These variables have the same name and scope. Remove the duplicates before saving: 'Secret'
    scoped to []]
    The later variable is removed.
    """

    seen = set()
    duplicates = []
    for header in VARIABLE_RESOURCE_HEADER_REGEX.finditer(config):
        end = find_block_end(config, header.end())
        if end is None:
            continue
        body = config[header.end() : end]
        owner = VARIABLE_OWNER_REGEX.search(body)
        name = VARIABLE_NAME_REGEX.search(body)
        if not owner or not name:
            continue
        scope = re.search(r"(?m)^[ \t]*scope[ \t]*\{", body)
        scope_text = ""
        if scope:
            scope_end = find_block_end(body, scope.end())
            scope_text = re.sub(r"\s+", "", body[scope.end() : scope_end]) if scope_end is not None else ""
        key = (owner.group("value"), name.group("value"), scope_text)
        if key in seen:
            duplicates.append(header.group("label"))
        else:
            seen.add(key)

    result = config
    for label in duplicates:
        header = re.search(rf'resource\s+"octopusdeploy_variable"\s+"{re.escape(label)}"\s*\{{', result)
        removed = remove_block(result, header) if header else None
        if removed is not None:
            result = removed
    return result


WORKER_POOL_DATA_REFERENCE_REGEX = re.compile(r"data\.octopusdeploy_worker_pools\.(?P<label>workerpool_\w+?)(?=\.worker_pools)")
WORKER_POOL_DATA_DECLARATION_REGEX = re.compile(r'data\s+"octopusdeploy_worker_pools"\s+"(?P<label>\w+)"')


def declare_missing_worker_pool_data_sources(config):
    """
    A step refers to a worker pool lookup that the LLM did not declare:
    Error: Reference to undeclared resource ... There is no data resource "octopusdeploy_worker_pools"
    "workerpool_hosted_ubuntu" definition in the root module.
    The lookup is declared with the pool name taken from the label (workerpool_hosted_ubuntu looks up Hosted Ubuntu).
    """

    declared = {match.group("label") for match in WORKER_POOL_DATA_DECLARATION_REGEX.finditer(config)}
    missing = []
    for match in WORKER_POOL_DATA_REFERENCE_REGEX.finditer(config):
        label = match.group("label")
        if label not in declared and label not in missing:
            missing.append(label)

    if not missing:
        return config

    blocks = []
    for label in missing:
        name = " ".join(word.capitalize() for word in label[len("workerpool_") :].split("_"))
        blocks.append(
            f'data "octopusdeploy_worker_pools" "{label}" {{\n'
            f"  ids          = null\n"
            f'  partial_name = "{name}"\n'
            f"  skip         = 0\n"
            f"  take         = 1\n"
            f"}}\n"
        )
    return config.rstrip("\n") + "\n\n" + "\n".join(blocks)


PACKAGES_MAP_REGEX = re.compile(r"\bpackages\s*=\s*\{")
UNQUOTED_DOTTED_KEY_REGEX = re.compile(r"(?m)^([ \t]*)([A-Za-z_]\w*(?:\.\w+)+)([ \t]*=)")


def quote_dotted_package_keys(config):
    """
    The key of an additional package in the packages map is the package reference name, and the LLM writes a name with
    a dot (a package ID like Acme.Extras) without quotes, which HCL reads as a reference:
    Error: Reference to undeclared resource ... There is no managed resource "Acme" "Extras" definition in the root
    module.
    """

    result = config
    position = 0
    while True:
        match = PACKAGES_MAP_REGEX.search(result, position)
        if not match:
            return result
        end = find_block_end(result, match.end())
        if end is None:
            return result

        body = UNQUOTED_DOTTED_KEY_REGEX.sub(r'\1"\2"\3', result[match.end() : end])
        result = result[: match.end()] + body + result[end:]
        position = match.end() + len(body)


NAMED_PACKAGES_START_REGEX = re.compile(r"(?m)^[ \t]*packages[ \t]*=[ \t]*\{")


def remove_named_packages_from_package_deploy_steps(config):
    """
    A package deployment step (Deploy a Package, Windows Service, IIS, Tomcat) takes one package, and the LLM adds the
    additional packages of the prompt as named packages, which the server rejects:
    Octopus API error: ... [This deployment step does not support named package references]
    The named packages are removed and the primary package stays.
    """

    result = config
    position = 0
    while True:
        header = PROCESS_STEP_HEADER_REGEX.search(result, position)
        if not header:
            return result
        end = find_block_end(result, header.end())
        if end is None:
            return result

        block = result[header.start() : end]
        step_type = STEP_TYPE_REGEX.search(block)
        if (
            step_type
            and step_type.group(1) in PACKAGE_DEPLOY_ON_TARGET_TYPES
            and NAMED_PACKAGES_START_REGEX.search(block)
        ):
            block = remove_balanced_attribute(block, NAMED_PACKAGES_START_REGEX)
            result = result[: header.start()] + block + result[end:]
            end = header.start() + len(block)
        position = end


FOR_OVER_INDEXED_LOOKUP_REGEX = re.compile(
    r"(\bin\s+)(data\.octopusdeploy_\w+\.\w+\.\w+\[0\]\.\w+)(\s*:)"
)


def fix_for_expression_over_empty_lookup(config):
    """
    A for expression that loops over an element of a lookup, like
    [for item in data.octopusdeploy_tag_sets.x.tag_sets[0].tags : item if item.name == "EU"]
    fails the plan when the lookup finds nothing in a fresh space:
    Error: Invalid index ... data.octopusdeploy_tag_sets.x.tag_sets is empty list of object
    An empty list is the correct result for a lookup that found nothing.
    """

    return FOR_OVER_INDEXED_LOOKUP_REGEX.sub(r"\1try(\2, [])\3", config)


PROJECT_DESCRIPTION_HEREDOC_REGEX = re.compile(
    r"^(?P<indent>[ \t]*)description[ \t]*=[ \t]*<<(?P<dash>-?)(?P<tag>[A-Za-z_][A-Za-z0-9_]*)[ \t]*\n"
    r"(?P<body>.*?)\n[ \t]*(?P=tag)[ \t]*$",
    re.MULTILINE | re.DOTALL,
)


def fix_project_description_heredoc(config):
    """
    A multi line markdown project description written as a heredoc ends with a newline that Octopus does not keep, so
    the apply fails with:
    Error: Provider produced inconsistent result after apply ... .description was cty.StringVal("# ...\\n"), but now ...
    Write it as a quoted string with the trailing whitespace removed instead.
    """

    if not config or "<<" not in config:
        return config

    def convert(match):
        lines = match.group("body").split("\n")
        if match.group("dash"):
            indents = [len(line) - len(line.lstrip()) for line in lines if line.strip()]
            strip = min(indents) if indents else 0
            lines = [line[strip:] for line in lines]
        text = "\n".join(lines).rstrip()
        text = (
            text.replace("\\", "\\\\")
            .replace('"', '\\"')
            .replace("${", "$${")
            .replace("%{", "%%{")
            .replace("\n", "\\n")
        )
        return f'{match.group("indent")}description = "{text}"'

    def convert_in_project(match):
        # The nearest resource header above the heredoc says which resource it belongs to. Indentation is not
        # relied on, as the LLM often leaves nested blocks unindented.
        headers = list(
            re.finditer(r'^[ \t]*(?:resource|data)[ \t]+"[^"]+"', config[: match.start()], re.MULTILINE)
        )
        if not headers or not re.fullmatch(
            r'resource\s+"octopusdeploy_project"', headers[-1].group(0).strip()
        ):
            return match.group(0)
        return convert(match)

    return PROJECT_DESCRIPTION_HEREDOC_REGEX.sub(convert_in_project, config)


CONTAINER_BLOCK_START_REGEX = re.compile(r"(?m)^([ \t]*)container[ \t]*\{")
CONTAINER_FIELD_REGEX = re.compile(r"\s*(dockerfile|feed_id|git_url|image)\s*=\s*(.+?)\s*$")


def fix_process_step_container_block(config):
    """
    The LLM writes the worker container image of a step as a block:
    container { feed_id = "..." image = "..." }
    octopusdeploy_process_step takes an attribute, and a block fails the plan with:
    Error: Unsupported block type ... Blocks of type "container" are not expected here.
    Brackets are counted rather than indents, as the LLM leaves the indents of nested blocks inconsistent.
    """

    if not config or "container" not in config:
        return config

    result = config
    position = 0
    while True:
        header = PROCESS_STEP_HEADER_REGEX.search(result, position)
        if not header:
            return result
        end = find_block_end(result, header.end())
        if end is None:
            return result

        block = result[header.start() : end]
        search_from = 0
        while True:
            container = CONTAINER_BLOCK_START_REGEX.search(block, search_from)
            if not container:
                break
            container_end = find_block_end(block, container.end())
            if container_end is None:
                break

            fields = {"dockerfile": "null", "feed_id": "null", "git_url": "null", "image": "null"}
            for line in block[container.end() : container_end - 1].split("\n"):
                field = CONTAINER_FIELD_REGEX.match(line)
                if field:
                    fields[field.group(1)] = field.group(2)
            replacement = (
                f"{container.group(1)}container = {{ "
                + ", ".join(f"{key} = {value}" for key, value in fields.items())
                + " }"
            )
            block = block[: container.start()] + replacement + block[container_end:]
            search_from = container.start() + len(replacement)

        result = result[: header.start()] + block + result[end:]
        position = header.start() + len(block)


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


def process_resource_blocks(config, process_resource, resource_prefix="resource "):
    """
    Split a configuration into the lines belonging to each top level resource block, pass those lines
    to the supplied function, and rebuild the configuration from the lines it returns. Lines outside
    of a matching resource block are passed through untouched.

    This relies on resource blocks starting with an unindented line beginning with resource_prefix and
    ending with an unindented closing bracket. Where those assumptions do not hold, the original
    configuration is returned unprocessed.

    Heredocs hold scripts and Terraform templates rather than HCL2, and their contents are frequently
    unindented, so they are treated as part of the surrounding block rather than scanned for brackets.
    """

    output = []

    in_resource = False
    resource_lines = []
    heredoc_terminator = None

    for line in config.splitlines():
        if heredoc_terminator is not None:
            # We are inside a heredoc, so the line is content rather than HCL2
            if line.strip() == heredoc_terminator:
                heredoc_terminator = None

            if in_resource:
                resource_lines.append(line)
            else:
                output.append(line)

            continue

        heredoc_start = HEREDOC_START_REGEX.search(line)
        if heredoc_start:
            heredoc_terminator = heredoc_start.group(1)

        if not in_resource and line.startswith(resource_prefix):
            # We entered a resource block
            in_resource = True
            resource_lines = [line]
        elif in_resource:
            resource_lines.append(line)

            if line == "}":
                in_resource = False
                output.extend(process_resource(resource_lines))
        else:
            output.append(line)

    # Our assumptions about the indents of brackets failed, so do no processing
    if in_resource:
        return config

    return "\n".join(output)


def remove_non_octopus_resources(config):
    """
    LLMs would sometimes define resources belonging to other providers, like aws_s3_bucket, which can
    not be applied to an Octopus space. This function removes any top level resource that is not an
    Octopus resource.
    """

    if not config:
        return ""

    # A quick out if there were no resources
    if "resource " not in config:
        return config

    def process_resource(resource_lines):
        if resource_lines[0].startswith(OCTOPUS_RESOURCE_PREFIX):
            return resource_lines

        return []

    return process_resource_blocks(config, process_resource)


def remove_non_octopus_data_sources(config):
    """
    LLMs would sometimes define data sources belonging to other providers, like aws_s3_bucket, which
    can not be read from an Octopus space. This function removes any top level data source that is not
    an Octopus data source.
    """

    if not config:
        return ""

    # A quick out if there were no data sources
    if "data " not in config:
        return config

    def process_data_source(data_source_lines):
        if data_source_lines[0].startswith(OCTOPUS_DATA_PREFIX):
            return data_source_lines

        return []

    return process_resource_blocks(config, process_data_source, "data ")


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

    def process_resource(resource_lines):
        # Detect if this is a script resource
        is_script = any(
            resource_line
            for resource_line in resource_lines
            if resource_line.strip().startswith('"Octopus.Action.Script.ScriptSource"')
        )

        if not is_script:
            return resource_lines

        script_type = next(
            (
                resource_line.split("=").pop().strip()
                for resource_line in resource_lines
                if resource_line.strip().startswith(
                    '"Octopus.Action.Script.ScriptSource"'
                )
            ),
            None,
        )

        if script_type == '"Inline"':
            return [sanitize_inline_script(resource_lines)]

        if script_type == '"Package"':
            return [sanitize_package_script(resource_lines)]

        # Unknown script type, just output the resource as-is
        return resource_lines

    return process_resource_blocks(config, process_resource)


def fix_yaml_source(config):
    """
    LLMs would often try to define a YML step from a git source with no filename.
    """

    if not config:
        return ""

    # A quick out if there were no k8s yaml
    if "Octopus.KubernetesDeployRawYaml" not in config:
        return config

    def process_resource(resource_lines):
        # Detect if this is a script resource
        is_script = any(
            resource_line
            for resource_line in resource_lines
            if resource_line.strip().startswith('"Octopus.Action.Script.ScriptSource"')
        )

        if not is_script:
            return resource_lines

        script_type = next(
            (
                resource_line.split("=").pop().strip()
                for resource_line in resource_lines
                if resource_line.strip().startswith(
                    '"Octopus.Action.Script.ScriptSource"'
                )
            ),
            None,
        )

        if script_type == '"GitRepository"':
            return [sanitize_git_script(resource_lines)]

        # Unknown script type, just output the resource as-is
        return resource_lines

    return process_resource_blocks(config, process_resource)


def sanitize_git_script(lines):
    filename_exists = any(
        resource_line
        for resource_line in lines
        if resource_line.strip().startswith(
            '"Octopus.Action.KubernetesContainers.CustomResourceYamlFileName"'
        )
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
                '        "Octopus.Action.KubernetesContainers.CustomResourceYamlFileName" = "resource.yaml"',
            )

    resource_combined = "\n".join(lines)
    return resource_combined


def has_mock_git_resources(config):
    """
    Check if the configuration contains resources that require mock git server credentials.
    This includes platform hub version control settings or git credential resources,
    and the mock git server URL must be present in the configuration.
    """
    if not config:
        return False

    return (
        "octopusdeploy_platform_hub_version_control_username_password_settings"
        in config
        or "octopusdeploy_git_credential" in config
    ) and os.getenv("MOCKGIT_API_URL", "") in config


def set_mock_certificate(config):
    """
    Set certificate_data and password for octopusdeploy_certificate resources
    using hardcoded canonical fixture values.
    """
    if not config:
        return ""

    if 'resource "octopusdeploy_certificate"' not in config:
        return config

    def replace_certificate_data(line):
        if line.strip().startswith("certificate_data"):
            return f'  certificate_data = "{MOCK_CERTIFICATE_DATA}"'
        return line

    def replace_password(line):
        if line.strip().startswith("password"):
            return f'  password = "{MOCK_CERTIFICATE_PASSWORD}"'
        return line

    def process_resource(resource_lines):
        return list(
            map(
                lambda resource_line: replace_certificate_data(
                    replace_password(resource_line)
                ),
                resource_lines,
            )
        )

    return process_resource_blocks(
        config, process_resource, 'resource "octopusdeploy_certificate"'
    )


def set_mock_git_server(config, username, password):
    """
    We want to add credentials for the mock git server
    """

    if not config:
        return ""

    # A quick out if there were no platform hub version control settings
    if (
        "octopusdeploy_platform_hub_version_control_username_password_settings"
        not in config
    ):
        return config

    def replace_username(line):
        if line.strip().startswith("username"):
            return f'  username = "{username}"'
        return line

    def replace_password(line):
        if line.strip().startswith("password"):
            return f'  password = "{password}"'
        return line

    def process_resource(resource_lines):
        return list(
            map(
                lambda resource_line: replace_username(replace_password(resource_line)),
                resource_lines,
            )
        )

    return process_resource_blocks(
        config,
        process_resource,
        'resource "octopusdeploy_platform_hub_version_control_username_password_settings"',
    )


def set_mock_git_credential(config, username, password):
    """
    Updates the username and password for octopusdeploy_git_credential resources
    when the config contains an Argo CD Update Manifests step.
    """

    if not config:
        return ""

    if 'resource "octopusdeploy_git_credential"' not in config:
        return config

    def replace_username(line):
        if line.strip().startswith("username"):
            return f'  username                = "{username}"'
        return line

    def replace_password(line):
        if line.strip().startswith("password"):
            return f'  password                = "{password}"'
        return line

    def process_resource(resource_lines):
        return list(
            map(
                lambda resource_line: replace_username(replace_password(resource_line)),
                resource_lines,
            )
        )

    return process_resource_blocks(
        config, process_resource, 'resource "octopusdeploy_git_credential"'
    )


def fix_stale_project_resource_label(config):
    """
    LLMs building from an example configuration file (progressive_deployment.tf, argoupdatemanifest.tf,
    deploymentorchestration.tf, etc.) sometimes declare the new project's octopusdeploy_project resource
    under a fresh, project-specific label, but leave many other resources (variables, the process, the
    channel data source, a runbook) referencing the EXAMPLE FILE's own generic label (e.g.
    "project_progressive_deployment"), which is never declared anywhere in the output as either a
    resource or a data source. This produces 15-20+ cascading "Reference to undeclared resource" errors
    at plan time and creates ZERO resources - a total failure, not merely a content mismatch. Observed
    3 times across different project types (Argo CD, Progressive Deployment, wave deployment) despite a
    documentation-only instruction to keep labels consistent, so this deterministic fix was added.

    This only rewrites labels when there is EXACTLY ONE declared "octopusdeploy_project" resource in the
    file, since with multiple projects (e.g. an orchestration project's parent + child) we cannot safely
    guess which one a stale reference was meant to point at.
    """
    if not config or 'resource "octopusdeploy_project"' not in config:
        return config

    declared_labels = set(
        re.findall(r'resource\s+"octopusdeploy_project"\s+"([a-zA-Z0-9_]+)"', config)
    )

    if len(declared_labels) != 1:
        return config

    correct_label = next(iter(declared_labels))

    declared_data_labels = set(
        re.findall(r'data\s+"octopusdeploy_projects"\s+"([a-zA-Z0-9_]+)"', config)
    )

    referenced_labels = set(re.findall(r"octopusdeploy_project\.([a-zA-Z0-9_]+)\[0\]", config))
    referenced_labels.update(
        re.findall(r"data\.octopusdeploy_projects\.([a-zA-Z0-9_]+)\.", config)
    )

    stale_labels = referenced_labels - declared_labels - declared_data_labels

    fixed_config = config
    for stale_label in stale_labels:
        fixed_config = re.sub(
            rf"\b{re.escape(stale_label)}\b", correct_label, fixed_config
        )

    return fixed_config


def set_mock_git_user_variable(config, username):
    """
    Finds a resource of type octopusdeploy_variable with the name
    "Project.MockGit.Username" and sets the value to the mock git server username.
    """

    if not config:
        return ""

    if "Project.MockGit.Username" not in config:
        return config

    def process_resource(resource_lines):
        # The resource declaration itself is not searched for the variable name
        is_target_variable = any(
            '"Project.MockGit.Username"' in resource_line and "name" in resource_line
            for resource_line in resource_lines[1:]
        )

        if not is_target_variable:
            return resource_lines

        return list(
            map(
                lambda resource_line: (
                    f'  value        = "{username}"'
                    if resource_line.strip().startswith("value")
                    else resource_line
                ),
                resource_lines,
            )
        )

    return process_resource_blocks(
        config, process_resource, 'resource "octopusdeploy_variable"'
    )
