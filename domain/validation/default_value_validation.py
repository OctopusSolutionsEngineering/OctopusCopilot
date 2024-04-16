def validate_default_value_name(default_name):
    name = str(default_name).casefold()
    if not (name == "environment" or name == "project" or name == "space" or name == "channel" or name == "tenant"):
        raise ValueError(f"Invalid default name \"{default_name}\". "
                         + "The default name must be one of \"Environment\", \"Project\", \"Space\", \"Tenant\", or \"Channel\"")
