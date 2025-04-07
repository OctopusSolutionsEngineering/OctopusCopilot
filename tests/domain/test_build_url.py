import unittest
from urllib.parse import urlparse

from domain.url.build_url import build_url, is_octopus_cloud_local_or_example


class BuildUrl(unittest.TestCase):
    def test_url_partial_name(self):
        url = build_url("https://example.org", "/path", dict(partialname="value"))
        self.assertEqual("https://example.org/path?partialname=value", url)

    def test_url(self):
        url = build_url(
            "https://example.org", "/path", {"query": "value", "query&2": "value2"}
        )
        self.assertEqual("https://example.org/path?query=value&query%262=value2", url)

    def test_url_slash(self):
        url = build_url(
            "https://example.org/", "/path", {"query": "value", "query&2": "value2"}
        )
        self.assertEqual("https://example.org/path?query=value&query%262=value2", url)

    def test_url_no_path(self):
        url = build_url(
            "https://example.org/", None, {"query": "value", "query&2": "value2"}
        )
        self.assertEqual("https://example.org?query=value&query%262=value2", url)

    def test_url_no_query(self):
        url = build_url("https://example.org/", "hi", None)
        self.assertEqual("https://example.org/hi", url)

    def test_empty_url(self):
        with self.assertRaises(ValueError):
            build_url("", "/path", {"query": "value"})

    def test_octopus_cloud_url(self):
        url = urlparse("https://example.octopus.app")
        self.assertTrue(is_octopus_cloud_local_or_example(url))

    def test_testoctopus_url(self):
        url = urlparse("https://example.testoctopus.com")
        self.assertTrue(is_octopus_cloud_local_or_example(url))

    def test_localhost_url(self):
        url = urlparse("http://localhost")
        self.assertTrue(is_octopus_cloud_local_or_example(url))

    def test_127_0_0_1_url(self):
        url = urlparse("http://127.0.0.1")
        self.assertTrue(is_octopus_cloud_local_or_example(url))

    def test_non_octopus_url(self):
        url = urlparse("https://example.com")
        self.assertFalse(is_octopus_cloud_local_or_example(url))
