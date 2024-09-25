import datetime
from http.cookies import SimpleCookie

import pytz


def get_cookie_expiration(now, expires_hours):
    expiration = now + datetime.timedelta(hours=expires_hours)
    gmt_timezone = pytz.timezone("GMT")
    expiration = expiration.astimezone(gmt_timezone)
    return expiration.strftime("%a, %d %b %Y %H:%M:%S GMT")


def create_cookie(
    cookie_name, cookie_value, expires_hours, path="/", secure=True, same_site="Strict"
):
    # Create a cookie
    cookie = SimpleCookie()

    # Set a value for the cookie
    cookie[cookie_name] = cookie_value

    # Set the expiration time
    cookie["session"]["expires"] = get_cookie_expiration(
        datetime.datetime.now(), expires_hours
    )
    cookie["session"]["path"] = path
    cookie["session"]["secure"] = secure
    cookie["session"]["samesite"] = same_site

    return cookie
