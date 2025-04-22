import json
import logging

from domain.errors.error_handling import handle_error
from domain.exceptions.invalid_admin_users import InvalidAdminUsers
from domain.exceptions.not_authorized import NotAuthorized
from domain.url.hostname import get_hostname_from_url


def is_admin_server(server, admin_servers):
    if not server or not admin_servers:
        return False

    try:
        admin_users = list(map(lambda x: str(x), json.loads(admin_servers)))

    except Exception as e:
        handle_error(
            InvalidAdminUsers(
                "Failed to parse list of admin users: " + admin_servers, e
            )
        )
        return False

    if get_hostname_from_url(str(server)) not in admin_servers:
        return False

    return True


def is_admin_user(user, get_admin_users):
    """
    Check if the user is an admin.
    :param user: A function returning the current user
    :param get_admin_users: A json string representing a list of admin users
    :return: The value returned by the callback
    """

    if not user or not get_admin_users:
        return False

    try:
        admin_users = list(map(lambda x: str(x), json.loads(get_admin_users)))

    except Exception as e:
        handle_error(
            InvalidAdminUsers(
                "Failed to parse list of admin users: " + get_admin_users, e
            )
        )
        return False

    if str(user) not in admin_users:
        return False

    return True


def call_admin_function(user, get_admin_users, callback):
    """
    A wrapper function that checks to see if the user is an admin. If so, the callback is called. If not, an exception is raised.
    :param user: A function returning the current user
    :param get_admin_users: A function returning a JSON list of users
    :param callback: The function to call if the user is authorized
    :return: The value returned by the callback
    """

    empty_string_is_authorized(get_admin_users)
    empty_string_is_authorized(user)

    if not callback:
        return

    try:
        admin_users = list(map(lambda x: str(x), json.loads(get_admin_users)))

    except Exception as e:
        handle_error(
            InvalidAdminUsers(
                "Failed to parse list of admin users: " + get_admin_users, e
            )
        )
        raise NotAuthorized()

    if str(user) not in admin_users:
        logging.error(f"User {user} not found in {admin_users}")
        raise NotAuthorized()

    return callback()


def empty_string_is_authorized(value):
    if not value or not isinstance(value, str) or not value.strip():
        raise NotAuthorized()
