def octolint_sha1_certificates_wrapper(callback, logging):
    def octolint_sha1_certificates(space=None, project=None, **kwargs):
        """
        Checks for uses of SHA-1 certificates for deployment targets, workers or the Octopus Server itself.
        Example prompts include:
        * Check for SHA-1 certificate usage in the space "MySpace".
        * Find SHA1 certificates in the space "MySpace" to improve security.

        You will be penalized for selecting this function when the prompt is a general question about variables or projects.

        Args:
        space: The name of the space to run the check in.
        project: The name of the project to run the check in.
        """

        if logging:
            logging("Enter:", "octolint_sha1_certificates")

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        return callback(space, project)

    return octolint_sha1_certificates
