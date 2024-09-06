class PromptedVariableMatchingError(Exception):
    """
    Represents the error associated with matching prompted variable values to an Octopus Resource such as a Runbook or
    Deployment.
    """

    def __init__(self, error_message):
        self.error_message = error_message
        super().__init__(error_message)
