import unittest

from domain.url.build_url import build_url


class BuildUrl(unittest.TestCase):
    def test_url_partial_name(self):
        url = build_url('https://example.org', '/path', dict(partialname='value'))
        self.assertEqual('https://example.org/path?partialname=value', url)

    def test_url(self):
        url = build_url('https://example.org', '/path', {'query': 'value', 'query&2': 'value2'})
        self.assertEqual('https://example.org/path?query=value&query%262=value2', url)

    def test_url_slash(self):
        url = build_url('https://example.org/', '/path', {'query': 'value', 'query&2': 'value2'})
        self.assertEqual('https://example.org/path?query=value&query%262=value2', url)

    def test_url_no_path(self):
        url = build_url('https://example.org/', None, {'query': 'value', 'query&2': 'value2'})
        self.assertEqual('https://example.org?query=value&query%262=value2', url)

    def test_url_no_query(self):
        url = build_url('https://example.org/', "hi", None)
        self.assertEqual('https://example.org/hi', url)

    def test_empty_url(self):
        with self.assertRaises(ValueError):
            build_url('', '/path', {'query': 'value'})
