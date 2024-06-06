from domain.defaults.defaults import get_default_argument
from domain.response.copilot_response import CopilotResponse
from domain.sanitizers.sanitized_list import sanitize_name_fuzzy, sanitize_space
from domain.transformers.chat_responses import get_dashboard_response
from infrastructure.octopus import get_spaces_generator, get_space_id_and_name_from_name, get_dashboard


def get_dashboard_wrapper(original_query, github_user, api_key, url):
    def get_dashboard_tool(space_name: None):
        """Display the dashboard

            Args:
                space_name: The name of the space containing the projects.
                If this value is not defined, the default value will be used.
        """

        sanitized_space = sanitize_name_fuzzy(lambda: get_spaces_generator(api_key, url),
                                              sanitize_space(original_query, space_name))

        space_name = get_default_argument(github_user,
                                          sanitized_space["matched"] if sanitized_space else None, "Space")

        warnings = ""

        if not space_name:
            space_name = next(get_spaces_generator(api_key, url), {"Name": "Default"}).get("Name")
            warnings = f"The query did not specify a space so the so the space named {space_name} was assumed."

        space_id, actual_space_name = get_space_id_and_name_from_name(space_name, api_key, url)
        dashboard = get_dashboard(space_id, api_key, url)
        response = get_dashboard_response(dashboard)

        return CopilotResponse("\n\n".join(filter(lambda x: x, [response, warnings])))

    return get_dashboard_tool
