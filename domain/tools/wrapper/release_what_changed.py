def release_what_changed_wrapper(
    original_query, callback, additional_messages=None, logging=None
):
    def release_what_changed_with_dates(
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
        Get the details of releases or deployments based on a date range.
        Example prompts include:
        * Find deployments after "1st Jan 2025" and before "2nd Mar 2025".
        * Find deployments after "January 12, 2025".
        * Find deployments before "2025 Mar 20".

        Args:
        space: The name of the space
        project: The name of the project
        environment: The name of the environment
        tenant: The name of the tenant
        channel: The name of the channel
        dates: The dates in the query
        release_version: The release version
        """

        return release_what_changed(
            space=space,
            project=project,
            environment=environment,
            tenant=tenant,
            channel=channel,
            release_version=release_version,
            dates=dates,
            **kwargs,
        )

    def release_what_changed_help_me(
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
        Provides help on understanding or fixing a failed deployment.

        You must select this function when the prompt is related to understanding or fixing a failed deployment.

        Example prompts include:
        * Help me understand why the deployment failed.
        * Help me resolve the failed deployment. Provide suggestions for resolving the issue.
        * Help me understand why the deployment failed. The current environment is "Production". The current project is "WebApp".
        * Help me understand why the deployment to the production environment failed.
        * Help me fix the deployment.
        * Help me understand why the deployment to the "Staging" environment failed.

        Args:
        space: The name of the space
        project: The name of the project
        environment: The name of the environment
        tenant: The name of the tenant
        channel: The name of the channel
        dates: The dates in the query
        release_version: The release version
        """

        return release_what_changed(
            space=space,
            project=project,
            environment=environment,
            tenant=tenant,
            channel=channel,
            release_version=release_version,
            dates=dates,
            **kwargs,
        )

    def release_what_changed_help_me_environment(
        environment=None,
        **kwargs,
    ):
        """
        Provides help on understanding or fixing a failed deployment to an environment.

        You must select this function when the prompt is related to understanding or fixing a failed deployment.

        Example prompts include:
        * Help me understand why the deployment failed.
        * Help me resolve the failed deployment. Provide suggestions for resolving the issue.
        * Help me understand why the deployment failed. The current environment is "Production".
        * Help me understand why the deployment to the production environment failed.
        * Help me fix the deployment.
        * Help me understand why the deployment to the "Staging" environment failed.

        Args:
        environment: The optional name of the environment
        """

        return release_what_changed(
            space=None,
            project=None,
            environment=environment,
            tenant=None,
            channel=None,
            release_version=None,
            dates=None,
            **kwargs,
        )

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
        Provides details about an Octopus release or deployment, including git commits, issues or tickets, release notes etc.
        Select this function for any prompt regarding releases or deployments.
        Example prompts include:
        * What changed in the latest deployment to the production environment?
        * How do I fix release "10.23.65" of the "WebApp" project to the "Production" environment?
        * Suggest a solution for the failed deployment to production environment in the hotfix channel?
        * What code changes went into deployment version "1.23.675"?
        * What issues were included in the latest deployment to the "prod" environment?
        * What is the release version of the latest deployment?
        * Given release "1.23.675" of the "WebApp" project to the "Production" environment, what changes were made?

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

    return (
        release_what_changed,
        release_what_changed_help_me,
        release_what_changed_with_dates,
        release_what_changed_help_me_environment,
    )
