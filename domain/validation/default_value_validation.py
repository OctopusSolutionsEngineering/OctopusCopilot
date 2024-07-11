def validate_default_value_name(default_name):
    """
    Ensures the supplied name is a recognized resource that stores a default value
    :param default_name: The name to validate
    """
    name = str(default_name).casefold()
    valid_names = ["debug", "environment", "project", "space", "channel", "tenant", "runbook", "owner", "repository", "workflow"]
    if name not in valid_names:
        raise ValueError(f"Invalid default name \"{default_name}\". "
                         + "The default name must be one of " + ",".join(valid_names))
