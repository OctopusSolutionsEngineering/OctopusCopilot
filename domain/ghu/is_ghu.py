def is_ghu_server(server):
    """
    A test to see if the user is logged into the GHU server
    :param server: The Octopus server
    :return:
    """
    return server.startswith("https://github-universe-2024.octopus.app")
