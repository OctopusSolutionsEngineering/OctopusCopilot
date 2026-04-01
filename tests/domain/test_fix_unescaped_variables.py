import unittest

from domain.sanitizers.terraform import fix_unescaped_variables


class FixUnescapedVariablesTests(unittest.TestCase):
    def test_no_change_when_no_dollar_brace(self):
        """Values with no ${ are left unchanged."""
        config = '"Octopus.Action.Script.ScriptBody" = "echo hello"'
        self.assertEqual(config, fix_unescaped_variables(config))

    def test_no_change_when_no_dollar_brace_two_lines(self):
        """Values with no ${ are left unchanged."""
        config = '"Octopus.Action.Script.ScriptBody" = "echo hello"\n"Octopus.Action.Script.ScriptBody" = "echo hello 2"'
        self.assertEqual(config, fix_unescaped_variables(config))

    def test_no_change_when_value_starts_with_dollar(self):
        """[^$] means values that start with $ (intentional Terraform variable refs) are not touched."""
        config = '"key" = "${var.name}"'
        self.assertEqual(config, fix_unescaped_variables(config))

    def test_no_change_when_value_starts_with_dollar_and_var(self):
        """[^$] means values that start with $ (intentional Terraform variable refs) are not touched."""
        config = '"key" = "${var.name}${var.name}"'
        self.assertEqual(config, fix_unescaped_variables(config))

    def test_no_change_when_dollar_brace_not_at_end_of_value(self):
        config = '"key" = "hello ${var.name}"'
        self.assertEqual('"key" = "hello $${var.name}"', fix_unescaped_variables(config))

    def test_escapes_single_char_prefix_before_dollar_brace(self):
        config = '"key" = "a${b}"'
        self.assertEqual('"key" = "a$${b}"', fix_unescaped_variables(config))

    def test_escapes_multi_char_prefix_before_dollar_brace(self):
        config = '"key" = "ab${"'
        self.assertEqual('"key" = "ab$${"', fix_unescaped_variables(config))

    def test_uses_last_group2_when_multiple_dollar_braces(self):
        config = '"key" = "a${b${"'
        self.assertEqual('"key" = "a$${b$${"', fix_unescaped_variables(config))

    def test_replaces_all_matches(self):
        config = '"key1" = "a${"\n"key2" = "b${"'
        result = fix_unescaped_variables(config)
        self.assertEqual('"key1" = "a$${"\n"key2" = "b$${"', result)

    def test_empty_string_unchanged(self):
        self.assertEqual("", fix_unescaped_variables(""))

    def test_raises_on_none_input(self):
        with self.assertRaises(TypeError):
            fix_unescaped_variables(None)


if __name__ == "__main__":
    unittest.main()

