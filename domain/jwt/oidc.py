from jwt import JWT

instance = JWT()


def parse_jwt(token):
    return instance.decode(message=token, do_verify=False, do_time_check=True)
