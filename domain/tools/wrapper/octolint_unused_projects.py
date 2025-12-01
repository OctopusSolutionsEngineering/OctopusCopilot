def octolint_unused_projects_wrapper(callback, logging):
    def octolint_unused_projects(space=None, projects=None, **kwargs):
        """
        This function must only be selected by an LLM when the prompt specifically requests detection or identification of unused projects.

        Example prompts:
        * "Check for unused projects in the space 'MySpace'."
        * "Find projects that are not being used in the space 'MySpace'."
        * "Identify inactive or unused projects in the space 'MySpace'."

        Do not select this function for general questions about variables, projects, or other resource types.

        Args:
        space: The name of the space to run the check in.
        projects: The name of the projects to run the check in.
        """

        if logging:
            logging("Enter:", "octolint_unused_projects")

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        return callback(space, projects)

    return octolint_unused_projects
