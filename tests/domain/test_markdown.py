import unittest
from domain.sanitizers.markdown_remove import remove_markdown_code_block


class TestRemoveMarkdownCodeBlock(unittest.TestCase):
    def test_remove_markdown_code_block_with_code_block(self):
        text = "```\nexample code\n```"
        result = remove_markdown_code_block(text)
        self.assertEqual(result, "\nexample code\n")

    def test_remove_markdown_code_block_with_syntax(self):
        text = "```hcl\nexample code\n```"
        result = remove_markdown_code_block(text)
        self.assertEqual(result, "\nexample code\n")

    def test_remove_markdown_code_block_without_code_block(self):
        text = "example code"
        result = remove_markdown_code_block(text)
        self.assertEqual(result, "example code")

    def test_remove_markdown_code_block_partial_code_block(self):
        text = "```example code"
        result = remove_markdown_code_block(text)
        self.assertEqual(result, "```example code")

    def test_remove_markdown_code_block_empty_string(self):
        text = ""
        result = remove_markdown_code_block(text)
        self.assertEqual(result, "")

    def test_remove_markdown_code_block_only_backticks(self):
        text = "```"
        result = remove_markdown_code_block(text)
        self.assertEqual(result, "")


if __name__ == "__main__":
    unittest.main()
