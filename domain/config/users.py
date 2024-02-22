import os


def get_admin_users():
    return os.environ.get("APPLICATION_USERS_ADMIN")
