def release_what_changed_wrapper(
    original_query, callback, additional_messages=None, logging=None
):
    def release_what_changed(
        space=None,
        project=None,
        environment=None,
        tenant=None,
        release_version=None,
        dates=None,
        **kwargs,
    ):
        """
        Provides details about an Octopus release or deployment and the changes went into it.

        Args:
        space: The name of the space
        project: The name of the project
        environment: The name of the environment
        tenant: The name of the tenant
        dates: the dates in the query
        release_version: The release version
        """

        if logging:
            logging("Enter:", "release_what_changed")

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        return callback(
            original_query,
            space,
            project,
            environment,
            tenant,
            release_version,
            dates,
        )

    return release_what_changed
