def create_account_wrapper(query, callback, logging):
    def create_account(
        space_name=None,
        account_name=None,
        account_type=None,
        **kwargs,
    ):
        """Creates an account in Octopus Deploy. Example prompts include:
            * Create an AWS account called "AWS" in the space "My Space"
            * Create an AWS OIDC account called "OIDC" in the space "My Space"
            * Create an Azure OIDC account called "OIDC" in the space "My Space"
            * Create an Azure Service Principal account called "Azure" in the space "My Space"
            * Create a Username/password account called "production" in the space "My Space"
            * Create a Token account called "K8s Cluster" in the space "My Space"

            You will be penalised for selecting this function if the prompt mentions a project, or creating a project.

        Args:
        space_name: The name of the space
        account_name: The name of the account
        account_type: The type of the account
        """

        if logging:
            logging("Enter:", create_account.__name__)

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # This is just a passthrough to the original callback
        return callback(
            create_account.__name__, query, space_name, account_name, account_type
        )

    return create_account
