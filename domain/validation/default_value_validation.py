def get_all_default_value_names():
    """
    Returns a list of all default value names
    """
    return ["debug", "environment", "project", "space", "channel", "tenant", "runbook", "owner", "repository",
            "workflow"]


def validate_default_value_name(default_name):
    """
    Ensures the supplied name is a recognized resource that stores a default value
    :param default_name: The name to validate
    """
    name = str(default_name).casefold()
    if name not in get_all_default_value_names():
        raise ValueError(f"Invalid default name \"{default_name}\". "
                         + "The default name must be one of " + ",".join(get_all_default_value_names()))
