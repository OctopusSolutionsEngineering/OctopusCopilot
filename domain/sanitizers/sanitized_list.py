import re

from domain.date.parse_dates import parse_unknown_format_date
from domain.sanitizers.sanitize_strings import replace_with_empty_string
from domain.transformers.date_convert import datetime_to_str


def sanitize_space(input_string):
    input_list = sanitize_list(input_string, "all|\\*|Space|Space\\s*[0-9A-Z]|My\\s*Space")
    if len(input_list) > 0:
        return input_list[0]
    return None


def sanitize_projects(input_list):
    return sanitize_list(input_list, "all|\\*|Project\\s*[0-9A-Z]|My\\s*Project")


def sanitize_tenants(input_list):
    return sanitize_list(input_list, "all|\\*|Tenant\\s*[0-9A-Z]|My\\s*Tenant")


def sanitize_feeds(input_list):
    return sanitize_list(input_list, "all|\\*|Feed\\s*[0-9A-Z]|My\\s*Feed")


def sanitize_accounts(input_list):
    return sanitize_list(input_list, "all|\\*|Account\\s*[0-9A-Z]|My\\s*Account")


def sanitize_workerpools(input_list):
    return sanitize_list(input_list, "all|\\*|Worker\\s*Pool\\s*[0-9A-Z]|My\\s*Worker\\s*Pool")


def sanitize_machinepolicies(input_list):
    return sanitize_list(input_list, "all|\\*|Machine\\s*Policy\\s*[0-9A-Z]|My\\s*Machine\\s*Policy")


def sanitize_tenanttagsets(input_list):
    return sanitize_list(input_list, "all|\\*|Tag\\s*Set\\s*[0-9A-Z]|My\\s*Tag\\s*Set")


def sanitize_gitcredentials(input_list):
    return sanitize_list(input_list, "all|\\*|Git\\s*Credential\\s*[0-9A-Z]|My\\s*Git\\s*Credential")


def sanitize_projectgroups(input_list):
    return sanitize_list(input_list, "all|\\*|Project\\s*Group\\s*[0-9A-Z]|My\\s*Project\\s*Group")


def sanitize_channels(input_list):
    return sanitize_list(input_list, "all|\\*|Channel\\s*[0-9A-Z]|My\\s*Channel")


def sanitize_releases(input_list):
    return sanitize_list(input_list, "all|\\*|Release\\s*[0-9A-Z]|My\\s*Release")


def sanitize_steps(input_list):
    return sanitize_list(input_list, "all|\\*|Step\\s*[0-9A-Z]|My\\s*Step")


def sanitize_variables(input_list):
    return sanitize_list(input_list, "all|\\*|Variable\\s*[0-9A-Z]|My\\s*Variable")


def sanitize_lifecycles(input_list):
    return sanitize_list(input_list, "all|\\*|Lifecycle\\s*[0-9A-Z]|My\\s*Lifecycle")


def sanitize_certificates(input_list):
    return sanitize_list(input_list, "all|\\*|Certificate\\s*[0-9A-Z]|My\\s*Certificate")


def sanitize_environments(input_list):
    return sanitize_list(input_list, "all|\\*|Environment\\s*[0-9A-Z]|My\\s*Environment")


def sanitize_targets(input_list):
    return sanitize_list(input_list,
                         "all|\\*|Machine\\s*[0-9A-Z]|Target\\s*[0-9A-Z]|My\\s*Machine|My\\s*Target")


def sanitize_runbooks(input_list):
    return sanitize_list(input_list, "all|\\*|Runbook\\s*[0-9A-Z]|My\\s*Runbook")


def sanitize_library_variable_sets(input_list):
    return sanitize_list(input_list,
                         "all|\\*|(Library\\s*)?Variable\\s*Set\\s*[0-9A-Z]|Variables|My\\s*Variable\\s*Set")


def sanitize_dates(input_list):
    list = [replace_with_empty_string(date.lower(),
                                      "after|before|between|on|today|yesterday|tomorrow|last\\s*week|last\\s*month|last\\s*year|next\\s*week|next\\s*month|next\\s*year")
            for date in sanitize_list(input_list)]
    dates = [parse_unknown_format_date(item.strip()) for item in list]
    return [datetime_to_str(date) for date in dates if date]


def sanitize_bool(input_bool):
    if isinstance(input_bool, bool):
        return input_bool
    return False


def none_if_falesy(input_list):
    if not input_list:
        return None
    return input_list


def none_if_falesy_or_all(input_list):
    """
    return None if the list is empty or includes a single item of "<all>"
    :param input_list: The list to inspect
    :return: None if the list is empty or includes a single item of "<all>", or the original list otherwise
    """
    if not input_list:
        return None
    if len(input_list) == 1 and input_list[0] == "<all>":
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
