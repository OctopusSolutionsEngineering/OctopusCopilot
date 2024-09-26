import re
from functools import reduce

from fuzzywuzzy import fuzz

from domain.converters.string_to_int import string_to_int
from domain.date.parse_dates import parse_unknown_format_date
from domain.sanitizers.sanitize_strings import replace_with_empty_string
from domain.transformers.date_convert import datetime_to_str


def sanitize_space(query, input_list):
    input_list = sanitize_list(
        input_list,
        "(?i)Any|all|\\*|Space|Space\\s*[0-9A-Z]|My\\s*Space|current|this|space_name",
    )

    # The LLM will sometimes return the space name of "default" when no specific space is mentioned
    # If the query does not contain "default" or "Default", we ignore the name default.
    if not query or "default" not in query.casefold():
        input_list = sanitize_list(input_list, "(?i)default")

    if len(input_list) > 0:
        return input_list[0]

    return None


def sanitize_projects(input_list):
    return sanitize_list(
        input_list,
        "(?i)Any|all|\\*|Project\\s*[0-9A-Z]|My\\s*Project|project\\d|project_name",
    )


def update_query(original_query, sanitized_projects):
    """
    Replace resource names in the original query with those found by fuzzy matching.
    :param original_query: The original query
    :param sanitized_projects: The output of the sanitize_projects_fuzzy function
    :return: The query with misnamed resources replaced with their fuzzy matches
    """
    return reduce(
        lambda new_query, name_map: new_query.replace(
            name_map["original"], name_map["matched"]
        ),
        sanitized_projects,
        original_query,
    )


def sanitize_names_fuzzy(names_generator, projects):
    """
    Match the list of resources to the closest project names that exist in the space. This allows
    for minor typos in the query. This version uses a generator to avoid loading all the resources
    if there is an exact match within the earlier batch requests.
    :param projects: The list of project names to match
    :param names_generator: The list of resource names from the space
    :return: A list of the closest matching project names from the space
    """
    fuzzy_items = [
        get_item_fuzzy_generator(names_generator, project) for project in projects
    ]
    return [
        {"original": project["original"], "matched": project["matched"]["Name"]}
        for project in fuzzy_items
        if project
    ]


def sanitize_name_fuzzy(names_generator, name):
    """
    Match the resource to the closest project names that exist in the space. This allows
    for minor typos in the query. This version uses a generator to avoid loading all the resources
    if there is an exact match within the earlier batch requests.
    :param name: The resource name
    :param names_generator: The list of resource names from the space
    :return: The closest matching resource names from the space
    """
    if not name:
        return None

    fuzzy_item = get_item_fuzzy_generator(names_generator, name)
    return (
        {"original": fuzzy_item["original"], "matched": fuzzy_item["matched"]["Name"]}
        if fuzzy_item
        else None
    )


def sanitize_tenants(input_list):
    return sanitize_list(
        input_list,
        "(?i)\\.\\*|Any|None|all|\\*|Tenant\\s*[0-9A-Z]|My\\s*Tenant|tenant_name",
    )


def sanitize_feeds(input_list):
    return sanitize_list(
        input_list, "(?i)\\.\\*|Any|None|all|\\*|Feed\\s*[0-9A-Z]|My\\s*Feed|feed_name"
    )


def sanitize_accounts(input_list):
    return sanitize_list(
        input_list,
        "(?i)\\.\\*|Any|None|all|\\*|Account\\s*[0-9A-Z]|My\\s*Account|account_name",
    )


def sanitize_workerpools(input_list):
    return sanitize_list(
        input_list,
        "(?i)\\.\\*|Any|None|all|\\*|Worker\\s*Pool\\s*[0-9A-Z]|My\\s*Worker\\s*Pool|worker_pool_name",
    )


def sanitize_machinepolicies(input_list):
    return sanitize_list(
        input_list,
        "(?i)\\.\\*|Any|None|all|\\*|Machine\\s*Policy\\s*[0-9A-Z]|My\\s*Machine\\s*Policy|machine_policy_name",
    )


def sanitize_tenanttagsets(input_list):
    return sanitize_list(
        input_list,
        "(?i)\\.\\*|Any|None|all|\\*|Tag\\s*Set\\s*[0-9A-Z]|My\\s*Tag\\s*Set|tag_set_name",
    )


def sanitize_gitcredentials(input_list):
    return sanitize_list(
        input_list,
        "(?i)\\.\\*|Any|None|all|\\*|Git\\s*Credential\\s*[0-9A-Z]|My\\s*Git\\s*Credential|cred\\d|git_credential_name",
    )


def sanitize_projectgroups(input_list):
    return sanitize_list(
        input_list,
        "(?i)\\.\\*|Any|None|all|\\*|Project\\s*Group\\s*[0-9A-Z]|My\\s*Project\\s*Group|project_group_name",
    )


def sanitize_channels(input_list):
    return sanitize_list(
        input_list,
        "(?i)\\.\\*|Any|None|all|\\*|Channel\\s*[0-9A-Z]|My\\s*Channel|channel_name",
    )


def sanitize_releases(input_list):
    return sanitize_list(
        input_list,
        "(?i)\\.\\*|Any|None|all|\\*|Release\\s*[0-9A-Z]|My\\s*Release|release_name",
    )


def sanitize_steps(input_list):
    return sanitize_list(
        input_list, "(?i)\\.\\*|Any|None|all|\\*|Step\\s*[0-9A-Z]|My\\s*Step|step_name"
    )


def sanitize_variables(input_list):
    return sanitize_list(
        input_list,
        "(?i)\\.\\*|Any|None|all|\\*|Variable\\s*[0-9A-Z]|My\\s*Variable|var\\d|variable_name",
    )


def sanitize_lifecycles(input_list):
    return sanitize_list(
        input_list,
        "(?i)\\.\\*|Any|None|all|\\*|Lifecycle\\s*[0-9A-Z]|My\\s*Lifecycle|lifecycle_name",
    )


def sanitize_certificates(input_list):
    return sanitize_list(
        input_list,
        "(?i)\\.\\*|Any|None|all|\\*|Certificate\\s*[0-9A-Z]|My\\s*Certificate|certificate_name",
    )


def sanitize_environments(input_query, input_list):
    list = sanitize_list(
        input_list,
        "(?i)\\.\\*|Any|None|all|\\*|Environment\\s*[0-9A-Z]|My\\s*Environment|env\\d|environment_name",
    )
    # The LLM will sometimes return environment names that were never mentioned in the query. I suspect the
    # names comes from the few-shot examples. Every environment needs to be mentioned in the query.
    return [env for env in list if env in input_query]


def sanitize_targets(input_list):
    return sanitize_list(
        input_list,
        "(?i)\\.\\*|Any|None|all|\\*|Machine\\s*[0-9A-Z]|Target\\s*[0-9A-Z]|My\\s*Machine|My\\s*Target|target_name",
    )


def sanitize_runbooks(input_list):
    return sanitize_list(
        input_list,
        "(?i)\\.\\*|Any|None|all|\\*|Runbook\\s*[0-9A-Z]|My\\s*Runbook|runbook_name",
    )


def sanitize_library_variable_sets(input_list):
    return sanitize_list(
        input_list,
        "(?i)\\.\\*|Any|None|all|\\*|(Library\\s*)?Variable\\s*Set\\s*[0-9A-Z]|Variables|My\\s*Variable\\s*Set|library_variable_set_name",
    )


def sanitize_dates(input_list):
    list = [
        replace_with_empty_string(
            date.lower(),
            "after|before|between|on|today|yesterday|tomorrow|last\\s*week|last\\s*month|last\\s*year|next\\s*week|next\\s*month|next\\s*year",
        )
        for date in sanitize_list(input_list)
    ]
    dates = [parse_unknown_format_date(item.strip()) for item in list]
    return [datetime_to_str(date) for date in dates if date]


def sanitize_log_lines(lines, input_query):
    """
    return the lines count if the integer actually appeared in the input query
    :param lines: The lines reported to be in the query
    :param input_query: The actual query
    :return: The number of lines to return or None if the number was not in the query
    """
    return lines if str(lines) in input_query else None


def sanitize_log_steps(input_list, input_query, logs):
    """
    When querying logs, it is handy to limit the logs to the output of certain steps. This is because the LLM sometimes
    has trouble finding information in large log outputs. The steps can either be in int
    index (i.e. a value of 1 returns logs for "Step 1: xxx") or the name of a step (e.g. "Deploy with CLI").
    However, the values returned by the LLM for step names can be a bit off. This function only returns ints or
    step names that are at least an 80% match with the step names in the logs.
    :param input_list: The list of steps to include in the logs
    :param input_query The original query
    :param logs: The log output
    :return: The list of steps that are either ints or steps names that closely match actual logged output
    """
    if not logs:
        return []

    # Early exit if there is nothing to process
    sanitized_steps = force_to_list(input_list)
    if not sanitized_steps:
        return []

    for log_item in logs:
        if log_item.get("Children") and len(log_item["Children"]) != 0:
            # These are the name of the top level log items
            step_names = [
                child_log_item["Name"] for child_log_item in log_item["Children"]
            ]
            # Valid steps names are either ints (less than the number of steps)
            # or something that is at least an 80% match for a step name
            valid_steps = [
                step
                for step in sanitized_steps
                if step_index_is_valid(step, input_query)
                or step_name_is_fuzzy_match(step, step_names)
            ]
            return valid_steps

    return []


def step_index_is_valid(step, input_query):
    """
    The LLM has a habit of inventing a value here. So we check if the step is an integer and that the original
    query included that integer.
    :param step: The step name or index
    :param input_query: The original query
    :return:
    """
    return string_to_int(step) and step in input_query


def step_name_is_fuzzy_match(step_name, step_names):
    return any(
        filter(
            lambda s: fuzz.ratio(
                normalize_log_step_name(step_name), normalize_log_step_name(s)
            )
            > 80,
            step_names,
        )
    )


def normalize_log_step_name(name):
    if not name:
        return ""

    return re.sub(r"Step\s*[0-9]+:\s*", "", name).lower().strip()


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
    if not input_list or not isinstance(input_list, list):
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
    return [
        entry.strip()
        for entry in input_list
        if isinstance(entry, str)
        and entry.strip()
        and not is_re_match(entry, ignored_re)
    ]


def force_to_list(input_list):
    """
    Force an input to a list
    :param input_list: The list to sanitize
    :return: The sanitized list of strings
    """
    if not input_list:
        return []

    # return a list if the input is already a list
    if isinstance(input_list, list):
        return input_list

    # return the string representation of the input in a list
    return [str(input_list)]


def is_re_match(entry, ignored_re):
    if not ignored_re:
        return False

    return re.match(ignored_re, entry)


def get_item_or_none(array, index):
    try:
        if not array:
            return None
        return array[index]
    except IndexError:
        return None


def get_item_or_default(array, index, default):
    try:
        if not array:
            return default
        return array[index]
    except IndexError:
        return default


def get_key_or_none(source, key):
    if not source:
        return None

    return source.get(key)


def flatten_list(deployments):
    return [item for sublist in deployments for item in sublist]


def yield_first(iterable):
    for item in iterable or []:
        yield item
        return


def get_item_fuzzy(items, name):
    """
    Get an item, first using an exact match, then case-insensitive match, then the closest match. Uses lazy evaluation.
    :param items: An iterable collection of items to search through
    :param name: The name of the item to return
    :return: The closest match that could be found in the items
    """

    if not items:
        return None

    if not name:
        return None

    case_sensitive_items = []
    fuzz_match = []

    for item in items:
        if "Name" not in item:
            continue

        if item["Name"] == name:
            return item

        if item["Name"].casefold() == name.casefold():
            case_sensitive_items.append(item)

        fuzz_match.append({"ratio": fuzz.ratio(name, item["Name"]), "item": item})

    if case_sensitive_items:
        return case_sensitive_items[0]

    fuzz_match_sorted = sorted(fuzz_match, key=lambda x: x["ratio"], reverse=True)

    if len(fuzz_match_sorted) != 0:
        return fuzz_match_sorted[0]["item"]

    return None


def get_item_fuzzy_generator(items_generator, name):
    """
    Get an item, first using an exact match, then case-insensitive match, then the closest match.
    This version of the function uses a generator to allow for an early exit if the exact name is found in the early
    batched requests.
    :param items_generator: A function returning the list of items to search through. Ideally this uses batched API
    calls, but this is not a requirement.
    :param name: The name of the item to return
    :return: The closest match that could be found in the items
    """

    case_insensitive = None
    fuzzy_matches = []
    for item in items_generator():
        # Early exit on exact name match. If the generator function uses lazy loading, this can have
        # a performance benefit.
        if item["Name"] == name:
            return {"original": name, "matched": item}

        # Track any case-insensitive matches
        if item["Name"].casefold() == name.casefold():
            case_insensitive = item

        # Calculate the fuzzy match
        ratio = fuzz.ratio(name, item["Name"])
        fuzzy_matches.append({"ratio": ratio, "item": item})

    # In the absence of an exact match, return a case-insensitive match
    if case_insensitive:
        return {"original": name, "matched": case_insensitive}

    # Fall back to the best fuzzy match
    fuzz_match_sorted = sorted(fuzzy_matches, key=lambda x: x["ratio"], reverse=True)

    if len(fuzz_match_sorted) != 0:
        return {"original": name, "matched": fuzz_match_sorted[0]["item"]}

    return None
