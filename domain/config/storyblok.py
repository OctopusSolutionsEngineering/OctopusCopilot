import os


def get_storyblok_token():
    """
    Gets the token for Storyblok
    :return: The zendesk user email
    """
    return os.environ.get("STORYBLOK_TOKEN")
