import unittest

from domain.url.build_cookie import create_cookie


class CreateCookieTest(unittest.TestCase):
    def test_create_cookie(self):
        cookie = create_cookie("session", "123", 1, "/", True)
        self.assertEqual(cookie["session"].value, "123")
        self.assertEqual(cookie["session"]["path"], "/")
        self.assertTrue(cookie["session"]["secure"])
        self.assertEqual(
            cookie["session"].OutputString(),
            f"session=123; expires={cookie["session"]["expires"]}; Path=/; SameSite=Strict; Secure",
        )
