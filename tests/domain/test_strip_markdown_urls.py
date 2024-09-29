import unittest

from domain.sanitizers.url_remover import strip_markdown_urls


class UrlValidation(unittest.TestCase):
    def test_url_removal(self):
        self.assertEqual(None, strip_markdown_urls(None))
        self.assertEqual(" ", strip_markdown_urls(" "))
        self.assertEqual("", strip_markdown_urls(""))
        self.assertEqual(1, strip_markdown_urls(1))
        self.assertEqual([], strip_markdown_urls([]))
        self.assertEqual({}, strip_markdown_urls({}))
        self.assertEqual("https://google.com", strip_markdown_urls("[https://google.com](https://google.com)"))
        self.assertEqual("http://google.com", strip_markdown_urls("[http://google.com](http://google.com)"))
        self.assertEqual("whatever", strip_markdown_urls("[whatever](http://google.com)"))
