from domain.context.octopus_context import collect_llm_context
from domain.defaults.defaults import get_default_argument
from domain.response.copilot_response import CopilotResponse
from domain.sanitizers.sanitized_list import sanitize_name_fuzzy, sanitize_space, sanitize_names_fuzzy, \
    sanitize_projects, update_query, none_if_falesy_or_all
from infrastructure.octopus import get_spaces_generator, get_space_id_and_name_from_name, get_projects_generator


def variable_query_callback(github_user, api_key, url, log_query):
    def variable_query_callback_implementation(original_query, messages, space, projects, variables):
        sanitized_space = sanitize_name_fuzzy(lambda: get_spaces_generator(api_key, url),
                                              sanitize_space(original_query, space))

        space = get_default_argument(github_user,
                                     sanitized_space["matched"] if sanitized_space else None, "Space")

        warnings = ""

        if not space:
            space = next(get_spaces_generator(api_key, url), {"Name": "Default"}).get("Name")
            warnings = f"The query did not specify a space so the so the space named {space} was assumed."

        space_id, actual_space_name = get_space_id_and_name_from_name(space, api_key, url)

        sanitized_projects = sanitize_names_fuzzy(lambda: get_projects_generator(space_id, api_key, url),
                                                  sanitize_projects(projects))

        projects = get_default_argument(github_user,
                                        [project["matched"] for project in sanitized_projects], "Project")

        processed_query = update_query(original_query, sanitized_projects)

        context = {"input": processed_query}

        chat_response = collect_llm_context(processed_query,
                                            messages,
                                            context,
                                            space_id,
                                            projects,
                                            None,
                                            None,
                                            None,
                                            None,
                                            None,
                                            None,
                                            None,
                                            None,
                                            None,
                                            None,
                                            None,
                                            None,
                                            None,
                                            None,
                                            None,
                                            None,
                                            ["<all>"] if none_if_falesy_or_all(variables) else variables,
                                            None,
                                            api_key,
                                            url,
                                            log_query)

        additional_information = ""
        if not projects:
            additional_information = (
                    "\nThe query did not specify a project so the response may reference a subset of all the projects in a space."
                    + "\nTo see more detailed information, specify a project name in the query.")

        return CopilotResponse("\n".join(filter(lambda x: x, [chat_response, warnings, additional_information])))

    return variable_query_callback_implementation
