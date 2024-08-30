class RunbookVariablesError(Exception):
    """
    Represents the error associated with prompted variables used in a Runbook
    """

    def __init__(self, resource_name, error_message):
        self.resource_name = resource_name
        self.error_message = error_message
        self.resource_type = "Runbook"
        super().__init__(f'Runbook \"{self.resource_name}\" variables error: {error_message}')
