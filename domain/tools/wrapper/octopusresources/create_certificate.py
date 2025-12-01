def create_certificate_wrapper(query, callback, logging):
    def create_certificate(
        space_name=None,
        certificate_name=None,
        **kwargs,
    ):
        """Creates a certificate in Octopus Deploy.

        IMPORTANT - Tool Selection Criteria:
        - ONLY select this function when the prompt explicitly asks to create certificates
        - DO NOT select this function for general questions about certificates
        - DO NOT select this function if the prompt mentions creating projects, steps, or other resources
        - DO NOT select this function if the prompt starts with phrases like "Create a Kubernetes project", "Create an Azure Web App project", etc.

        This function is ONLY for prompts that specifically request certificate creation, such as:
        * "Create a Certificate called 'Web Server' in the space 'My Space'"
        * "Add a certificate named 'SSL Certificate'"
        * "Create the Production certificate"

        You will be penalized for selecting this function when:
        - The prompt asks general questions about certificates
        - The prompt contains instructions to create projects or other resources
        - The prompt is about anything other than creating certificates

        Args:
            space_name: The name of the space
            certificate_name: The name of the certificate
        """

        if logging:
            logging("Enter:", create_certificate.__name__)

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # This is just a passthrough to the original callback
        return callback(
            create_certificate.__name__, query, space_name, certificate_name
        )

    return create_certificate
