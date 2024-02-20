from jwt import jwt


def parse_jwt(token):
    return jwt.decode(jwt=token,
                      algorithms=["HS256"])
