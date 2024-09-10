from domain.context.octopus_context import collect_llm_context
from domain.defaults.defaults import get_default_argument
from domain.response.copilot_response import CopilotResponse
from domain.sanitizers.sanitized_list import (
    sanitize_name_fuzzy,
    sanitize_names_fuzzy,
    sanitize_space,
    sanitize_projects,
    sanitize_environments,
    update_query,
)
from domain.tools.debug import get_params_message
from infrastructure.octopus import (
    get_spaces_generator,
    get_space_id_and_name_from_name,
    get_projects_generator,
)


def general_query_callback(github_user, octopus_details, log_query):
    def general_query_callback_implementation(original_query, body, messages):
        api_key, url = octopus_details()

        debug_text = get_params_message(
            github_user,
            True,
            general_query_callback_implementation.__name__,
            original_query=original_query,
            space_name=body["space_name"],
            project_names=body["project_names"],
            runbook_names=body["runbook_names"],
            target_names=body["target_names"],
            tenant_names=body["tenant_names"],
            library_variable_sets=body["library_variable_sets"],
            environment_names=body["environment_names"],
            feed_names=body["feed_names"],
            account_names=body["account_names"],
            certificate_names=body["certificate_names"],
            lifecycle_names=body["lifecycle_names"],
            workerpool_names=body["workerpool_names"],
            machinepolicy_names=body["machinepolicy_names"],
            tagset_names=body["tagset_names"],
            projectgroup_names=body["projectgroup_names"],
            channel_names=body["channel_names"],
            release_versions=body["release_versions"],
            step_names=body["step_names"],
            variable_names=body["variable_names"],
            dates=body["dates"],
        )

        sanitized_space = sanitize_name_fuzzy(
            lambda: get_spaces_generator(api_key, url),
            sanitize_space(original_query, body["space_name"]),
        )

        space = get_default_argument(
            github_user,
            sanitized_space["matched"] if sanitized_space else None,
            "Space",
        )

        warnings = []

        if not space:
            space = next(get_spaces_generator(api_key, url), {"Name": "Default"}).get(
                "Name"
            )
            warnings.append(
                f"The query did not specify a space so the so the space named {space} was assumed."
            )

        space_id, actual_space_name = get_space_id_and_name_from_name(
            space, api_key, url
        )

        sanitized_projects = sanitize_names_fuzzy(
            lambda: get_projects_generator(space_id, api_key, url),
            sanitize_projects(body["project_names"]),
        )

        project_names = get_default_argument(
            github_user,
            [project["matched"] for project in sanitized_projects],
            "Project",
        )
        environment_names = get_default_argument(
            github_user,
            sanitize_environments(original_query, body["environment_names"]),
            "Environment",
        )

        processed_query = update_query(original_query, sanitized_projects)

        context = {"input": processed_query}

        response = [
            collect_llm_context(
                processed_query,
                messages,
                context,
                space_id,
                project_names,
                body["runbook_names"],
                body["target_names"],
                body["tenant_names"],
                body["library_variable_sets"],
                environment_names,
                body["feed_names"],
                body["account_names"],
                body["certificate_names"],
                body["lifecycle_names"],
                body["workerpool_names"],
                body["machinepolicy_names"],
                body["tagset_names"],
                body["projectgroup_names"],
                body["channel_names"],
                body["release_versions"],
                body["step_names"],
                body["variable_names"],
                body["dates"],
                api_key,
                url,
                log_query,
            )
        ]

        debug_text.extend(
            get_params_message(
                github_user,
                False,
                general_query_callback_implementation.__name__,
                original_query=processed_query,
                space_name=actual_space_name,
                project_names=project_names,
                runbook_names=body["runbook_names"],
                target_names=body["target_names"],
                tenant_names=body["tenant_names"],
                library_variable_sets=body["library_variable_sets"],
                environment_names=environment_names,
                feed_names=body["feed_names"],
                account_names=body["account_names"],
                certificate_names=body["certificate_names"],
                lifecycle_names=body["lifecycle_names"],
                workerpool_names=body["workerpool_names"],
                machinepolicy_names=body["machinepolicy_names"],
                tagset_names=body["tagset_names"],
                projectgroup_names=body["projectgroup_names"],
                channel_names=body["channel_names"],
                release_versions=body["release_versions"],
                step_names=body["step_names"],
                variable_names=body["variable_names"],
                dates=body["dates"],
            )
        )

        response.extend(warnings)
        response.extend(debug_text)
        return CopilotResponse(response="\n\n".join(response))

    return general_query_callback_implementation
