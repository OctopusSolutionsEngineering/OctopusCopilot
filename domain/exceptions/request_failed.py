class OctopusRequestFailed(Exception):
    """
    Represents a failed request to the Octopus API
    """
    pass


class GitHubRequestFailed(Exception):
    """
    Represents a failed request to the GitHub api
    """
    pass


class ZenDeskRequestFailed(Exception):
    """
    Represents a failed request to the ZenDesk api
    """
    pass
