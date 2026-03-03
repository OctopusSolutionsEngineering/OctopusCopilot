def create_argocdmodifymanifest_project_wrapper(query, callback, logging):
    def create_argocdmodifymanifest_project(
        space_name=None,
        project_name=None,
        no_prompt=False,
        **kwargs,
    ):
        """
        Creates an Argo CD Update Manifest project in Octopus Deploy, in addition to any supporting resources.

        Example prompts include:
        * Create a Argo CD Modify Manifest project in the space "My Space" called "My Project"
        * Create a Argo CD Update Manifest project in the space "My Space" called "My Project"
        * Create an Argo CD project modifying manifest files a war file called "My Project" in the space "My Space"
        * Create an Argo CD project updating manifest files a war file called "My Project" in the space "My Space"

        Args:
        space_name: The name of the space
        project_name: The name of the project
        no_prompt: Whether to disable the prompt. Defaults to False.
        """

        if logging:
            logging("Enter:", create_argocdmodifymanifest_project.__name__)

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # This is just a passthrough to the original callback
        return callback(
            create_argocdmodifymanifest_project.__name__,
            query,
            space_name,
            project_name,
            no_prompt,
        )

    return create_argocdmodifymanifest_project
