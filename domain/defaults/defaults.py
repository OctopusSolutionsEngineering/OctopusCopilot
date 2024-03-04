from domain.config.database import get_functions_connection_string
from domain.validation.argument_validation import ensure_string_not_empty
from infrastructure.users import get_default_values


def get_default_argument(user, argument, default_name):
    """
    If the argument is empty, return the default value for the user.
    :param user: The user to get the default value for
    :param argument: The argument to check
    :param default_name: The type of argument
    :return: The argument is if it is not blank, or the default value
    """

    ensure_string_not_empty(user, 'user must be the current user (get_default_argument).')
    ensure_string_not_empty(default_name, 'default_name must be the argument type (get_default_argument).')

    if not argument or not argument.strip():
        return get_default_values(user, default_name, get_functions_connection_string())

    return argument
