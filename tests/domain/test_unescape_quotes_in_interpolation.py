import unittest

from domain.sanitizers.terraform import unescape_quotes_in_interpolation


class TestUnescapeQuotesInInterpolation(unittest.TestCase):
    def test_observed_tag_count(self):
        config = (
            'resource "octopusdeploy_tag" "tagset_q49_tier_tag_gold" {\n'
            '  count = "${length(try([for item in try(data.octopusdeploy_tag_sets.tagset_q49_tier.tag_sets[0].tags, []) : item if item.name == \\"Gold\\"], [])) != 0 ? 0 : 1}"\n'
            '  name  = "Gold"\n'
            "}\n"
        )
        result = unescape_quotes_in_interpolation(config)
        self.assertIn('item if item.name == "Gold"], [])) != 0 ? 0 : 1}"', result)
        self.assertNotIn('\\"', result)

    def test_escaped_quotes_outside_interpolation_are_unchanged(self):
        config = '"Octopus.Action.Script.ScriptBody" = "echo \\"${var.name}\\" and \\"done\\""'
        self.assertEqual(config, unescape_quotes_in_interpolation(config))

    def test_literal_interpolation_is_unchanged(self):
        config = '"Octopus.Action.Script.ScriptBody" = "echo \\"$${READY:-\\"no\\"}\\""'
        self.assertEqual(config, unescape_quotes_in_interpolation(config))

    def test_nested_braces(self):
        config = 'value = "${jsonencode({ name = \\"x\\" })}"'
        self.assertEqual('value = "${jsonencode({ name = "x" })}"', unescape_quotes_in_interpolation(config))

    def test_unbalanced_interpolation_is_unchanged(self):
        config = 'value = "${length(x == \\"a\\"\nother = \\"b\\"'
        self.assertEqual(config, unescape_quotes_in_interpolation(config))

    def test_valid_interpolation_is_unchanged(self):
        config = 'count = "${length(local.x) != 0 ? 0 : 1}"\nname = "${var.a == "b" ? "c" : "d"}"'
        self.assertEqual(config, unescape_quotes_in_interpolation(config))

    def test_empty(self):
        self.assertEqual("", unescape_quotes_in_interpolation(""))
        self.assertIsNone(unescape_quotes_in_interpolation(None))


if __name__ == "__main__":
    unittest.main()
