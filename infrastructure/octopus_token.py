from domain.exceptions.request_failed import RequestFailed
from domain.logging.app_logging import configure_logging
from infrastructure.http_pool import http

logger = configure_logging()


def exchange_id_token_for_api_key(id_token, service_account_id, my_get_octopus_api):
    """
    This function exchanges an ID token for an Octopus API key.
    https://octopus.com/docs/octopus-rest-api/openid-connect/other-issuers#OidcOtherIssuers-TokenExchange
    :param id_token: The OIDC token
    :param service_account_id: The service account configured to trust the OIDC token
    :param my_get_octopus_api: A function returning the Octopus URL
    :return: An octopus API key
    """

    logger.info("exchange_id_token_for_api_key - Enter")

    if not id_token or not isinstance(id_token, str) or not id_token.strip():
        raise ValueError('id_token must be a non-empty string.')

    if not service_account_id or not isinstance(service_account_id, str) or not service_account_id.strip():
        raise ValueError('service_account_id must be a non-empty string.')

    if my_get_octopus_api is None:
        raise ValueError('my_get_api_key must be function returning the Octopus Url.')

    # Look up the OpenID configuration endpoint
    open_id_configuration = my_get_octopus_api() + "/.well-known/openid-configuration"
    resp = http.request("GET", open_id_configuration)

    if resp.status != 200:
        raise RequestFailed(f"Request to {open_id_configuration} failed with {resp.data.decode('utf-8')}")

    json = resp.json()

    logger.info(json)

    # Exchange the token
    resp = http.request_encode_body("POST",
                                    json['token_endpoint'],
                                    encode_multipart=False,
                                    fields={
                                        'grant_type': 'urn:ietf:params:oauth:grant-type:token-exchange',
                                        'audience': service_account_id,
                                        'subject_token_type': 'urn:ietf:params:oauth:token-type:jwt',
                                        'subject_token': id_token
                                    })

    if resp.status != 200:
        raise RequestFailed(f"Request to {json['token_endpoint']} failed with {resp.data.decode('utf-8')}")

    json = resp.json()
    return json['access_token']
