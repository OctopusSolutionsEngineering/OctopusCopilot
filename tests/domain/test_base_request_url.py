import unittest

import azure.functions as func

from domain.url.url_builder import base_request_url


class BaseRequestUrlTest(unittest.TestCase):
    def test_base_request_url(self):
        request_url = base_request_url(func.HttpRequest(
            url='https://example.org',
            headers={},
            method="GET",
            body=bytes("test", "utf-8")))
        self.assertEqual('https://example.org', request_url)

    def test_base_request_url_forwarded(self):
        request_url = base_request_url(func.HttpRequest(
            url='https://example.org',
            headers={
                'X-Forwarded-Host': 'forwarded.org',
                'X-Forwarded-Proto': 'http'
            },
            method="GET",
            body=bytes("test", "utf-8")))
        self.assertEqual('http://forwarded.org', request_url)
