import re


def sanitize_projects(input_list):
    return sanitize_list(input_list, "\\*|Project [0-9A-Z]|MyProject|My Project")


def sanitize_tenants(input_list):
    return sanitize_list(input_list, "\\*|Tenant [0-9A-Z]|MyTenant|My Tenant")


def sanitize_feeds(input_list):
    return sanitize_list(input_list, "\\*|Feed [0-9A-Z]|MyFeed|My Feed")


def sanitize_environments(input_list):
    return sanitize_list(input_list, "\\*|Environment [0-9A-Z]|MyEnvironment|My Environment"),


def sanitize_targets(input_list):
    return sanitize_list(input_list, "\\*|Machine [0-9A-Z]|Target [0-9A-Z]|MyMachine|MyTarget|My Machine|My Target")


def sanitize_runbooks(input_list):
    return sanitize_list(input_list, "\\*|Runbook [0-9A-Z]|MyRunbook|My Runbook")


def sanitize_library_variable_sets(input_list):
    return sanitize_list(input_list,
                         "\\*|(Library )?Variable Set [0-9A-Z]|MyVariableSet|Variables|My Variable Set")


def sanitize_list(input_list, ignored_re=None):
    """
    OpenAI can provide some unexpected inputs. This function cleans them up.
    :param input_list: The list to sanitize
    :return: The sanitized list of strings
    """
    if isinstance(input_list, str):
        if input_list.strip() and not has_prefix(ignored_re, ignored_re):
            return [input_list.strip()]
        else:
            return []

    # Open AI will give you a list with a single asterisk if the list is empty
    return [entry.strip() for entry in input_list if
            isinstance(entry, str) and entry.strip() and not has_prefix(entry, ignored_re)] if input_list else []


def has_prefix(entry, ignored_re):
    if not ignored_re:
        return False

    return re.match(ignored_re, entry)
