import unittest

from domain.sanitizers.terraform import truncate_long_project_names

LONG_NAME = "Order Processing " + "Service " * 40


class TruncateLongProjectNamesTests(unittest.TestCase):
    def test_truncates_name_held_in_variable_default(self):
        config = (
            'variable "project_orders_name" {\n'
            "  type    = string\n"
            f'  default = "{LONG_NAME}"\n'
            "}\n"
            'data "octopusdeploy_projects" "project_orders" {\n'
            f'  partial_name = "{LONG_NAME}"\n'
            "}\n"
            'resource "octopusdeploy_project" "project_orders" {\n'
            '  name = "${var.project_orders_name}"\n'
            "}\n"
        )
        result = truncate_long_project_names(config)
        expected = LONG_NAME[:200].rstrip()
        self.assertNotIn(LONG_NAME, result)
        self.assertEqual(2, result.count(f'"{expected}"'))
        self.assertIn('name = "${var.project_orders_name}"', result)

    def test_truncates_literal_name(self):
        config = f'resource "octopusdeploy_project" "p" {{\n  name = "{LONG_NAME}"\n}}\n'
        result = truncate_long_project_names(config)
        self.assertIn(f'name = "{LONG_NAME[:200].rstrip()}"', result)

    def test_keeps_short_names(self):
        config = 'resource "octopusdeploy_project" "p" {\n  name = "Short"\n}\n'
        self.assertEqual(config, truncate_long_project_names(config))

    def test_counts_unicode_characters_not_bytes(self):
        name = "注文処理" * 45  # 180 characters, 540 bytes
        config = f'resource "octopusdeploy_project" "p" {{\n  name = "{name}"\n}}\n'
        self.assertEqual(config, truncate_long_project_names(config))

    def test_counts_emoji_as_two_characters(self):
        name = "🚀" * 101  # 101 code points, 202 UTF-16 code units
        config = f'resource "octopusdeploy_project" "p" {{\n  name = "{name}"\n}}\n'
        result = truncate_long_project_names(config)
        self.assertIn(f'name = "{"🚀" * 100}"', result)

    def test_ignores_long_names_on_other_resources(self):
        config = f'resource "octopusdeploy_environment" "e" {{\n  name = "{LONG_NAME}"\n}}\n'
        self.assertEqual(config, truncate_long_project_names(config))


if __name__ == "__main__":
    unittest.main()
