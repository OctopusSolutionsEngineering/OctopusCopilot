class SpaceNotFound(Exception):
    """
    Represents the error associated with a space that was not found in Octopus
    """

    def __init__(self, space_name):
        self.space_name = space_name
        super().__init__(f'Space {self.space_name} not found in Octopus')
