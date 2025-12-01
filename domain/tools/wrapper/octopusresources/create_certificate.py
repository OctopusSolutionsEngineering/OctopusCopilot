def create_certificate_wrapper(query, callback, logging):
    def create_certificate(
        space_name=None,
        certificate_name=None,
        **kwargs,
    ):
        """Creates a certificate in Octopus Deploy.

        You must only select this function when the prompt is specifically requesting to create a single certificate.
        You will be penalized for selecting this function for a prompt that asks a general question about certificates.
        You will be penalized for selecting this function when the prompt contains any instructions to create a project, for example, "Create a project called...".
        If the prompt contains instructions to create a project, you must consider this function as not applicable.

        Example prompts include:
        * Create a Certificate called "Web Server" in the space "My Space"

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
