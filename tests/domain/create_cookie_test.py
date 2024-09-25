import datetime
import unittest

import pytz

from domain.url.build_cookie import create_cookie, get_cookie_expiration


class CreateCookieTest(unittest.TestCase):
    def test_create_cookie(self):
        cookie = create_cookie("session", "123", 1, "/", True)
        self.assertEqual(cookie["session"].value, "123")
        self.assertEqual(cookie["session"]["path"], "/")
        self.assertTrue(cookie["session"]["secure"])
        self.assertEqual(
            cookie["session"].OutputString(),
            f"session=123; expires={cookie['session']['expires']}; Path=/; SameSite=Strict; Secure",
        )

    def test_get_cookie_expiration(self):
        tz = pytz.timezone("Australia/Brisbane")
        now = tz.localize(datetime.datetime(2024, 9, 25, 12, 0, 0, 0))
        expiration = get_cookie_expiration(now, 1)
        self.assertEqual("Wed, 25 Sep 2024 03:00:00 GMT", expiration)
