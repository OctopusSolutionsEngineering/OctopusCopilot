import datetime
from http.cookies import SimpleCookie


def create_cookie(cookie_name, cookie_value, expires_hours):
    # Create a cookie
    cookie = SimpleCookie()

    # Set a value for the cookie
    cookie[cookie_name] = cookie_value

    # Set the expiration time
    expiration = datetime.datetime.now()
    expiration = expiration + datetime.timedelta(hours=expires_hours)
    cookie["session"]["expires"] = expiration.strftime("%a, %d-%b-%Y %H:%M:%S PST")

    return cookie
