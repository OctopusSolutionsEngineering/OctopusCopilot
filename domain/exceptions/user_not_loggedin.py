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
