from domain.transformers.delete_links import delete_links


def get_deployment_array_from_progression(progression):
    deployments = delete_links(progression)
    deployments_context = list(map(lambda x: list(x["Deployments"].values()), deployments["Releases"]))
    return [item for sublist in deployments_context for item in sublist]
