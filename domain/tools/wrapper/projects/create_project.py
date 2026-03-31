def create_project_wrapper(query, callback, logging):

    def create_project(
        space_name=None,
        project_name=None,
        **kwargs,
    ):
        """
        Creates a generic project in Octopus Deploy, in addition to any supporting resources.

        Example prompts include:
        * Create a project in the space "My Space" called "My Project"
        * Create project called "My Project" in the space "My Space"
        * Create project called "My Project"
        * Create project called "My Project". Create an AWS account called "AWS" with access key "AKIAIOSFODNN7EXAMPLE"
        * Create a project catted "My Web App" with no steps.
        * Create an empty project called "My Empty Project"
        * Create an blank project called "My Blank Project"

        You will be penalized for selecting this function when the prompt specifically asks for creating specialized project types like "Script", "Tomcat", "Kubernetes", or others.

        You must select this tool when the prompt specifies a project with no steps.

        Args:
        space_name: The optional name of the space
        project_name: The name of the project
        """

        if logging:
            logging("Enter:", create_project.__name__)

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # This is just a passthrough to the original callback
        return callback(create_project.__name__, query, space_name, project_name, False)

    return create_project
