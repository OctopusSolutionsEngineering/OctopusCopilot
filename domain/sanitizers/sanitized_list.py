import re


def sanitize_projects(input_list):
    return sanitize_list(input_list, "\\*|Project\\s*[0-9A-Z]|My\\s*Project")


def sanitize_tenants(input_list):
    return sanitize_list(input_list, "\\*|Tenant\\s*[0-9A-Z]|My\\s*Tenant")


def sanitize_feeds(input_list):
    return sanitize_list(input_list, "\\*|Feed\\s*[0-9A-Z]|My\\s*Feed")


def sanitize_accounts(input_list):
    return sanitize_list(input_list, "\\*|Account\\s*[0-9A-Z]|My\\s*Account")


def sanitize_workerpools(input_list):
    return sanitize_list(input_list, "\\*|Worker\\s*Pool\\s*[0-9A-Z]|My\\s*Worker\\s*Pool")


def sanitize_machinepolicies(input_list):
    return sanitize_list(input_list, "\\*|Machine\\s*Policy\\s*[0-9A-Z]|My\\s*Machine\\s*Policy")


def sanitize_tenanttagsets(input_list):
    return sanitize_list(input_list, "\\*|Tag\\s*Set\\s*[0-9A-Z]|My\\s*Tag\\s*Set")


def sanitize_projectgroups(input_list):
    return sanitize_list(input_list, "\\*|Project\\s*Group\\s*[0-9A-Z]|My\\s*Project\\s*Group")


def sanitize_channels(input_list):
    return sanitize_list(input_list, "\\*|Channel\\s*[0-9A-Z]|My\\s*Channel")


def sanitize_releases(input_list):
    return sanitize_list(input_list, "\\*|Release\\s*[0-9A-Z]|My\\s*Release")


def sanitize_lifecycles(input_list):
    return sanitize_list(input_list, "\\*|Lifecycle\\s*[0-9A-Z]|My\\s*Lifecycle")


def sanitize_certificates(input_list):
    return sanitize_list(input_list, "\\*|Certificate\\s*[0-9A-Z]|My\\s*Certificate")


def sanitize_environments(input_list):
    return sanitize_list(input_list, "\\*|Environment\\s*[0-9A-Z]|My\\s*Environment")


def sanitize_targets(input_list):
    return sanitize_list(input_list,
                         "\\*|Machine\\s*[0-9A-Z]|Target\\s*[0-9A-Z]|My\\s*Machine|My\\s*Target")


def sanitize_runbooks(input_list):
    return sanitize_list(input_list, "\\*|Runbook\\s*[0-9A-Z]|My\\s*Runbook")


def sanitize_library_variable_sets(input_list):
    return sanitize_list(input_list,
                         "\\*|(Library\\s*)?Variable\\s*Set\\s*[0-9A-Z]|Variables|My\\s*Variable\\s*Set")


def sanitize_bool(input_bool):
    if isinstance(input_bool, bool):
        return input_bool
    return False


def none_if_falesy(input_list):
    if not input_list:
        return None
    return input_list


def sanitize_list(input_list, ignored_re=None):
    """
    OpenAI can provide some unexpected inputs. This function cleans them up.
    :param input_list: The list to sanitize
    :param ignored_re: A regular expression to match strings that should be ignored
    :return: The sanitized list of strings
    """
    if not input_list:
        return []

    # Treat a string as a list with a single string
    if isinstance(input_list, str):
        if input_list.strip() and not is_re_match(input_list.strip(), ignored_re):
            return [input_list.strip()]
        else:
            return []

    # Sometimes you get a bool or int rather than a list, which we treat as an empty list
    if not isinstance(input_list, list):
        return []

    # Open AI will give you a list with a single asterisk if the list is empty
    return [entry.strip() for entry in input_list if
            isinstance(entry, str) and entry.strip() and not is_re_match(entry, ignored_re)]


def is_re_match(entry, ignored_re):
    if not ignored_re:
        return False

    return re.match(ignored_re, entry)


def get_item_or_none(array, index):
    try:
        return array[index]
    except IndexError:
        return None


def flatten_list(deployments):
    return [item for sublist in deployments for item in sublist]
