def create_lambda_project_wrapper(query, callback, logging):
    def create_lambda_project(
        space_name=None,
        project_name=None,
        **kwargs,
    ):
        """
        Creates a project in Octopus Deploy that deploys to AWS Lambda, in addition to any supporting resources.

        Example prompts include:
        * Create a Lambda project in the space "My Space" called "My Project"
        * Create AWS Lambda project called "My Project" in the space "My Space"
        * Create Lambda project called "My Project"
        * Create Lambda project called "My Project". Create an AWS account called "AWS" with access key "AKIAIOSFODNN7EXAMPLE"

        Args:
        space_name: The optional name of the space
        project_name: The name of the project
        """

        if logging:
            logging("Enter:", create_lambda_project.__name__)

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # This is just a passthrough to the original callback
        return callback(create_lambda_project.__name__, query, space_name, project_name)

    return create_lambda_project
