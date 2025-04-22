import os


def get_admin_servers():
    """
    Returns the JSON list of admin servers for the live application
    :return: The JSON list of admin servers
    """
    return os.environ.get("APPLICATION_SERVERS_ADMIN")
