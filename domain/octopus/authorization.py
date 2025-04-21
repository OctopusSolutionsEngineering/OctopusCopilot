def get_auth(auth):
    api_key = ""
    access_token = ""

    if auth.startswith("API-"):
        api_key = auth
    else:
        access_token = auth

    return api_key, access_token
