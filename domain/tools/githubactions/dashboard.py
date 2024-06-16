from domain.defaults.defaults import get_default_argument
from domain.response.copilot_response import CopilotResponse
from domain.sanitizers.sanitized_list import sanitize_name_fuzzy, sanitize_space
from domain.transformers.chat_responses import get_dashboard_response
from infrastructure.octopus import get_spaces_generator, get_space_id_and_name_from_name, get_dashboard


def get_dashboard_callback(github_user, log_query=None):
    def get_dashboard_callback_implementation(original_query, api_key, url, space_name):
        sanitized_space = sanitize_name_fuzzy(lambda: get_spaces_generator(api_key, url),
                                              sanitize_space(original_query, space_name))

        space_name = get_default_argument(github_user,
                                          sanitized_space["matched"] if sanitized_space else None, "Space")

        warnings = []

        if not space_name:
            space_name = next(get_spaces_generator(api_key, url), {"Name": "Default"}).get("Name")
            warnings.append(f"The query did not specify a space so the so the space named {space_name} was assumed.")

        if log_query:
            log_query("get_dashboard_callback_implementation", f"""
                Space: {space_name}""")

        space_id, actual_space_name = get_space_id_and_name_from_name(space_name, api_key, url)
        dashboard = get_dashboard(space_id, api_key, url)
        response = [get_dashboard_response(actual_space_name, dashboard)]

        # Debug mode shows the entities extracted from the query
        debug_text = []
        debug = get_default_argument(github_user, "False", "Debug")
        if debug.casefold() == "true":
            debug_text.append(get_dashboard_callback_implementation.__name__
                              + " was called with the following parameters:"
                              + f"\n* Original Query: {original_query}"
                              + f"\n* Space: {space_name}")

        response.extend(warnings)
        response.extend(debug_text)

        return CopilotResponse("\n\n".join(response))

    return get_dashboard_callback_implementation
