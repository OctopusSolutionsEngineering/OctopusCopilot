from domain.exceptions.request_failed import RequestFailed
from domain.logging.app_logging import configure_logging
from infrastructure.http_pool import http

logger = configure_logging(__name__)


def exchange_code(code, get_url, get_client_secret, get_client_id, get_redirect_url):
    """
    Exchanges an OAuth code for an ID token.
    :param code: The Oauth code
    :param get_url: A function returning the OAuth provider token URL
    :param get_client_secret: A function returning the client secret
    :param get_client_id:   A function returning the client ID
    :param get_redirect_url: A function returning the redirection URL
    :return: The ID token
    """

    logger.info("exchange_code - Enter")

    resp = http.request_encode_body("POST",
                                    get_url(),
                                    encode_multipart=False,
                                    fields={
                                        'grant_type': 'authorization_code',
                                        'code': code,
                                        'client_id': get_client_id(),
                                        'client_secret': get_client_secret(),
                                        'redirect_url': get_redirect_url()
                                    })

    if resp.status != 200:
        logger.info("exchange_code - return code: " + str(resp.status))
        raise RequestFailed(f"Request failed with " + resp.data.decode('utf-8'))

    json = resp.json()

    return json['id_token']
