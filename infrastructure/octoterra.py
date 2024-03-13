import json

from retry import retry
from urllib3.exceptions import HTTPError

from domain.logging.app_logging import configure_logging
from domain.strings.sanitized_list import sanitize_projects, sanitize_tenants, sanitize_targets, \
    sanitize_runbooks, sanitize_library_variable_sets, sanitize_environments, sanitize_feeds, sanitize_accounts, \
    sanitize_certificates, sanitize_lifecycles, sanitize_workerpools, sanitize_machinepolicies, sanitize_tenanttagsets, \
    sanitize_projectgroups
from domain.validation.argument_validation import ensure_string_not_empty
from infrastructure.http_pool import http
from infrastructure.octopus import handle_response, get_space_id_and_name_from_name

logger = configure_logging(__name__)


@retry(HTTPError, tries=3, delay=2)
def get_octoterra_space(query, space_name, project_names, runbook_names, target_names, tenant_names,
                        library_variable_sets, environment_names, feed_names, account_names, certificate_names,
                        lifecycle_names, workerpool_names, machinepolicy_names, tagset_names, projectgroup_names,
                        api_key, octopus_url):
    """
    Returns the terraform representation of a space
    :param space_name: The name of the space.
    :param project_names: The names of the projects to limit the export to.
    :param api_key: The Octopus API key
    :param octopus_url: The Octopus URL
    :return: The space terraform module
    """
    logger.info("get_octoterra_space - Enter")

    ensure_string_not_empty(space_name, 'space_name must be a non-empty string (get_octoterra_space).')
    ensure_string_not_empty(query, 'query must be a non-empty string (get_octoterra_space).')
    ensure_string_not_empty(api_key, 'api_key must be a non-empty string (get_octoterra_space).')
    ensure_string_not_empty(octopus_url, 'octopus_url must be a non-empty string (get_octoterra_space).')

    space_id, actual_space_name = get_space_id_and_name_from_name(space_name, api_key, octopus_url)

    # We want to restrict the size of the exported Terraform configuration as much as possible,
    # so we make heavy use of the options to exclude resources unless they were mentioned in the query.
    sanitized_project_names = sanitize_projects(project_names)
    sanitized_tenant_names = sanitize_tenants(tenant_names)
    sanitized_target_names = sanitize_targets(target_names)
    sanitized_runbook_names = sanitize_runbooks(runbook_names)
    sanitized_library_variable_sets = sanitize_library_variable_sets(library_variable_sets)
    sanitized_environments = sanitize_environments(environment_names)
    sanitized_feeds = sanitize_feeds(feed_names)
    sanitized_accounts = sanitize_accounts(account_names)
    sanitized_certificates = sanitize_certificates(certificate_names)
    sanitized_lifecycles = sanitize_lifecycles(lifecycle_names)
    sanitized_workerpools = sanitize_workerpools(workerpool_names)
    sanitized_machinepolicies = sanitize_machinepolicies(machinepolicy_names)
    sanitized_tagsets = sanitize_tenanttagsets(tagset_names)
    sanitized_projectgroups = sanitize_projectgroups(projectgroup_names)

    exclude_targets = True if not sanitized_target_names and "target" not in query.lower() and "machine" not in query.lower() else False
    exclude_runbooks = True if not sanitized_runbook_names and "runbook" not in query.lower() else False
    exclude_tenants = True if not sanitized_tenant_names and "tenant" not in query.lower() else False
    exclude_projects = True if not sanitized_project_names and "project" not in query.lower() else False
    exclude_library_variable_sets = True if not sanitized_library_variable_sets and "library variable set" not in query.lower() else False
    exclude_environments = True if not sanitized_environments and "environment" not in query.lower() else False
    exclude_feeds = True if not sanitized_feeds and "feed" not in query.lower() else False
    exclude_accounts = True if not sanitized_accounts and "account" not in query.lower() else False
    exclude_certificates = True if not sanitized_certificates and "certificate" not in query.lower() else False
    exclude_lifecycles = True if not sanitized_lifecycles and "lifecycle" not in query.lower() else False
    exclude_workerpools = True if not sanitized_workerpools and "workerpool" not in query.lower() else False
    exclude_machinepolicies = True if not sanitized_machinepolicies and "policy" not in query.lower() else False
    exclude_tagsets = True if not sanitized_tagsets and "tag" not in query.lower() else False
    exclude_projectgroups = True if not sanitized_projectgroups and "group" not in query.lower() else False

    body = {
        "space": space_id,
        "url": octopus_url,
        "apiKey": api_key,
        "ignoreCacManagedValues": False,
        "excludeCaCProjectSettings": True,
        "excludeProjectsExcept": sanitized_project_names if sanitized_project_names else None,
        "excludeTenantsExcept": sanitized_tenant_names if sanitized_tenant_names else None,
        "excludeEnvironmentsExcept": sanitized_environments if sanitized_environments else None,
        "excludeFeedsExcept": sanitized_feeds if sanitized_feeds else None,
        "excludeAccountsExcept": sanitized_accounts if sanitized_accounts else None,
        "excludeCertificatesExcept": sanitized_certificates if sanitized_certificates else None,
        "excludeLifecyclesExcept": sanitized_lifecycles if sanitized_lifecycles else None,
        "excludeWorkerPoolsExcept": sanitized_workerpools if sanitized_workerpools else None,
        "excludeMachinePoliciesExcept": exclude_machinepolicies if exclude_machinepolicies else None,
        "excludeTagSetsExcept": sanitized_tagsets if sanitized_tagsets else None,
        "excludeProjectGroupsExcept": exclude_projectgroups if sanitized_tagsets else None,
        "excludeAllProjects": exclude_projects,
        "excludeAllTenant": exclude_tenants,
        "excludeAllTargets": exclude_targets,
        "excludeAllRunbooks": exclude_runbooks,
        "excludeAllFeeds": exclude_feeds,
        "excludeAllAccounts": exclude_accounts,
        "excludeAllEnvironments": exclude_environments,
        "excludeAllCertificates": exclude_certificates,
        "excludeAllLifecycles": exclude_lifecycles,
        "excludeAllWorkerPools": exclude_workerpools,
        "excludeAllMachinePolicies": exclude_machinepolicies,
        "excludeAllTagSets": exclude_tagsets,
        "excludeAllprojectGroups": exclude_projectgroups,
        "excludeAllLibraryVariableSets": exclude_library_variable_sets,
        "limitAttributeLength": 100,
        # This setting ensures that any project, tenant, runbook, or target names are valid.
        # If not, the assumption is made that the LLM incorrectly identified the resource in the query,
        # and the results must not be limited by that incorrect assumption.
        "ignoreInvalidExcludeExcept": True,
        "excludeTerraformVariables": True,
        "excludeSpaceCreation": True,
        "excludeProvider": True,
    }

    resp = handle_response(lambda: http.request("POST",
                                                "https://octoterraproduction.azurewebsites.net/api/octoterra",
                                                body=json.dumps(body)))

    return resp.data.decode("utf-8")
