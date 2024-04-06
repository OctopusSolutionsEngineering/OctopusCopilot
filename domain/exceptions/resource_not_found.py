class ResourceNotFound(Exception):
    """
    Represents the error associated with a resource that was not found in Octopus
    """

    def __init__(self, resource_type, resource_name):
        self.resource_name = resource_name
        self.resource_type = resource_type
        super().__init__(f'{resource_type} {self.resource_name} not found in Octopus')
