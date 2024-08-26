import os


def get_zendesk_user():
    """
    Gets the email address of the zendesk api user
    :return: The zendesk user email
    """
    return os.environ.get("ZENDESK_EMAIL")


def get_zendesk_token():
    """
    Gets the zendesk api token
    :return: The zendesk api token
    """
    return os.environ.get("ZENDESK_TOKEN")
