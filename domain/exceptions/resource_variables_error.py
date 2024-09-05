class ResourceVariablesError(Exception):
    """
    Represents the error associated with prompted variables used in a Resource such as a Runbook or Deployment
    """

    def __init__(self, resource_name, error_message):
        self.resource_name = resource_name
        self.error_message = error_message
        super().__init__(f'{self.resource_name} variables error: {error_message}')
