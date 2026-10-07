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


class TestRemoveProseAroundCodeBlock(unittest.TestCase):
    def test_removes_prose_before_code_block(self):
        text = (
            "Looking at the error, the issue is that the `name` attribute is truncated.\n"
            "I need to fix this.\n"
            '```hcl\nresource "octopusdeploy_project_group" "pg" {\n  name = "x"\n}\n```'
        )
        result = remove_markdown_code_block(text)
        self.assertEqual(
            result, 'resource "octopusdeploy_project_group" "pg" {\n  name = "x"\n}\n'
        )

    def test_removes_prose_and_a_stray_trailing_fence_pair(self):
        text = (
            "Here is the fixed configuration.\n"
            '```hcl\nprovider "octopusdeploy" {\n}\n```\n```'
        )
        result = remove_markdown_code_block(text)
        self.assertEqual(result, 'provider "octopusdeploy" {\n}\n')

    def test_joins_multiple_fenced_blocks(self):
        text = "Two parts:\n```hcl\nvariable \"a\" {\n}\n```\nand\n```hcl\nvariable \"b\" {\n}\n```"
        result = remove_markdown_code_block(text)
        self.assertIn('variable "a" {', result)
        self.assertIn('variable "b" {', result)
        self.assertNotIn("```", result)
        self.assertNotIn("Two parts", result)

    def test_leaves_configuration_with_a_fence_in_a_heredoc_unchanged(self):
        text = (
            'resource "octopusdeploy_process_step" "s" {\n'
            '  notes = <<-EOT\n```bash\necho hi\n```\nEOT\n}'
        )
        self.assertEqual(remove_markdown_code_block(text), text)

    def test_leaves_prose_without_a_closed_block_unchanged(self):
        text = "Some prose\n```hcl\nunterminated"
        self.assertEqual(remove_markdown_code_block(text), text)

    def test_leaves_prose_before_only_empty_fences_unchanged(self):
        text = "Some prose\n```\n```"
        self.assertEqual(remove_markdown_code_block(text), text)

    def test_removes_prose_before_unfenced_configuration(self):
        text = (
            "Looking at the error, the issue is that the `container` blocks are wrong.\n\n"
            "Let me also check for other issues.\n\n"
            'provider "octopusdeploy" {\n}\n'
        )
        self.assertEqual(
            remove_markdown_code_block(text), 'provider "octopusdeploy" {\n}\n'
        )

    def test_keeps_leading_comments_before_unfenced_configuration(self):
        text = '# Provider\n\nterraform {\n}\n'
        self.assertEqual(remove_markdown_code_block(text), text)

    def test_ignores_prose_that_starts_with_a_block_keyword(self):
        text = "data sources are not needed here\nand neither is this"
        self.assertEqual(remove_markdown_code_block(text), text)


if __name__ == "__main__":
    unittest.main()


class UnclosedFenceTest(unittest.TestCase):
    def test_removes_unclosed_opening_fence(self):
        from domain.sanitizers.markdown_remove import remove_markdown_code_block

        self.assertEqual(
            'resource "octopusdeploy_project" "p" {\n  name = "x"',
            remove_markdown_code_block('```hcl\nresource "octopusdeploy_project" "p" {\n  name = "x"'),
        )

    def test_keeps_closed_fence_handling(self):
        from domain.sanitizers.markdown_remove import remove_markdown_code_block

        self.assertEqual(
            'resource "a" "b" {}',
            remove_markdown_code_block('```hcl\nresource "a" "b" {}\n```').strip(),
        )
