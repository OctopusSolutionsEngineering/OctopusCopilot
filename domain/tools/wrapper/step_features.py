from domain.messages.general import build_hcl_prompt
from domain.sanitizers.sanitized_list import sanitize_projects, sanitize_runbooks, sanitize_targets, sanitize_tenants, \
    sanitize_library_variable_sets, sanitize_environments, sanitize_feeds, sanitize_accounts, sanitize_certificates, \
    sanitize_lifecycles, sanitize_workerpools, sanitize_tenanttagsets, sanitize_steps, sanitize_space, \
    sanitize_machinepolicies, sanitize_projectgroups, sanitize_releases, sanitize_channels, sanitize_gitcredentials, \
    sanitize_dates


def answer_step_features_wrapper(query, callback, logging=None):
    def answer_step_features(space=None, projects=None, runbooks=None, targets=None,
                             tenants=None, library_variable_sets=None, environments=None,
                             feeds=None, accounts=None, certificates=None, lifecycles=None,
                             worker_pools=None, machine_policies=None, tag_sets=None, project_groups=None,
                             channels=None, releases=None, steps=None, variables=None, git_credentials=None, dates=None,
                             **kwargs):
        """A query about step features like retries.
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
tagsets: tenant tag set names
steps: step names
variables: variable names"""

        # Note that the function description does not list every argument because the length of the string
        # causes an error with GPT 3.5. Only the arguments that are relevant to steps are documented. This
        # allows for a longer description of the function in the future.
        # That said, the LLM will often pass in the arguments despite the fact that they are not documented, so we
        # capture them as there is no downside to having more information about the context to build.

        if logging:
            logging("Enter:", "answer_step_features")

        body = {
            "space_name": sanitize_space(query, space),
            "project_names": sanitize_projects(projects),
            "runbook_names": sanitize_runbooks(runbooks),
            "target_names": sanitize_targets(targets),
            "tenant_names": sanitize_tenants(tenants),
            "library_variable_sets": sanitize_library_variable_sets(library_variable_sets),
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
            "dates": sanitize_dates(dates)
        }

        for key, value in kwargs.items():
            if key not in body:
                body[key] = value
            else:
                logging(f"Conflicting Key: {key}", "Value: {value}")

        few_shot = """
Question: Given the HCL representation of a project and its steps, which steps have retries enabled?
HCL: ###
resource "octopusdeploy_project" "test_project" {{
    name = "My Project"
}}
resource "octopusdeploy_deployment_process" "test_project_deployment_process" {{
  project_id = "${{octopusdeploy_project.test_project.id}}"
  step {{
    name = "My Sample Step Parent"
    action {{
      name = "My Sample Step"
      properties = {{
        "Octopus.Action.Script.ScriptBody" = "echo #{{Variable.Test}}"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.AutoRetry.MaximumCount" = "3"
      }}
    }}
  }}
  step {{
    name = "Step 2"
    action {{
      name = "Step 2"
      properties = {{
        "Octopus.Action.Script.ScriptBody" = "echo #{{AnotherVariable}}\\necho #{{SecretVariable}}"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.Azure.AccountId" = "Azure.Account"
      }}
    }}
  }}
  step {{
    name = "Retry the login"
    action {{
      name = "Retry the login"
      properties = {{
        "Octopus.Action.Script.ScriptBody" = "echo #{{AnotherVariable}}\\necho #{{SecretVariable}}"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.Azure.AccountId" = "Azure.Account"
      }}
    }}
  }}
  step {{
    name = "Restart the service"
    action {{
      name = "Restart the service"
      description = "This step has retries enabled"
      properties = {{
        "Octopus.Action.Script.ScriptBody" = "echo #{{AnotherVariable}}\\necho #{{SecretVariable}}"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.Azure.AccountId" = "Azure.Account"
      }}
    }}
  }}
}}
###
Answer:
The action with the name "My Sample Step" has a property called "Octopus.Action.AutoRetry.MaximumCount" set to "3". Because the "Octopus.Action.AutoRetry.MaximumCount" property is greater than 0, this action has step reties enabled.
The action with the name "Step 2" does not have a property called "Octopus.Action.AutoRetry.MaximumCount" defined. Because the "Octopus.Action.AutoRetry.MaximumCount" property is not defined, this action does not have step reties enabled.
The action with the name "Retry the login" does not have a property called "Octopus.Action.AutoRetry.MaximumCount" defined. Because the "Octopus.Action.AutoRetry.MaximumCount" property is not defined, this action does not have step reties enabled.
The action with the name "Restart the service" does not have a property called "Octopus.Action.AutoRetry.MaximumCount" defined. Because the "Octopus.Action.AutoRetry.MaximumCount" property is not defined, this action does not have step reties enabled.

The steps with retries enabled are:
- My Sample Step
"""

        messages = build_hcl_prompt([("user", few_shot)])

        return callback(query, body, messages)

    return answer_step_features
