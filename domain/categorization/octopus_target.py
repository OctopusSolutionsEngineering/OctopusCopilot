import re

from domain.validation.argument_validation import ensure_string, ensure_string_or_none


def project_includes_azure_steps(deployment_context):
    """
    Checks a snippet if HCL to determine if it includes Azure steps.
    :param deployment_context: The HCL snippet to check
    :return: True if the snippet includes Azure steps, False otherwise
    """

    ensure_string_or_none(
        deployment_context,
        "deployment_context must be a string (project_includes_azure_steps).",
    )

    if not deployment_context:
        return False

    return re.search(r"action_type\s*=\s*\"Octopus.Azure.*?\"", deployment_context)


def project_includes_aws_steps(deployment_context):
    """
    Checks a snippet if HCL to determine if it includes AWS steps.
    :param deployment_context: The HCL snippet to check
    :return: True if the snippet includes AWS steps, False otherwise
    """

    ensure_string_or_none(
        deployment_context,
        "deployment_context must be a string (project_includes_aws_steps).",
    )

    if not deployment_context:
        return False

    return re.search(r"action_type\s*=\s*\"Octopus.AWS.*?\"", deployment_context)


def project_includes_gcp_steps(deployment_context):
    """
    Checks a snippet if HCL to determine if it includes GCP steps.
    :param deployment_context: The HCL snippet to check
    :return: True if the snippet includes GCP steps, False otherwise
    """

    ensure_string_or_none(
        deployment_context,
        "deployment_context must be a string (project_includes_gcp_steps).",
    )

    if not deployment_context:
        return False

    return re.search(r"action_type\s*=\s*\"Octopus.Google.*?\"", deployment_context)


def project_includes_windows_steps(deployment_context):
    """
    Checks a snippet if HCL to determine if it includes Windows steps.
    :param deployment_context: The HCL snippet to check
    :return: True if the snippet includes Windows steps, False otherwise
    """

    ensure_string_or_none(
        deployment_context,
        "deployment_context must be a string (project_includes_windows_steps).",
    )

    if not deployment_context:
        return False

    patterns = [
        r"action_type\s*=\s*\"Octopus.IIS\"",
        r"action_type\s*=\s*\"Octopus.WindowsService\"",
    ]

    return any(re.search(pattern, deployment_context) for pattern in patterns)


def has_unknown_steps(deployment_context):
    """
    Checks a snippet if HCL to determine if it includes steps that deploy to an unknown platform.
    :param deployment_context: The HCL snippet to check
    :return: True if the snippet includes unknown steps, False otherwise
    """

    ensure_string_or_none(
        deployment_context,
        "deployment_context must be a string (has_unknown_steps).",
    )

    return not (
        project_includes_windows_steps(deployment_context)
        or project_includes_gcp_steps(deployment_context)
        or project_includes_aws_steps(deployment_context)
        or project_includes_azure_steps(deployment_context)
    )
