def exclude_all_targets(query, entity_list):
    return True if not entity_list and "target" not in query.lower() and "machine" not in query.lower() else False


def exclude_all_runbooks(query, entity_list):
    return True if not entity_list and "runbook" not in query.lower() else False


def exclude_all_tenants(query, entity_list):
    return True if not entity_list and "tenant" not in query.lower() else False


def exclude_all_projects(query, entity_list):
    return True if not entity_list and "project" not in query.lower() else False


def exclude_all_library_variable_sets(query, entity_list):
    return True if not entity_list and "library variable set" not in query.lower() else False


def exclude_all_environments(query, entity_list):
    return True if not entity_list and "environment" not in query.lower() else False


def exclude_all_feeds(query, entity_list):
    return True if not entity_list and "feed" not in query.lower() else False


def exclude_all_accounts(query, entity_list):
    return True if not entity_list and "account" not in query.lower() else False


def exclude_all_certificates(query, entity_list):
    return True if not entity_list and "certificate" not in query.lower() else False


def exclude_all_lifecycles(query, entity_list):
    return True if not entity_list and "lifecycle" not in query.lower() else False


def exclude_all_worker_pools(query, entity_list):
    return True if not entity_list and "workerpool" not in query.lower() else False


def exclude_all_machine_policies(query, entity_list):
    return True if not entity_list and "policy" not in query.lower() else False


def exclude_all_tagsets(query, entity_list):
    return True if not entity_list and "tag" not in query.lower() else False


def exclude_all_project_groups(query, entity_list):
    return True if not entity_list and "group" not in query.lower() else False


def release_is_latest(release_version):
    phrases = ["latest", "last", "most recent"]
    return not release_version or release_version.casefold() in phrases
