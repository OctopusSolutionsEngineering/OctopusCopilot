def get_auth(auth):
    stripped_auth = auth.strip()
    api_key = ""
    access_token = ""

    if stripped_auth.casefold().startswith("api-"):
        api_key = stripped_auth
    else:
        access_token = stripped_auth

    return api_key, access_token
