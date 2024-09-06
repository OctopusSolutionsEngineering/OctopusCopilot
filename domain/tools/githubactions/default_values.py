from domain.config.database import get_functions_connection_string
from domain.response.copilot_response import CopilotResponse
from domain.validation.default_value_validation import (
    validate_default_value_name,
    get_all_default_value_names,
)
from infrastructure.users import (
    save_default_values,
    delete_default_values,
    get_default_values,
    save_profile,
    get_profile,
    get_profiles,
)


def default_value_callbacks(github_user, connection_string):
    def save_defaults_as_profile(profile_name):
        """Saves the current default values to the named profile

        Args:
            profile_name: The name of the profile
        """
        profile = {}
        for default_name in get_all_default_value_names():
            profile[default_name] = get_default_values(
                github_user, default_name, connection_string
            )
        save_profile(github_user, profile_name, profile, connection_string)

        responses = [
            f"Saved profile {profile_name} with the following values:",
            *[
                f'"{name}": "{get_default_values(github_user, name, get_functions_connection_string())}"'
                for name in get_all_default_value_names()
            ],
        ]

        return CopilotResponse("\n\n".join(responses))

    def load_defaults_from_profile(profile_name):
        """Loads the default values from the named profile.

        Args:
            profile_name: The name of the profile
        """
        profile = get_profile(github_user, profile_name, connection_string)
        for default_name in get_all_default_value_names():
            save_default_values(
                github_user, default_name, profile.get(default_name), connection_string
            )
        responses = [
            f"Loaded profile {profile_name} with the following values:",
            *[
                f'"{name}": "{get_default_values(github_user, name, get_functions_connection_string())}"'
                for name in get_all_default_value_names()
            ],
        ]

        return CopilotResponse("\n\n".join(responses))

    def list_profiles():
        """Lists the available profiles."""
        profiles = list(get_profiles(github_user, connection_string))

        if not profiles:
            return CopilotResponse("No profiles are available")

        profile_list = "\n".join([f"* {profile}" for profile in profiles])
        responses = [
            f"The following profiles are available:",
            profile_list,
        ]

        return CopilotResponse("\n\n".join(responses))

    def set_default_value(default_name, default_value):
        """Save a default value for a space, query_project, environment, or channel

        Args:
            default_name: The name of the default value. For example, "Environment", "Project", "Space", "Channel",
            or "Tenant"

            default_value: The default value
        """
        if not default_name or not default_name.strip():
            return CopilotResponse("The default name cannot be empty")

        if not default_value or not default_value.strip():
            return CopilotResponse("The default value cannot be empty")

        try:
            validate_default_value_name(default_name)
        except ValueError as e:
            return CopilotResponse(e.args[0])

        save_default_values(
            github_user,
            default_name.casefold(),
            str(default_value).strip(),
            get_functions_connection_string(),
        )
        return CopilotResponse(
            f'Saved default value "{default_value}" for "{default_name.casefold()}"'
        )

    def remove_default_value():
        """Removes, clears, or deletes a default value for a space, query_project, environment, or channel"""

        delete_default_values(github_user, get_functions_connection_string())
        return CopilotResponse(f"Deleted default values")

    def get_default_value(default_name):
        """Return a default value for a space, query_project, environment, or channel

        Args:
            default_name: The name of the default value. For example, "Environment", "Project", "Space", or "Channel"
        """
        if not default_name or not default_name.strip():
            return CopilotResponse("The default name cannot be empty")

        name = str(default_name).casefold()
        value = get_default_values(github_user, name, get_functions_connection_string())
        return CopilotResponse(f'The default value for "{name}" is "{value}"')

    def get_all_default_values():
        """
        Return all the default values
        """
        responses = [
            f'The default value for "{name}" is "{get_default_values(github_user, name, get_functions_connection_string())}"'
            for name in get_all_default_value_names()
        ]
        return CopilotResponse("\n\n".join(responses))

    return (
        set_default_value,
        remove_default_value,
        get_default_value,
        get_all_default_values,
        save_defaults_as_profile,
        load_defaults_from_profile,
        list_profiles,
    )
