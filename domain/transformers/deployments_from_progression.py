from domain.transformers.delete_links import delete_links


def get_deployment_array_from_progression(progression):
    deployments = delete_links(progression)
    deployments_context = list(map(lambda x: flatten_list(list(x["Deployments"].values())), deployments["Releases"]))
    return flatten_list(deployments_context)


def flatten_list(deployments):
    return [item for sublist in deployments for item in sublist]
