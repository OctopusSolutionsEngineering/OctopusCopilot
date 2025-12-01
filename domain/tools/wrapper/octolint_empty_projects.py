def octolint_empty_projects_wrapper(callback, logging):
    def octolint_empty_projects(space=None, projects=None, **kwargs):
        """
        **ONLY use this function when the user explicitly asks to detect, check, or find empty projects.**

        Checks for empty projects with no steps or runbooks in the space. Example prompts include:
        * Check for empty projects in the space "MySpace".
        * Find projects with no steps or runbooks in space "MySpace".
        * Detect empty projects.
        * List projects that are empty.

        **DO NOT use this function for:**
        * General questions about projects or steps
        * Listing all projects
        * Getting project details
        * Any query not specifically about empty project detection

        Args:
        space: The name of the space to run the check in.
        projects: The name of the projects to run the check in.
        """

        if logging:
            logging("Enter:", "octolint_empty_projects")

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        return callback(space, projects)

    return octolint_empty_projects
