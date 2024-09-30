def create_release_wrapper(query, callback, logging):
    def create_release(
        space_name=None,
        project_name=None,
        git_ref=None,
        release_version=None,
        channel_name=None,
        environment_name=None,
        tenant_name=None,
        variables=None,
        **kwargs,
    ):
        """Creates a release for an Octopus project, and optionally deploys it to an environment. Example prompts include:
            * Create a release in the project "Deploy WebApp" with version "4.2.12" and channel "Mainline" in the space "Default"
            * Create a release in the project "Deploy Az Function" in the space "Global" and deploy to the "Development" environment with variables "DeploymentSlot=Staging, notifyUsers=true"

        Args:
        space_name: The name of the space
        project_name: The name of the project
        git_ref: The (optional) git reference for the project
        release_version: The (optional) version for the release
        channel_name: The (optional) name of the channel
        environment_name: The (optional) name of the environment to deploy the release to
        tenant_name: The (optional) name of the tenant to deploy the release to
        variables: The (optional) dictionary of variable key/value pairs.
        """

        if logging:
            logging("Enter:", "create_release")

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # This is just a passthrough to the original callback
        return callback(
            query,
            space_name,
            project_name,
            git_ref,
            release_version,
            channel_name,
            environment_name,
            tenant_name,
            variables,
        )

    return create_release
