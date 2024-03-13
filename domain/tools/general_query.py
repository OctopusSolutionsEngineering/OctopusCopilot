from pydantic import BaseModel

from domain.strings.sanitized_list import sanitize_projects, sanitize_runbooks, sanitize_targets, sanitize_tenants, \
    sanitize_library_variable_sets, sanitize_environments, sanitize_feeds, sanitize_accounts, sanitize_certificates, \
    sanitize_lifecycles, sanitize_workerpools, sanitize_machinepolicies, sanitize_tenanttagsets, sanitize_projectgroups


def answer_general_query_callback(callback):
    def answer_general_query(space=None, projects=None, runbooks=None, targets=None,
                             tenants=None, library_variable_sets=None, environments=None,
                             feeds=None, accounts=None, certificates=None, lifecycles=None,
                             workerpools=None, machinepolicies=None, tagsets=None, projectgroups=None):
        """Answers a general query about an Octopus space.
    
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
        workerpools: worker pool names
        machinepolicies: machine policy names
        tagsets: tenant tag set names
        projectgroups: project group names
        """

        # OpenAI will inject values for some of these lists despite the fact that there was no mention
        # of these resources anywhere in the question. We clean up the results before sending them back
        # to the client.
        body = {
            "space_name": space,
            "project_names": sanitize_projects(projects),
            "runbook_names": sanitize_runbooks(runbooks),
            "target_names": sanitize_targets(targets),
            "tenant_names": sanitize_tenants(tenants),
            "library_variable_sets": sanitize_library_variable_sets(library_variable_sets),
            "environment_names": sanitize_environments(environments),
            "feed_names": sanitize_feeds(feeds),
            "account_names": sanitize_accounts(accounts),
            "certificate_names": sanitize_certificates(certificates),
            "lifecycle_names": sanitize_lifecycles(lifecycles),
            "workerpool_names": sanitize_workerpools(workerpools),
            "machinepolicy_names": sanitize_machinepolicies(machinepolicies),
            "tagset_names": sanitize_tenanttagsets(tagsets),
            "projectgroup_names": sanitize_projectgroups(projectgroups),
        }

        return callback(body)

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
    workerpools: list[str] = []
    machinepolicies: list[str] = []
    tagsets: list[str] = []
    projectgroups: list[str] = []
