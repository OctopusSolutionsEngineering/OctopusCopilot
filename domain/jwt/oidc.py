from jwt import JWT

instance = JWT()


def parse_jwt(token):
    """
    Parse the ID token, failing if the token has expired, but otherwise don't validate the token.
    We assume Octopus does any validation required to ensure this is a signed OIDC token, while
    our agent is just concerned with maintaining tokens that have not expired.
    :param token: The OIDC token
    :return: The parsed token
    """
    return instance.decode(message=token, do_verify=False, do_time_check=True)
