def create_release_wrapper(query, callback, logging):
    def create_release(space_name=None, project_name=None, git_ref=None, release_version=None, channel_name=None,
                       environment_name=None, tenant_name=None, **kwargs):
        """Responds to queries like: Create a release in the project "Deploy WebApp" with version "4.2.12" and channel
           "Mainline" in the space "Default", or Create a release in the project "Deploy Az Function" in the space
           "Global" and deploy to the "Development" environment

        Args:
        space_name: The name of the space
        project_name: The name of the project
        git-ref: The (optional) git reference for the project if its version-controlled
        release_version: The (optional) version for the release
        channel_name: The (optional name of the channel
        environment_name: The (optional) name of the environment to deploy the release to
        tenant_name: The (optional) name of the tenant to deploy the release to
        """

        if logging:
            logging("Enter:", "create_release")

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # This is just a passthrough to the original callback
        return callback(query,
                        space_name,
                        project_name,
                        git_ref,
                        release_version,
                        channel_name,
                        environment_name,
                        tenant_name)

    return create_release
