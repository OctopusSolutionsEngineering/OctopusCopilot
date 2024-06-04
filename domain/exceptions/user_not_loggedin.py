class UserNotLoggedIn(Exception):
    """
    Represents a GitHub user that has not logged in
    """
    pass


class OctopusApiKeyInvalid(Exception):
    """
    Represents an invalid or expired Octopus API key
    """
    pass


class OctopusVersionInvalid(Exception):
    """
    Represents an octopus instance that is too old
    """

    def __init__(self, version):
        self.version = version
        super().__init__(f'{version} is to old')
