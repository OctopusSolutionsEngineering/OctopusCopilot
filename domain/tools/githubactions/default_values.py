from domain.config.database import get_functions_connection_string
from domain.response.copilot_response import CopilotResponse
from domain.validation.default_value_validation import validate_default_value_name
from infrastructure.users import save_default_values, delete_default_values, get_default_values


def default_value_callbacks(github_user):
    def set_default_value(default_name, default_value):
        """Save a default value for a space, query_project, environment, or channel
    
            Args:
                default_name: The name of the default value. For example, "Environment", "Project", "Space", "Channel",
                or "Tenant"
    
                default_value: The default value
        """

        try:
            validate_default_value_name(default_name)
        except ValueError as e:
            return CopilotResponse(e.args[0])

        save_default_values(github_user, default_name.casefold(), default_value,
                            get_functions_connection_string())
        return CopilotResponse(f"Saved default value \"{default_value}\" for \"{default_name.casefold()}\"")

    def remove_default_value():
        """Removes, clears, or deletes a default value for a space, query_project, environment, or channel
        """

        delete_default_values(github_user, get_functions_connection_string())
        return CopilotResponse(f"Deleted default values")

    def get_default_value(default_name):
        """Save a default value for a space, query_project, environment, or channel
    
            Args:
                default_name: The name of the default value. For example, "Environment", "Project", "Space", or "Channel"
        """
        name = str(default_name).casefold()
        value = get_default_values(github_user, name, get_functions_connection_string())
        return CopilotResponse(f"The default value for \"{name}\" is \"{value}\"")

    return set_default_value, remove_default_value, get_default_value
