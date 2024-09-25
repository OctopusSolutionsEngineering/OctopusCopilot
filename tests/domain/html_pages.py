import unittest

from domain.b64.b64_encoder import encode_string_b64, decode_string_b64
from domain.view.html.html_pages import get_redirect_page


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
