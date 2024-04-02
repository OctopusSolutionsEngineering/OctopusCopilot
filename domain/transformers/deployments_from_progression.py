from domain.sanitizers.sanitized_list import flatten_list


def get_deployment_progression(progression, environment_id, channel_id):
    """
    Gets the list of deployments for a specific environment from the progression of a project
    :param progression: The raw progression result
    :param environment_id: The environment to limit the results to
    :param channel_id: The channel to limit the results to
    :return: The of deployments
    """

    deployments_context = list(map(lambda x: flatten_list(list(x["Deployments"].values())), progression["Releases"]))
    flattened_deployments = flatten_list(deployments_context)

    environment_deployments = [deployment for deployment in flattened_deployments if
                               deployment["EnvironmentId"] == environment_id and deployment["ChannelId"] == channel_id]

    return environment_deployments
