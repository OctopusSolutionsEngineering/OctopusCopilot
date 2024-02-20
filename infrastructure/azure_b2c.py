from domain.exceptions.request_failed import RequestFailed
from infrastructure.http_pool import http


def exchange_code(code, get_url, get_client_secret, get_client_id, get_redirect_url):
    """
    Exchanges an OAuth code for an ID token.
    :param code: The Oauth code
    :param get_url: A function returning the OAuth provider token URL
    :param get_client_secret: A function returning the client secret
    :param get_client_id:   A function returning the client ID
    :param get_redirect_url: A function returning the redirection URL
    :return:
    """
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
        raise RequestFailed(f"Request failed with " + resp.data.decode('utf-8'))

    json = resp.json()

    return json['id_token']
