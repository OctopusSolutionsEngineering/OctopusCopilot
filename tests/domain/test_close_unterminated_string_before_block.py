import unittest

from domain.sanitizers.terraform import close_unterminated_string_before_block


class TestCloseUnterminatedStringBeforeBlock(unittest.TestCase):
    def test_observed_runaway_project_name(self):
        config = (
            'variable "project_300_x_name_name" {\n'
            "  type        = string\n"
            '  default     = "' + "x" * 50 + "\n"
            "locals {\n"
            '  a = [for p in data.octopusdeploy_projects.x.projects : p if p.name == "Empty Name Project"]\n'
            "}\n"
        )
        result = close_unterminated_string_before_block(config)
        self.assertIn('  default     = "' + "x" * 50 + '"\n}\nlocals {', result)
        self.assertTrue(result.endswith('"Empty Name Project"]\n}\n'))

    def test_balanced_config_is_unchanged(self):
        config = (
            'resource "octopusdeploy_project" "p" {\n'
            '  name = "A \\"quoted\\" { name"\n'
            '  description = "x"\n'
            "}\n"
            'variable "v" {\n'
            '  default = "y"\n'
            "}\n"
        )
        self.assertEqual(config, close_unterminated_string_before_block(config))

    def test_heredoc_is_unchanged(self):
        config = (
            'resource "octopusdeploy_process_step" "s" {\n'
            "  execution_properties = {\n"
            '    "Octopus.Action.Script.ScriptBody" = <<EOT\n'
            'echo "unbalanced\n'
            "EOT\n"
            "  }\n"
            "}\n"
            "locals {\n"
            "}\n"
        )
        self.assertEqual(config, close_unterminated_string_before_block(config))

    def test_unclosed_string_not_followed_by_block_is_unchanged(self):
        config = 'resource "a" "b" {\n  name = "abc\n  other = 1\n}\n'
        self.assertEqual(config, close_unterminated_string_before_block(config))

    def test_empty(self):
        self.assertEqual("", close_unterminated_string_before_block(""))
        self.assertIsNone(close_unterminated_string_before_block(None))


if __name__ == "__main__":
    unittest.main()
