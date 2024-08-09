import json
import uuid

from domain.lookup.octopus_lookups import lookup_space, lookup_projects, lookup_environments, lookup_tenants
from domain.performance.timing import timing_wrapper
from domain.response.copilot_response import CopilotResponse
from domain.sanitizers.sanitized_list import get_item_or_none
from domain.tools.debug import get_params_message
from domain.validation.octopus_validation import is_task_interruption_valid
from infrastructure.callbacks import save_callback
from infrastructure.octopus import get_project, get_deployment_logs, get_task_interruptions, \
    approve_manual_intervention_for_task, get_teams


def approve_manual_intervention_confirm_callback_wrapper(github_user, url, api_key, log_query):
    def approve_manual_intervention_confirm_callback(space_id, project_name, project_id, release_version,
                                                     environment_name, tenant_name, deployment_id, task_id):
        debug_text = get_params_message(github_user, True,
                                        approve_manual_intervention_confirm_callback.__name__,
                                        space_id=space_id,
                                        project_name=project_name,
                                        project_id=project_id,
                                        release_version=release_version,
                                        environment_name=environment_name,
                                        tenant_name=tenant_name,
                                        deployment_id=deployment_id,
                                        task_id=task_id)

        log_query("approve_manual_intervention_confirm_callback", f"""
            Space Id: {space_id}
            Project Name: {project_name}
            Project Id: {project_id}
            Version: {release_version}
            Environment Name: {environment_name}
            Tenant Name: {tenant_name}
            Deployment Id: {deployment_id}
            Task Id: {task_id}""")

        approval_response, error_message = approve_manual_intervention_for_task(
            space_id,
            project_id,
            release_version,
            environment_name,
            tenant_name,
            task_id,
            api_key,
            url)

        if approval_response is None:
            response = f"Unable to approve manual intervention. Please check and retry\n\n[View task]({url}/app#/{space_id}/tasks/{task_id}"
            if error_message:
                response = f"\n\n{error_message}"
            return CopilotResponse(response)

        response_text = [
            f"{project_name}\n\n☑️ Manual intervention approved\n\n[View task]({url}/app#/{space_id}/tasks/{approval_response['TaskId']})"]

        debug_text.extend(get_params_message(github_user, False,
                                             approve_manual_intervention_confirm_callback.__name__,
                                             space_id=space_id,
                                             project_name=project_name,
                                             project_id=project_id,
                                             release_version=release_version,
                                             environment_name=environment_name,
                                             task_id=approval_response['TaskId']))

        response_text.extend(debug_text)
        return CopilotResponse("\n\n".join(response_text))

    return approve_manual_intervention_confirm_callback


def approve_manual_intervention_wrapper(url, api_key, github_user, original_query, connection_string, log_query):
    def approve_manual_intervention(space_name=None, project_name=None, release_version=None, environment_name=None,
                                    tenant_name=None, **kwargs):
        """
        Approves a manual intervention request

        Args:
        space_name: The name of the space
        project_name: The name of the project
        release_version: The release version
        environment_name: The name of the environment
        tenant_name: The (optional) name of the tenant
        """
        for key, value in kwargs.items():
            if log_query:
                log_query(f"Unexpected Key: {key}", "Value: {value}")

        debug_text = get_params_message(github_user, True,
                                        approve_manual_intervention.__name__,
                                        space_name=space_name,
                                        project_name=project_name,
                                        release_version=release_version,
                                        environment_name=environment_name,
                                        tenant_name=tenant_name)

        space_id, actual_space_name, warnings = lookup_space(url, api_key, github_user, original_query, space_name)
        sanitized_project_names, sanitized_projects = lookup_projects(url, api_key, github_user, original_query,
                                                                      space_id, project_name)

        if not release_version:
            return CopilotResponse("Please specify a release version in the query.")

        if not sanitized_project_names:
            return CopilotResponse("Please specify a project name in the query.")

        project = get_project(space_id, sanitized_project_names[0], api_key, url)

        sanitized_environment_names = lookup_environments(url, api_key, github_user, original_query, space_id,
                                                          environment_name)

        if not sanitized_environment_names:
            return CopilotResponse("Please specify an environment name in the query.")

        sanitized_tenant_names = lookup_tenants(url, api_key, github_user, original_query, space_id, tenant_name)

        # Find matching task
        task, activity_logs, actual_release_version = timing_wrapper(
            lambda: get_deployment_logs(
                space_name,
                sanitized_project_names[0],
                sanitized_environment_names[0],
                get_item_or_none(sanitized_tenant_names, 0),
                release_version,
                api_key,
                url),
            "Deployment logs")

        query_details = [f"\n* Project: **{sanitized_project_names[0]}**"
                         f"\n* Version: **{release_version}**"
                         f"\n* Environment: **{sanitized_environment_names[0]}**"]
        if sanitized_tenant_names:
            query_details.append(f"\n* Tenant: **{sanitized_tenant_names[0]}**")

        query_details.append(f"\n* Space: **{actual_space_name}**\n\n")

        if task is None:
            response = ["⚠️ No task found for:"]
            response.extend(warnings)
            response.extend(debug_text)
            return CopilotResponse("".join(response))

        interruptions = None
        if task['HasPendingInterruptions']:
            interruptions = get_task_interruptions(space_id, task['Id'], api_key, url)

            teams = get_teams(space_id, api_key, url)
            valid, error_response = is_task_interruption_valid(actual_space_name,
                                                               space_id,
                                                               sanitized_project_names[0],
                                                               release_version,
                                                               sanitized_environment_names[0],
                                                               sanitized_tenant_names[0] if sanitized_tenant_names else None,
                                                               task['Id'],
                                                               interruptions,
                                                               teams,
                                                               url)
            if not valid:
                response = [error_response]
                response.extend(warnings)
                response.extend(debug_text)
                return CopilotResponse("".join(response))

        else:
            response = ["⚠️ No pending manual interventions found for:"]
            response.extend(query_details)
            response.extend(warnings)
            response.extend(debug_text)
            return CopilotResponse("".join(response))

        instructions = None
        if interruptions is not None:
            interruption = interruptions[0]
            interruption_elements = interruption['Form']['Elements']
            instruction_element = [interruption_element for interruption_element in interruption_elements if
                                   interruption_element['Name'] == "Instructions"]
            if len(instruction_element) > 0:
                instructions = instruction_element[0]['Control']['Text']

        callback_id = str(uuid.uuid4())

        arguments = {
            "space_id": space_id,
            "project_name": sanitized_project_names[0],
            "project_id": task['ProjectId'],
            "release_version": release_version,
            "environment_name": sanitized_environment_names[0],
            "tenant_name": sanitized_tenant_names[0] if sanitized_tenant_names else None,
            "deployment_id": task['Arguments']['DeploymentId'],
            "task_id": task['Id']
        }

        log_query("manual_intervention", f"""
            Space: {arguments["space_id"]}
            Project Name: {arguments["project_name"]}
            Project Id: {arguments["project_id"]}
            Version: {arguments["release_version"]}
            Environment Name: {arguments["environment_name"]}
            Tenant Name: {arguments["tenant_name"]}
            Deployment Id: {arguments["deployment_id"]}
            Task Id: {arguments["task_id"]}""")

        debug_text.extend(get_params_message(github_user, False,
                                             approve_manual_intervention.__name__,
                                             space_name=actual_space_name,
                                             space_id=space_id,
                                             project_name=sanitized_project_names,
                                             project_id=project['Id'],
                                             release_version=release_version,
                                             environment_name=sanitized_environment_names,
                                             task_id=task['Id']))

        save_callback(github_user,
                      approve_manual_intervention.__name__,
                      callback_id,
                      json.dumps(arguments),
                      original_query,
                      connection_string)

        response = ["Manual intervention"]
        response.extend(warnings)
        response.extend(debug_text)

        prompt_title = "Do you want to approve the manual intervention?"
        prompt_message = ["Please confirm the details below are correct before proceeding:"
                          f"\n* Project: **{sanitized_project_names[0]}**"
                          f"\n* Version: **{release_version}**"
                          f"\n* Environment: **{sanitized_environment_names[0]}**"]
        if sanitized_tenant_names:
            prompt_message.append(f"\n* Tenant: **{sanitized_tenant_names[0]}**")
        prompt_message.append(f"\n* Space: **{actual_space_name}**")
        if instructions:
            prompt_message.append(f"\n* Instructions: *{instructions}*")

        return CopilotResponse("\n\n".join(response), prompt_title, "".join(prompt_message), callback_id)

    return approve_manual_intervention
