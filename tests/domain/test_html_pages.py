import os
import unittest

import azure.functions as func
from domain.view.html.html_pages import get_redirect_page, get_login_page


class AdminUser(unittest.TestCase):
    def test_get_redirect_page(self):
        # The path changes depending on how the test is run.
        # From the IDE, the path is relative to the test file.
        # From the CI/CD pipeline, the path is relative to the root of the repository.
        search_path = (
            "../../html/templates"
            if os.path.exists("../../html/templates")
            else "html/templates"
        )

        output = get_redirect_page(
            "http://example.com?redirect=path",
            "Redirecting to example.com",
            search_path,
        )
        self.assertTrue(
            'window.location.href = "http://example.com?redirect=path";' in output
        )

    def test_get_login_page(self):
        # The path changes depending on how the test is run.
        # From the IDE, the path is relative to the test file.
        # From the CI/CD pipeline, the path is relative to the root of the repository.
        search_path = (
            "../../html/templates"
            if os.path.exists("../../html/templates")
            else "html/templates"
        )

        output = get_login_page(
            func.HttpRequest(
                method="GET",
                body="".encode("utf8"),
                url="/api/octopus",
                params=None,
                headers={},
            ),
            search_path,
        )
        self.assertFalse("Codefresh" in output)
