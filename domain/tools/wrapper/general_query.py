from pydantic import BaseModel

from domain.messages.general import build_hcl_prompt
from domain.sanitizers.sanitized_list import (
    sanitize_projects,
    sanitize_runbooks,
    sanitize_targets,
    sanitize_tenants,
    sanitize_library_variable_sets,
    sanitize_environments,
    sanitize_feeds,
    sanitize_accounts,
    sanitize_certificates,
    sanitize_lifecycles,
    sanitize_workerpools,
    sanitize_machinepolicies,
    sanitize_tenanttagsets,
    sanitize_projectgroups,
    sanitize_channels,
    sanitize_releases,
    sanitize_steps,
    sanitize_gitcredentials,
    sanitize_space,
    sanitize_dates,
)


def answer_general_query_wrapper(query, callback, logging=None):
    def answer_general_query(
        space=None,
        projects=None,
        runbooks=None,
        targets=None,
        tenants=None,
        library_variable_sets=None,
        environments=None,
        feeds=None,
        accounts=None,
        certificates=None,
        lifecycles=None,
        worker_pools=None,
        machine_policies=None,
        tag_sets=None,
        project_groups=None,
        channels=None,
        releases=None,
        steps=None,
        variables=None,
        git_credentials=None,
        dates=None,
        **kwargs,
    ):
        """Inspect the configuration or state of an Octopus space.
        You will be penalized for selecting this function if a more specific function is available,
        or for releases, deployments, and cancelling tasks.
        Args:
        space: Space name
        projects: project names
        runbooks: runbook names
        targets: target/machine names
        tenants: tenant names
        library_variable_sets: library variable set names
        environments: environment names
        feeds: feed names
        accounts: account names
        certificates: certificate names
        lifecycles: lifecycle names
        worker_pools: worker pool names
        machine_policies: machine policy names
        tag_sets: tenant tag set names
        project_groups: project group names
        channels: channel names
        releases: release versions
        steps: step names
        variables: variable names
        git_credentials: git credential names
        dates: individual dates in the query"""

        if logging:
            logging("Enter:", "answer_general_query")

        # This function acts as a way to extract the names of resources that are important to an Octopus query. The
        # resource names map to resources into the API that need to be queried and exposed for context to answer
        # a general question. So the only thing this function does is make another request to the LLM after
        # extracting the relevant entities from the Octopus API.

        # OpenAI will inject values for some of these lists despite the fact that there was no mention
        # of these resources anywhere in the question. We clean up the results before sending them back
        # to the client.
        body = {
            "space_name": sanitize_space(query, space),
            "project_names": sanitize_projects(projects),
            "runbook_names": sanitize_runbooks(runbooks),
            "target_names": sanitize_targets(targets),
            "tenant_names": sanitize_tenants(tenants),
            "library_variable_sets": sanitize_library_variable_sets(
                library_variable_sets
            ),
            "environment_names": sanitize_environments(query, environments),
            "feed_names": sanitize_feeds(feeds),
            "account_names": sanitize_accounts(accounts),
            "certificate_names": sanitize_certificates(certificates),
            "lifecycle_names": sanitize_lifecycles(lifecycles),
            "workerpool_names": sanitize_workerpools(worker_pools),
            "machinepolicy_names": sanitize_machinepolicies(machine_policies),
            "tagset_names": sanitize_tenanttagsets(tag_sets),
            "projectgroup_names": sanitize_projectgroups(project_groups),
            "channel_names": sanitize_channels(channels),
            "release_versions": sanitize_releases(releases),
            "step_names": sanitize_steps(steps),
            "variable_names": sanitize_steps(variables),
            "gitcredential_names": sanitize_gitcredentials(git_credentials),
            "dates": sanitize_dates(dates),
        }

        for key, value in kwargs.items():
            if key not in body:
                body[key] = value
            else:
                logging(f"Conflicting Key: {key}", "Value: {value}")

        messages = build_hcl_prompt()

        return callback(query, body, messages)

    return answer_general_query


class AnswerGeneralQuery(BaseModel):
    projects: list[str] = []
    runbooks: list[str] = []
    targets: list[str] = []
    tenants: list[str] = []
    library_variable_sets: list[str] = []
    environments: list[str] = []
    feeds: list[str] = []
    accounts: list[str] = []
    certificates: list[str] = []
    lifecycles: list[str] = []
    worker_pools: list[str] = []
    machine_policies: list[str] = []
    tag_sets: list[str] = []
    project_groups: list[str] = []
