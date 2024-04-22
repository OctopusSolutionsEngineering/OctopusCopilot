from domain.validation.argument_validation import ensure_string


def exclude_all_targets(query, entity_list):
    """
    Determines if the query indicates if all targets should be excluded.
    :param query: The user's query
    :param entity_list: The list of targets extracted from the query
    :return: True if all targets should be excluded, False otherwise
    """

    ensure_string(query, 'query must be a string (exclude_all_targets).')

    return True if (not entity_list
                    and "target" not in query.lower()
                    and "machine" not in query.lower()
                    and "agent" not in query.lower()
                    and "listening" not in query.lower()
                    and "ssh" not in query.lower()
                    and "cloud region" not in query.lower()
                    and "cloudregion" not in query.lower()
                    and "kubernetes" not in query.lower()
                    and "ecs" not in query.lower()
                    and "web app" not in query.lower()
                    and "webapp" not in query.lower()
                    and "service fabric" not in query.lower()
                    and "servicefabric" not in query.lower()
                    and "polling" not in query.lower()) else False


def exclude_all_runbooks(query, entity_list):
    """
    Determines if the query indicates if all runbooks should be excluded.
    :param query: The user's query
    :param entity_list: The list of runbooks extracted from the query
    :return: True if all runbooks should be excluded, False otherwise
    """

    ensure_string(query, 'query must be a string (exclude_all_runbooks).')

    return True if not entity_list and "runbook" not in query.lower() else False


def exclude_all_tenants(query, entity_list):
    """
    Determines if the query indicates if all tenants should be excluded.
    :param query: The user's query
    :param entity_list: The list of tenants extracted from the query
    :return: True if all tenants should be excluded, False otherwise
    """

    ensure_string(query, 'query must be a string (exclude_all_tenants).')

    return True if not entity_list and "tenant" not in query.lower() else False


def exclude_all_projects(query, entity_list):
    """
    Determines if the query indicates if all projects should be excluded.
    :param query: The user's query
    :param entity_list: The list of projects extracted from the query
    :return: True if all projects should be excluded, False otherwise
    """

    ensure_string(query, 'query must be a string (exclude_all_projects).')

    return True if not entity_list and "project" not in query.lower() else False


def exclude_all_library_variable_sets(query, entity_list):
    """
    Determines if the query indicates if all variable sets should be excluded.
    :param query: The user's query
    :param entity_list: The list of variable sets extracted from the query
    :return: True if all variable sets should be excluded, False otherwise
    """

    ensure_string(query, 'query must be a string (exclude_all_library_variable_sets).')

    return True if not entity_list and "library variable set" not in query.lower() else False


def exclude_all_environments(query, entity_list):
    """
    Determines if the query indicates if all environments should be excluded.
    :param query: The user's query
    :param entity_list: The list of environments extracted from the query
    :return: True if all environments should be excluded, False otherwise
    """

    ensure_string(query, 'query must be a string (exclude_all_environments).')

    if entity_list and "<all>" in entity_list:
        return False
    return True if not entity_list and "environment" not in query.lower() else False


def exclude_all_feeds(query, entity_list):
    """
    Determines if the query indicates if all feeds should be excluded.
    :param query: The user's query
    :param entity_list: The list of feeds extracted from the query
    :return: True if all feeds should be excluded, False otherwise
    """

    ensure_string(query, 'query must be a string (exclude_all_feeds).')

    return True if not entity_list and "feed" not in query.lower() else False


def exclude_all_accounts(query, entity_list):
    """
    Determines if the query indicates if all accounts should be excluded.
    :param query: The user's query
    :param entity_list: The list of accounts extracted from the query
    :return: True if all accounts should be excluded, False otherwise
    """

    ensure_string(query, 'query must be a string (exclude_all_accounts).')

    return True if not entity_list and "account" not in query.lower() else False


def exclude_all_certificates(query, entity_list):
    """
    Determines if the query indicates if all certificates should be excluded.
    :param query: The user's query
    :param entity_list: The list of certificates extracted from the query
    :return: True if all certificates should be excluded, False otherwise
    """

    ensure_string(query, 'query must be a string (exclude_all_certificates).')

    return True if not entity_list and "certificate" not in query.lower() else False


def exclude_all_lifecycles(query, entity_list):
    """
    Determines if the query indicates if all lifecycles should be excluded.
    :param query: The user's query
    :param entity_list: The list of lifecycles extracted from the query
    :return: True if all lifecycles should be excluded, False otherwise
    """

    ensure_string(query, 'query must be a string (exclude_all_lifecycles).')

    return True if not entity_list and "lifecycle" not in query.lower() else False


def exclude_all_worker_pools(query, entity_list):
    """
    Determines if the query indicates if all worker pools should be excluded.
    :param query: The user's query
    :param entity_list: The list of worker pools extracted from the query
    :return: True if all worker pools should be excluded, False otherwise
    """

    ensure_string(query, 'query must be a string (exclude_all_worker_pools).')

    return True if not entity_list and "worker pool" not in query.lower() else False


def exclude_all_machine_policies(query, entity_list):
    """
    Determines if the query indicates if all machine policies should be excluded.
    :param query: The user's query
    :param entity_list: The list of machine policies extracted from the query
    :return: True if all machine policies should be excluded, False otherwise
    """

    ensure_string(query, 'query must be a string (exclude_all_machine_policies).')

    return True if not entity_list and "policy" not in query.lower() else False


def exclude_all_tagsets(query, entity_list):
    """
    Determines if the query indicates if all tag sets should be excluded.
    :param query: The user's query
    :param entity_list: The list of tag sets extracted from the query
    :return: True if all tag sets should be excluded, False otherwise
    """

    ensure_string(query, 'query must be a string (exclude_all_tagsets).')

    return True if not entity_list and "tag" not in query.lower() else False


def exclude_all_project_groups(query, entity_list):
    """
    Determines if the query indicates if all project groups should be excluded.
    :param query: The user's query
    :param entity_list: The list of project groups extracted from the query
    :return: True if all project groups should be excluded, False otherwise
    """

    ensure_string(query, 'query must be a string (exclude_all_project_groups).')

    return True if not entity_list and "group" not in query.lower() else False


def exclude_all_steps(query, entity_list):
    """
    Determines if the query indicates if all project steps should be excluded.
    :param query: The user's query
    :param entity_list: The list of project steps extracted from the query
    :return: True if all project steps should be excluded, False otherwise
    """

    ensure_string(query, 'query must be a string (exclude_all_steps).')

    return True if not entity_list and "step" not in query.lower() else False


def exclude_all_variables(query, entity_list):
    """
    Determines if the query indicates if all variables should be excluded.
    :param query: The user's query
    :param entity_list: The list of variables extracted from the query
    :return: True if all variables should be excluded, False otherwise
    """

    ensure_string(query, 'query must be a string (exclude_all_variables).')

    if entity_list and "<all>" in entity_list:
        return False
    return True if not entity_list and "variable" not in query.lower() else False


def release_is_latest(release_version):
    """
    Determines if the query indicates it is talking about the latest release
    :param release_version: The release version
    :return: True if all variables should be excluded, False otherwise
    """

    ensure_string(release_version, 'release_version must be a string (release_is_latest).')

    phrases = ["latest", "last", "most recent"]
    return not release_version or not release_version.strip() or release_version.casefold() in phrases
