import unittest

from domain.sanitizers.url_remover import strip_markdown_urls


class UrlValidation(unittest.TestCase):
    def test_url_removal(self):
        self.assertEquals(None, strip_markdown_urls(None))
        self.assertEquals(" ", strip_markdown_urls(" "))
        self.assertEquals("", strip_markdown_urls(""))
        self.assertEquals(1, strip_markdown_urls(1))
        self.assertEquals([], strip_markdown_urls([]))
        self.assertEquals({}, strip_markdown_urls({}))
        self.assertEquals("https://google.com", strip_markdown_urls("[https://google.com](https://google.com)"))
        self.assertEquals("http://google.com", strip_markdown_urls("[http://google.com](http://google.com)"))
        self.assertEquals("whatever", strip_markdown_urls("[whatever](http://google.com)"))
