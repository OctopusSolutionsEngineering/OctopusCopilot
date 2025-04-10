def octolint_unrotated_accounts_wrapper(callback, logging):
    def octolint_unrotated_accounts(space=None, **kwargs):
        """
        Checks for accounts with static credentials that have not been rotated in the space. Example prompts include:
        * Find accounts with unrotated credentials in the space "MySpace".
        * Find accounts with unrotated credentials in the space "MySpace" to improve security.

        Args:
        space: The name of the space to run the check in.
        """

        if logging:
            logging("Enter:", "octolint_unrotated_accounts")

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        return callback(space)

    return octolint_unrotated_accounts
