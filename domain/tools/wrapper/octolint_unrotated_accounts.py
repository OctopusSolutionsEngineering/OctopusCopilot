def octolint_unrotated_accounts_wrapper(callback, logging):
    def octolint_unrotated_accounts(space=None, **kwargs):
        """
        This function must only be selected by an LLM when the prompt specifically requests detection or identification of accounts with unrotated credentials.

        Example prompts:
        * "Find accounts with unrotated credentials in the space 'MySpace'."
        * "Check for accounts that haven't rotated their credentials in the space 'MySpace'."
        * "Identify accounts with static credentials that need rotation in the space 'MySpace'."

        Do not select this function for general questions about accounts, projects, or other resource types.

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
