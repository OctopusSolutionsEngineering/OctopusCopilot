def release_what_changed_wrapper(
    original_query, callback, additional_messages=None, logging=None
):
    def release_what_changed(
        space=None,
        project=None,
        environment=None,
        tenant=None,
        channel=None,
        release_version=None,
        dates=None,
        **kwargs,
    ):
        """
        Provides details about an Octopus release or deployment and the changes went into it. Example prompts include:
        * What changed in the latest deployment to the production environment?
        * Suggest a solution for the failed deployment to production environment in the hotfix channel?
        * What code changes went into deployment version "1.23.675"?
        * What issues were included in the latest deployment to the "prod" environment?
        * What is the release version of the latest deployment?

        Args:
        space: The name of the space
        project: The name of the project
        environment: The name of the environment
        tenant: The name of the tenant
        channel: The name of the channel
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
            channel,
            release_version,
            dates,
        )

    return release_what_changed
