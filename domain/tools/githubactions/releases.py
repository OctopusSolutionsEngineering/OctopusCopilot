import json

from domain.config.openai import max_deployments
from domain.context.octopus_context import collect_llm_context
from domain.defaults.defaults import get_default_argument, get_default_argument_list
from domain.performance.timing import timing_wrapper
from domain.response.copilot_response import CopilotResponse
from domain.sanitizers.sanitized_list import sanitize_environments, sanitize_tenants, sanitize_name_fuzzy, \
    sanitize_space, sanitize_names_fuzzy, sanitize_projects, get_item_or_none, update_query
from domain.transformers.deployments_from_dashboard import get_deployments_from_dashboard
from domain.transformers.deployments_from_release import get_deployments_for_project
from infrastructure.octopus import get_spaces_generator, get_space_id_and_name_from_name, get_projects_generator


def releases_query_messages(github_user):
    def releases_query_messages_implementation(original_query, space, projects, environments, channels, releases):
        """
        Provide some additional context about the default projects and environments that were used
        to build the list of releases.
        """
        query_project = get_default_argument(github_user,
                                             get_item_or_none(projects, 0),
                                             "Project")
        query_environments = get_default_argument(github_user,
                                                  get_item_or_none(environments, 0),
                                                  "Environment")

        additional_messages = []

        # Let the LLM know which query_project and environment to find the details for
        # if we used the default value.
        if not projects and query_project:
            additional_messages.append(
                ("user", f"The question relates to the project \"{query_project}\""))

        if not environments and query_environments:
            if isinstance(query_environments, str):
                additional_messages.append(
                    ("user", f"The question relates to the environment \"{query_environments}\""))
            else:
                additional_messages.append(
                    ("user",
                     f"The question relates to the environments \"{','.join(query_environments)}\""))

        return additional_messages

    return releases_query_messages_implementation


def releases_query_callback(github_user, api_key, url, log_query):
    def releases_query_callback_implementation(original_query, messages, space, projects, environments, channels,
                                               releases, tenants, dates):

        sanitized_environments = sanitize_environments(original_query, environments)
        sanitized_tenants = sanitize_tenants(tenants)

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

        query_project = get_default_argument(github_user,
                                             get_item_or_none(
                                                 [project["matched"] for project in sanitized_projects], 0),
                                             "Project")

        query_environments = get_default_argument_list(github_user,
                                                       sanitized_environments,
                                                       "Environment")

        query_tenants = get_default_argument_list(github_user,
                                                  sanitized_tenants,
                                                  "Tenant")

        processed_query = update_query(original_query, sanitized_projects)

        context = {"input": processed_query}

        # We need some additional JSON data to answer this question
        if query_project:
            # When the query limits the results to certain projects, we
            # can dive deeper and return a larger collection of deployments
            deployments = timing_wrapper(lambda: get_deployments_for_project(space_id,
                                                                             query_project,
                                                                             query_environments,
                                                                             query_tenants,
                                                                             api_key,
                                                                             url,
                                                                             dates,
                                                                             max_deployments), "Deployments")
            context["json"] = json.dumps(deployments, indent=2)
        else:
            # When the query is more general, we rely on the deployment information
            # returned to supply the dashboard. The results are broad, but not deep.
            context["json"] = get_deployments_from_dashboard(space_id, api_key, url)

        chat_response = collect_llm_context(processed_query,
                                            messages,
                                            context,
                                            space_id,
                                            query_project,
                                            None,
                                            None,
                                            query_tenants,
                                            None,
                                            ["<all>"] if not query_environments else query_environments,
                                            None,
                                            None,
                                            None,
                                            None,
                                            None,
                                            None,
                                            None,
                                            None,
                                            channels,
                                            releases,
                                            None,
                                            None,
                                            dates,
                                            api_key,
                                            url,
                                            log_query)

        additional_information = ""
        if not query_project:
            additional_information = (
                    "\nThe query did not specify a project so the response is limited to the latest deployments for all projects."
                    + "\nTo see more detailed information, specify a project name in the query.")

        # Debug mode shows the entities extracted from the query
        debug_text = ""
        debug = get_default_argument(github_user, None, "Debug")
        if debug.casefold() == "true":
            additional_information = (releases_query_callback_implementation.__name__
                                      + " was called with the following parameters:"
                                      + f"\n* Original Query: {original_query}"
                                      + f"\n* Space: {space}"
                                      + f"\n* Projects: {projects}"
                                      + f"\n* Environments: {environments}"
                                      + f"\n* Channels: {channels}"
                                      + f"\n* Releases: {releases}"
                                      + f"\n* Tenants: {tenants}"
                                      + f"\n* Dates: {dates}")

        return CopilotResponse(
            "\n\n".join(filter(lambda x: x, [chat_response, warnings, additional_information, debug_text])))

    return releases_query_callback_implementation
