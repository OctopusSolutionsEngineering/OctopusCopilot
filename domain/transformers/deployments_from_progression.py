from domain.sanitizers.sanitized_list import flatten_list
from domain.transformers.delete_links import delete_links


def get_deployment_array_from_progression(progression, environment_names, max_results=None):
    """
    Gets the list of deployments for a specific environment from the progression of a project
    :param progression: The raw progression result
    :param environment_names: The environments to limit the results to
    :param max_results: The maximum number of results to return
    :return: The list of deployments
    """
    deployments = delete_links(progression)
    environment_ids = [environment["Id"] for environment in deployments["Environments"] if
                       environment["Name"] in environment_names] if environment_names else []

    deployments_context = list(map(lambda x: flatten_list(list(x["Deployments"].values())), deployments["Releases"]))
    flattened_deployments = flatten_list(deployments_context)

    environment_deployments = [deployment for deployment in flattened_deployments if
                               deployment[
                                   "EnvironmentId"] in environment_ids] if environment_ids else flattened_deployments

    if max_results:
        environment_deployments = environment_deployments[:max_results]

    return environment_deployments


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
