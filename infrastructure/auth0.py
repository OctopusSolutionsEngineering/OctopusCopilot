from domain.exceptions.request_failed import RequestFailed
from domain.logging.app_logging import configure_logging
from infrastructure.http_pool import http

logger = configure_logging(__name__)


def create_management_api_token(get_auth0_domain, get_client_id, get_client_secret):
    logger.info("create_management_api_token - Enter")

    resp = http.request_encode_body("POST",
                                    get_auth0_domain() + "/oauth/token",
                                    encode_multipart=False,
                                    fields={
                                        'grant_type': 'client_credentials',
                                        'client_id': get_client_id(),
                                        'client_secret': get_client_secret(),
                                        'audience': get_auth0_domain() + "/api/v2/"
                                    })

    if resp.status != 200:
        logger.info("create_management_api_token - return code: " + str(resp.status))
        raise RequestFailed(f"Request failed with " + resp.data.decode('utf-8'))

    json = resp.json()

    return json['access_token']


def resource_server_exists(get_auth0_domain, service_account_id, access_token):
    headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer " + access_token
    }

    resp = http.request("GET",
                        get_auth0_domain() + "/api/v2/resource-servers/" + service_account_id,
                        headers=headers)

    if resp.status == 200:
        return True

    if resp.status == 404:
        return False

    logger.info("resource_server_exists - return code: " + str(resp.status))
    raise RequestFailed(f"Request failed with " + resp.data.decode('utf-8'))


def create_resource_server(get_auth0_domain, service_account_id, access_token):
    headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer " + access_token
    }

    resource_server = {
        "name": service_account_id,
        "identifier": service_account_id,
    }

    resp = http.request("POST",
                        get_auth0_domain() + " /api/v2/resource-servers",
                        resource_server,
                        headers=headers)

    if resp.status != 200:
        logger.info("create_resource_server - return code: " + str(resp.status))
        raise RequestFailed(f"Request failed with " + resp.data.decode('utf-8'))

    return resp.json()['identifier']
