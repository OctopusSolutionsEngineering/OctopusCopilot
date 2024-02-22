import json

from domain.errors.error_handling import handle_error
from domain.exceptions.not_authorized import NotAuthorized


def is_admin_user(user, get_admin_users, callback):
    """
    A wrapper function that checks to see if the user is an admin. If so, the callback is called. If not, an exception is raised.
    :param user: A function returning the current user
    :param get_admin_users: A function returning a JSON list of users
    :param callback: The function to call if the user is authorized
    :return: The value returned by the callback
    """
    try:
        admin_users = json.loads(get_admin_users())
    except Exception as e:
        handle_error(e)
        raise NotAuthorized()

    if user() not in admin_users:
        raise NotAuthorized()

    return callback()
