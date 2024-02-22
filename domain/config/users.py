import os


def get_admin_users():
    """
    Returns the list of admin users for the live application
    :return: The list of admin users
    """
    return os.environ.get("APPLICATION_USERS_ADMIN")
