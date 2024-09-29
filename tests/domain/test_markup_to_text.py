import unittest

from domain.sanitizers.sanitize_markup import markdown_to_text, html_to_text


class TestMarkdownToText(unittest.TestCase):
    def test_markdown_to_text_basic(self):
        markdown_string = "# Heading\n\nThis is a **bold** text."
        result = markdown_to_text(markdown_string)
        self.assertEqual(result, "Heading This is a bold text ")

    def test_markdown_to_text_empty(self):
        markdown_string = ""
        result = markdown_to_text(markdown_string)
        self.assertEqual(result, "")

    def test_markdown_to_text_none(self):
        markdown_string = None
        result = markdown_to_text(markdown_string)
        self.assertEqual(result, "")

    def test_markdown_to_text_code_snippets(self):
        markdown_string = (
            "Here is some code:\n\n```\ndef hello():\n    print('Hello, world!')\n```"
        )
        result = markdown_to_text(markdown_string)
        self.assertEqual(
            result, "Here is some code  def hello        print  Hello  world   "
        )

    def test_markdown_to_text_links(self):
        markdown_string = "[GitHub](https://github.com)"
        result = markdown_to_text(markdown_string)
        self.assertEqual(result, "GitHub")

    def test_markdown_to_text_images(self):
        markdown_string = "![Alt text](https://example.com/image.jpg)"
        result = markdown_to_text(markdown_string)
        self.assertEqual(result, "")

    def test_html_to_text_basic(self):
        html_string = "<h1>Heading</h1><p>This is a <strong>bold</strong> text.</p>"
        result = html_to_text(html_string)
        self.assertEqual(result, "HeadingThis is a bold text.")

    def test_html_to_text_empty(self):
        html_string = ""
        result = html_to_text(html_string)
        self.assertEqual(result, "")

    def test_html_to_text_none(self):
        html_string = None
        result = html_to_text(html_string)
        self.assertEqual(result, "")

    def test_html_to_text_with_links(self):
        html_string = '<a href="https://github.com">GitHub</a>'
        result = html_to_text(html_string)
        self.assertEqual(result, "GitHub")

    def test_html_to_text_with_images(self):
        html_string = '<img src="https://example.com/image.jpg" alt="Alt text">'
        result = html_to_text(html_string)
        self.assertEqual(result, "")

    def test_html_to_text_with_nested_tags(self):
        html_string = "<div><p>Nested <span>text</span></p></div>"
        result = html_to_text(html_string)
        self.assertEqual(result, "Nested text")
