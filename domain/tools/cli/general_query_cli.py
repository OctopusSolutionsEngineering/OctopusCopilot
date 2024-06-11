from domain.context.octopus_context import collect_llm_context
from domain.sanitizers.sanitized_list import sanitize_name_fuzzy, sanitize_space, sanitize_names_fuzzy, \
    sanitize_projects
from infrastructure.octopus import get_spaces_generator, get_space_id_and_name_from_name, get_projects_generator


def general_query_cli_callback(api_key, url, get_default_argument, logging):
    def general_query_callback_implementation(original_query, body, messages):
        sanitized_space = sanitize_name_fuzzy(lambda: get_spaces_generator(api_key, url),
                                              sanitize_space(original_query, body["space_name"]))

        space = get_default_argument(sanitized_space["matched"] if sanitized_space else None, "Space")

        context = {"input": original_query}

        space_id, actual_space_name = get_space_id_and_name_from_name(space, api_key, url)

        sanitized_projects = sanitize_names_fuzzy(
            lambda: get_projects_generator(space_id, api_key, url),
            sanitize_projects(body["project_names"]))

        project_names = [project["matched"] for project in sanitized_projects]

        return collect_llm_context(original_query,
                                   messages,
                                   context,
                                   space_id,
                                   project_names,
                                   body['runbook_names'],
                                   body['target_names'],
                                   body['tenant_names'],
                                   body['library_variable_sets'],
                                   body['environment_names'],
                                   body['feed_names'],
                                   body['account_names'],
                                   body['certificate_names'],
                                   body['lifecycle_names'],
                                   body['workerpool_names'],
                                   body['machinepolicy_names'],
                                   body['tagset_names'],
                                   body['projectgroup_names'],
                                   body['channel_names'],
                                   body['release_versions'],
                                   body['step_names'],
                                   body['variable_names'],
                                   body['dates'],
                                   api_key,
                                   url,
                                   logging)

    return general_query_callback_implementation
