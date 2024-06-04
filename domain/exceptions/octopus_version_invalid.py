class OctopusVersionInvalid(Exception):
    """
    Represents the error associated with an invalid Octopus version
    """

    def __init__(self, version):
        self.version = version
        super().__init__(f'{version} is not a valid Octopus version number')
