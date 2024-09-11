def release_what_changed_wrapper(
    original_query, callback, additional_messages=None, logging=None
):
    def release_what_changed(space=None, projects=None, release_version=None, **kwargs):
        """
        Provides details about what changes went into an Octopus release.
        Args:
        space: The name of the space
        projects: The name of the project
        release_version: The release version
        """

        if logging:
            logging("Enter:", "release_what_changed")

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        return callback(original_query, space, projects, release_version)

    return release_what_changed
