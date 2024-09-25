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


class SlackRequestFailed(Exception):
    """
    Represents a failed request to the Slack api
    """

    pass


class ZenDeskRequestFailed(Exception):
    """
    Represents a failed request to the ZenDesk api
    """

    pass


class StoryBlokRequestFailed(Exception):
    """
    Represents a failed request to the StoryBlok api
    """

    pass


class CodefreshRequestFailed(Exception):
    """
    Represents a failed request to the Codefresh API
    """

    pass
