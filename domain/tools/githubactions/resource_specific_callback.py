from domain.context.octopus_context import collect_llm_context
from domain.defaults.defaults import get_default_argument
from domain.response.copilot_response import CopilotResponse
from domain.sanitizers.sanitized_list import (
    sanitize_name_fuzzy,
    sanitize_space,
    sanitize_names_fuzzy,
    sanitize_projects,
    get_item_or_none,
    sanitize_environments,
    sanitize_tenants,
    update_query,
)
from domain.tools.debug import get_params_message
from infrastructure.octopus import (
    get_spaces_generator,
    get_space_id_and_name_from_name,
    get_projects_generator,
)


def resource_specific_callback(github_user, octopus_details, log_query):
    def resource_specific_callback_implementation(
        original_query,
        messages,
        space,
        projects,
        runbooks,
        targets,
        tenants,
        environments,
        accounts,
        certificates,
        workerpools,
        machinepolicies,
        tagsets,
        steps,
    ):
        """
        Resource specific queries are typically used to give the LLM context about the relationship between space
        level scopes such as environments and tenants, and how those scopes apply to resources like targets,
        certificates, accounts etc.

        While the tool functions are resource specific, this callback is generic.
        """

        api_key, url = octopus_details()

        debug_text = get_params_message(
            github_user,
            True,
            resource_specific_callback_implementation.__name__,
            original_query=original_query,
            space=space,
            projects=projects,
            runbooks=runbooks,
            targets=targets,
            tenants=tenants,
            environments=environments,
            accounts=accounts,
            certificates=certificates,
            workerpools=workerpools,
            machinepolicies=machinepolicies,
            tagsets=tagsets,
            steps=steps,
        )

        sanitized_space = sanitize_name_fuzzy(
            lambda: get_spaces_generator(api_key, url),
            sanitize_space(original_query, space),
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
            sanitize_projects(projects),
        )

        project = get_default_argument(
            github_user,
            get_item_or_none([project["matched"] for project in sanitized_projects], 0),
            "Project",
        )
        environment = get_default_argument(
            github_user,
            get_item_or_none(sanitize_environments(original_query, environments), 0),
            "Environment",
        )
        tenant = get_default_argument(
            github_user, get_item_or_none(sanitize_tenants(tenants), 0), "Tenant"
        )

        processed_query = update_query(original_query, sanitized_projects)

        context = {"input": processed_query}

        debug_text.extend(
            get_params_message(
                github_user,
                False,
                resource_specific_callback_implementation.__name__,
                original_query=processed_query,
                space=actual_space_name,
                projects=project,
                runbooks=runbooks,
                targets=targets,
                tenants=tenant,
                environments=environment,
                accounts=accounts,
                certificates=certificates,
                workerpools=workerpools,
                machinepolicies=machinepolicies,
                tagsets=tagsets,
                steps=steps,
            )
        )

        response = [
            collect_llm_context(
                processed_query,
                messages,
                context,
                space_id,
                project,
                runbooks,
                targets,
                tenant,
                None,
                environment,
                None,
                accounts,
                certificates,
                None,
                workerpools,
                machinepolicies,
                tagsets,
                None,
                None,
                None,
                steps,
                None,
                None,
                api_key,
                url,
                log_query,
            )
        ]

        response.extend(warnings)
        response.extend(debug_text)

        return CopilotResponse("\n\n".join(response))

    return resource_specific_callback_implementation
