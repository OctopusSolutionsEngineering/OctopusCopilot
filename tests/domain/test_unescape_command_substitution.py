import unittest

from domain.sanitizers.terraform import unescape_command_substitution


class TestUnescapeCommandSubstitution(unittest.TestCase):
    def test_observed_date_substitution(self):
        config = '"Octopus.Action.Script.ScriptBody" = "aws s3 cp report.json \\"s3://q33-reports/#{Octopus.Release.Number}/report-$$(date +%Y%m%d).json\\""'
        result = unescape_command_substitution(config)
        self.assertIn("report-$(date +%Y%m%d).json", result)
        self.assertNotIn("$$(", result)

    def test_escaped_interpolation_is_unchanged(self):
        config = '"echo $${HOME} and $(whoami) and $$ alone"'
        self.assertEqual(config, unescape_command_substitution(config))

    def test_triple_dollar_is_unchanged(self):
        config = '"echo $$$(whoami)"'
        self.assertEqual(config, unescape_command_substitution(config))

    def test_heredoc_body(self):
        config = 'body = <<EOT\nNOW=$$(date)\nEOT\n'
        self.assertEqual('body = <<EOT\nNOW=$(date)\nEOT\n', unescape_command_substitution(config))

    def test_empty(self):
        self.assertEqual("", unescape_command_substitution(""))
        self.assertIsNone(unescape_command_substitution(None))


if __name__ == "__main__":
    unittest.main()
