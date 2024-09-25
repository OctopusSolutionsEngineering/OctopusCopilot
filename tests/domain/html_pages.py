import unittest

import azure.functions as func
from domain.view.html.html_pages import get_redirect_page, get_login_page


class AdminUser(unittest.TestCase):
    def test_get_redirect_page(self):
        output = get_redirect_page(
            "http://example.com?redirect=path",
            "Redirecting to example.com",
            "../../html/templates",
        )
        self.assertTrue(
            'window.location.href = "http://example.com?redirect=path";' in output
        )

    def test_get_login_page(self):
        output = get_login_page(
            func.HttpRequest(
                method="GET",
                body="".encode("utf8"),
                url="/api/octopus",
                params=None,
                headers={},
            ),
            "../../html/templates",
        )
        self.assertFalse("Codefresh" in output)
