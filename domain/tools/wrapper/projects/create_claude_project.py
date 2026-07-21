def create_claude_project_wrapper(query, callback, logging):

    def create_claude_project(
        space_name=None,
        project_name=None,
        **kwargs,
    ):
        """
        Creates a Claude project in Octopus Deploy, in addition to any supporting resources.

        This project focuses on using a LLM to categorize the impact of code changes associated with a new package version,
        and if the changes are significant, to present a manual intervention.

        Select this tool when the prompt mentions Claude, or if the prompt mentions using AI or an LLM to rate code changes.

        Example prompts include:
        * Create a Claude project in the space "My Space" called "My Project"
        * Create a project with the Claude step in the space "My Space" called "My Project"
        * Create a project called "My LLM project" using AI to determine the impact of changes in a release
        * Create Claude project called "My Project" in the space "My Space"
        * Create Claude project called "My Project"
        * Create Claude project called "My Project". Create an AWS account called "AWS" with access key "AKIAIOSFODNN7EXAMPLE"

        Args:
        space_name: The optional name of the space
        project_name: The name of the project
        """

        if logging:
            logging("Enter:", create_claude_project.__name__)

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # This is just a passthrough to the original callback
        return callback(
            create_claude_project.__name__,
            query,
            space_name,
            project_name,
            False,
        )

    return create_claude_project
