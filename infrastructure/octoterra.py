import json
import os

from retry import retry
from urllib3.exceptions import HTTPError

from domain.config.openai import max_context
from domain.logging.app_logging import configure_logging
from domain.query.query_inspector import exclude_all_targets, exclude_all_runbooks, exclude_all_tenants, \
    exclude_all_projects, exclude_all_library_variable_sets, exclude_all_environments, exclude_all_feeds, \
    exclude_all_accounts, exclude_all_certificates, exclude_all_lifecycles, exclude_all_worker_pools, \
    exclude_all_machine_policies, exclude_all_tagsets, exclude_all_project_groups, exclude_all_steps, \
    exclude_all_variables
from domain.sanitizers.sanitized_list import sanitize_projects, sanitize_tenants, sanitize_targets, \
    sanitize_runbooks, sanitize_library_variable_sets, sanitize_environments, sanitize_feeds, sanitize_accounts, \
    sanitize_certificates, sanitize_lifecycles, sanitize_workerpools, sanitize_machinepolicies, sanitize_tenanttagsets, \
    sanitize_projectgroups, none_if_falesy, sanitize_steps, none_if_falesy_or_all, sanitize_variables
from domain.validation.argument_validation import ensure_string_not_empty
from infrastructure.http_pool import http
from infrastructure.octopus import handle_response, logging_wrapper

logger = configure_logging(__name__)


@retry(HTTPError, tries=3, delay=2)
@logging_wrapper
def get_octoterra_space(query, space_id, project_names, runbook_names, target_names, tenant_names,
                        library_variable_sets, environment_names, feed_names, account_names, certificate_names,
                        lifecycle_names, workerpool_names, machinepolicy_names, tagset_names, projectgroup_names,
                        step_names, variable_names, api_key, octopus_url):
    """
    Returns the terraform representation of a space
    :param space_id: The ID of the space.
    :param project_names: The names of the projects to limit the export to.
    :param api_key: The Octopus API key
    :param octopus_url: The Octopus URL
    :return: The space terraform module
    """

    ensure_string_not_empty(space_id, 'space_id must be a non-empty string (get_octoterra_space).')
    ensure_string_not_empty(query, 'query must be a non-empty string (get_octoterra_space).')
    ensure_string_not_empty(api_key, 'api_key must be a non-empty string (get_octoterra_space).')
    ensure_string_not_empty(octopus_url, 'octopus_url must be a non-empty string (get_octoterra_space).')

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
    sanitized_step_names = sanitize_steps(step_names)
    sanitized_variable_names = sanitize_variables(variable_names)

    exclude_targets_with_no_environments = len(sanitized_environments) != 0

    # This is a list of the resources that are set to all be included in the context.
    # This is usually a sign or a poorly formatted question.
    include_all_resources = []

    exclude_all_projects_value = exclude_all_projects(query, sanitized_project_names)
    exclude_projects_except = none_if_falesy(sanitized_project_names)
    if not exclude_all_projects_value and not exclude_projects_except:
        include_all_resources.append("projects")

    exclude_all_tenants_value = exclude_all_tenants(query, sanitized_tenant_names)
    exclude_tenants_except = none_if_falesy(sanitized_tenant_names)
    if not exclude_all_tenants_value and not exclude_projects_except:
        include_all_resources.append("tenants")

    exclude_all_targets_value = exclude_all_targets(query, sanitized_target_names)
    exclude_targets_except = none_if_falesy(sanitized_target_names)
    if not exclude_all_targets_value and not exclude_targets_except:
        include_all_resources.append("targets")

    exclude_all_environments_value = exclude_all_environments(query, sanitized_environments)
    exclude_environments_except = none_if_falesy_or_all(sanitized_environments)
    if not exclude_all_environments_value and not exclude_environments_except:
        include_all_resources.append("environments")

    exclude_all_feeds_value = exclude_all_feeds(query, sanitized_feeds)
    exclude_feeds_except = none_if_falesy(sanitized_feeds)
    if not exclude_all_feeds_value and not exclude_feeds_except:
        include_all_resources.append("feeds")

    exclude_all_accounts_value = exclude_all_accounts(query, sanitized_accounts)
    exclude_accounts_except = none_if_falesy(sanitized_accounts)
    if not exclude_all_accounts_value and not exclude_accounts_except:
        include_all_resources.append("accounts")

    exclude_all_certificates_value = exclude_all_certificates(query, sanitized_certificates)
    exclude_certificates_except = none_if_falesy(sanitized_certificates)
    if not exclude_all_certificates_value and not exclude_certificates_except:
        include_all_resources.append("certificates")

    exclude_all_lifecycles_value = exclude_all_lifecycles(query, sanitized_lifecycles)
    exclude_lifecycles_except = none_if_falesy(sanitized_lifecycles)
    if not exclude_all_lifecycles_value and not exclude_lifecycles_except:
        include_all_resources.append("lifecycles")

    exclude_all_workerpools_value = exclude_all_worker_pools(query, sanitized_workerpools)
    exclude_workerpools_except = none_if_falesy(sanitized_workerpools)
    if not exclude_all_workerpools_value and not exclude_workerpools_except:
        include_all_resources.append("worker pools")

    exclude_all_machinepolicies_value = exclude_all_machine_policies(query, sanitized_machinepolicies)
    exclude_machinepolicies_except = none_if_falesy(sanitized_machinepolicies)
    if not exclude_all_machinepolicies_value and not exclude_machinepolicies_except:
        include_all_resources.append("machine policies")

    exclude_all_runbooks_value = exclude_all_runbooks(query, sanitized_runbook_names)
    exclude_runbooks_except = none_if_falesy(sanitized_runbook_names)
    if not exclude_all_runbooks_value and not exclude_runbooks_except:
        include_all_resources.append("runbooks")

    exclude_all_projectgroups_value = exclude_all_project_groups(query, sanitized_projectgroups)
    exclude_projectgroups_except = none_if_falesy(sanitized_projectgroups)
    if not exclude_all_projectgroups_value and not exclude_projectgroups_except:
        include_all_resources.append("project groups")

    exclude_all_projectvariables_value = exclude_all_variables(query, sanitized_variable_names)
    exclude_projectvariables_except = none_if_falesy_or_all(sanitized_variable_names)
    if not exclude_all_projectvariables_value and not exclude_projectvariables_except:
        include_all_resources.append("project variables")

    exclude_all_libraryvariablesets_value = exclude_all_library_variable_sets(query, sanitized_library_variable_sets)
    exclude_libraryvariablesets_except = none_if_falesy_or_all(sanitized_library_variable_sets)
    if not exclude_all_libraryvariablesets_value and not exclude_libraryvariablesets_except:
        include_all_resources.append("library variable sets")

    exclude_all_tenanttags_value = exclude_all_tagsets(query, sanitized_tagsets)
    exclude_tenanttags_except = none_if_falesy(sanitized_tagsets)
    if not exclude_all_tenanttags_value and not exclude_tenanttags_except:
        include_all_resources.append("tenant tags")

    body = {
        "space": space_id,
        "url": octopus_url,
        "apiKey": api_key,
        "ignoreCacManagedValues": False,
        "excludeCaCProjectSettings": True,
        "excludeProjectsExcept": exclude_projects_except,
        "excludeTenantsExcept": exclude_tenants_except,
        "excludeTargetsExcept": exclude_targets_except,
        "excludeEnvironmentsExcept": exclude_environments_except,
        "excludeFeedsExcept": exclude_feeds_except,
        "excludeAccountsExcept": exclude_accounts_except,
        "excludeCertificatesExcept": exclude_certificates_except,
        "excludeLifecyclesExcept": exclude_lifecycles_except,
        "excludeWorkerPoolsExcept": exclude_workerpools_except,
        "excludeMachinePoliciesExcept": exclude_machinepolicies_except,
        "excludeRunbooksExcept": exclude_runbooks_except,
        "excludeTenantTagSetsExcept": exclude_tenanttags_except,
        "excludeProjectGroupsExcept": exclude_projectgroups_except,
        "excludeLibraryVariableSetsExcept": exclude_libraryvariablesets_except,
        "excludeAllProjects": exclude_all_projects_value,
        "excludeAllTenants": exclude_all_tenants_value,
        "excludeAllTargets": exclude_all_targets_value,
        "excludeAllRunbooks": exclude_all_runbooks_value,
        "excludeAllFeeds": exclude_all_feeds_value,
        "excludeAllAccounts": exclude_all_accounts_value,
        "excludeAllEnvironments": exclude_all_environments_value,
        "excludeAllCertificates": exclude_all_certificates_value,
        "excludeAllLifecycles": exclude_all_lifecycles_value,
        "excludeAllWorkerPools": exclude_all_workerpools_value,
        "excludeAllMachinePolicies": exclude_all_machinepolicies_value,
        "excludeAllTenantTagSets": exclude_all_tenanttags_value,
        "excludeAllProjectGroups": exclude_all_projectgroups_value,
        "excludeAllLibraryVariableSets": exclude_all_libraryvariablesets_value,
        "excludeAllSteps": exclude_all_steps(query, sanitized_step_names),
        "excludeAllProjectVariables": exclude_all_projectvariables_value,
        "excludeProjectVariablesExcept": exclude_projectvariables_except,
        "limitAttributeLength": 100,
        # This setting ensures that any project, tenant, runbook, or target names are valid.
        # If not, the assumption is made that the LLM incorrectly identified the resource in the query,
        # and the results must not be limited by that incorrect assumption.
        "ignoreInvalidExcludeExcept": True,
        "excludeTerraformVariables": True,
        "excludeSpaceCreation": True,
        "excludeProvider": True,
        "includeIds": True,
        "includeSpaceInPopulation": True,
        # If any environments were mentioned, exclude targets that are not linked to the named environments.
        "excludeTargetsWithNoEnvironments": exclude_targets_with_no_environments,
        # Limit the number of resources to prevent the context from filling up and the LLM from
        # having to process more items than it can reasonably process.
        "limitResourceCount": max_context,
        # Include the default channel as a standard resource rather than a data lookup
        "includeDefaultChannel": True,
    }

    resp = handle_response(lambda: http.request("POST",
                                                os.environ["APPLICATION_OCTOTERRA_URL"] + "/api/octoterra",
                                                body=json.dumps(body)))

    answer = resp.data.decode("utf-8")

    # Broad questions are inaccurate, so add a warning when resources are included in the context in bulk.
    if len(include_all_resources) != 0:
        answer += (
                f"\n\nThe following resources were included in bulk in the context of the question: "
                + f"{', '.join(include_all_resources)}."
                + "\nThis occurs when a specific resource name is not included in the question."
                + f"\nThe AI agent will only process {max_context} resources of each type "
                + f"(i.e. {max_context} projects, {max_context} accounts etc.), "
                + "meaning broad questions in large spaces results in many resources being ignored."
                + "\nIncluding the names of specific resources in the question results in a more accurate answer."
                + "\nSee https://github.com/OctopusSolutionsEngineering/OctopusCopilot/wiki/Prompt-Engineering-with-Octopus for more details.")

    return answer
