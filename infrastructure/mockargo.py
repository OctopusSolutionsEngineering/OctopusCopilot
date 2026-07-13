import json
import os

from domain.logging.app_logging import configure_logging
from infrastructure.http_pool import http
from infrastructure.octopus import logging_wrapper

logger = configure_logging(__name__)


@logging_wrapper
def create_mock_argocd_gateway(
    url, access_token, space_id, environments, project_slug, app_details
):
    """
    Creates a new Argo CD Gateway. See https://github.com/OctopusDeploy/octopus-argocd-gateway/tree/mattc/mockedargo.
    :param url: The URL of the Argo CD server
    :param access_token: The Mock git access token
    :param space_id: The Argo CD space ID
    :param environments: The list of environments
    :param project_slug: The project slug
    :param app_details: The details of the applications
    """

    try:
        if access_token is None:
            return None

        api = os.getenv("MOCKARGO_API_URL") + "/api/applications"

        body = {
            "server_api_url": url,
            "server_access_token": access_token,
            "space_id": space_id,
            "gateway_name": "Mocked Argo CD Instance",
            "environments": environments,
            "tenants": [],
            "applications": [],
        }

        for app_detail in app_details:
            body["applications"].append(
                {
                    "name": app_detail["name"],
                    "project": "default",
                    "namespace": "argocd",
                    "destination_server": "https://kubernetes.default.svc",
                    "destination_namespace": app_detail["destination_namespace"],
                    "repo_url": "https://mockgit.octopusdemos.com/repo/argocd",
                    "path": app_detail["path"],
                    "sync_status": "Synced",
                    "health_status": "Healthy",
                    "octopus_project": project_slug,
                    "octopus_environment": app_detail["octopus_environment"],
                }
            )

        headers = {
            "Content-Type": "application/json",
        }

        resp = http.request(
            "POST",
            api,
            headers=headers,
            body=json.dumps(body),
        )

        if resp.status != 200:
            # This is just a best effort and must not interfere with the main flow
            logger.warn(f"Failed to create Argo CD gateway. Status: {resp.status}")
        else:
            logger.info(f"Successfully created Argo CD gateway for space {space_id}.")

    except Exception as e:
        # This is just a best effort and so we swallow exceptions
        logger.warn(f"Exception occurred while creating Argo CD gateway: {str(e)}")
