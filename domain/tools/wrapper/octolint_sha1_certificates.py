def octolint_sha1_certificates_wrapper(callback, logging):
    def octolint_sha1_certificates(space=None, project=None, **kwargs):
        """
        **ONLY use this function when the user explicitly asks to detect, check, or find SHA-1 certificates.**

        Checks for uses of SHA-1 certificates for deployment targets, workers or the Octopus Server itself.
        Example prompts include:
        * Check for SHA-1 certificate usage in the space "MySpace".
        * Find SHA1 certificates in the space "MySpace" to improve security.
        * Detect SHA-1 certificates in project "MyProject".
        * List deployment targets using SHA-1 certificates.

        **DO NOT use this function for:**
        * General questions about certificates, variables, or projects
        * Listing all certificates
        * Getting certificate details unrelated to SHA-1
        * Security questions not specifically about SHA-1 certificate detection

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
