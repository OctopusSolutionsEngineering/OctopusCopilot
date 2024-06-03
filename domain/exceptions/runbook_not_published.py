class RunbookNotPublished(Exception):
    """
    Represents the error associated with a resource that was not found in Octopus
    """

    def __init__(self, resource_name):
        self.resource_name = resource_name
        self.resource_type = "Runbook"
        super().__init__(f'Runbook {self.resource_name} is not published')
