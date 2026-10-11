import unittest

from domain.sanitizers.terraform import sanitize_name_attributes

TEMPLATE_VARIABLE = r'''resource "octopusdeploy_variable" "terraform_configuration" {
  value        = "variable \"cidr\" {}\nresource \"azurerm_resource_group\" \"rg\" {\n  name     = \"rg-$${var.cidr}\"\n  location = \"australiaeast\"\n}"
  name         = "Project.Terraform.Configuration"
  type         = "String"
}
'''


class TestSanitizeNameAttributesAnchor(unittest.TestCase):
    def test_name_inside_a_string_value_is_untouched(self):
        result = sanitize_name_attributes(TEMPLATE_VARIABLE)
        self.assertNotIn("_n", result)
        self.assertIn(r'\"rg-$${var.cidr}\"\n  location = \"australiaeast\"\n}', result)

    def test_name_attribute_at_line_start_is_still_sanitized(self):
        config = 'resource "octopusdeploy_project" "p" {\n  name = "Blue/Green"\n}\n'
        self.assertIn('name = "Blue-Green"', sanitize_name_attributes(config))

    def test_name_in_an_inline_object_is_still_sanitized(self):
        config = 'resource "x" "y" {\n  thing = { id = null, name = "A/B" }\n}\n'
        self.assertIn('name = "A-B"', sanitize_name_attributes(config))

    def test_name_directly_after_an_opening_brace_is_still_sanitized(self):
        config = 'resource "x" "y" {\n  thing = {name = "A/B"}\n}\n'
        self.assertIn('name = "A-B"', sanitize_name_attributes(config))

    def test_heredoc_body_is_untouched(self):
        config = (
            'resource "octopusdeploy_process_step" "x" {\n'
            '  name = "Write/INI"\n'
            "  execution_properties = {\n"
            '    "Octopus.Action.Script.ScriptBody" = <<EOT\n'
            "[service]\n"
            'name = "orders/eu-west"\n'
            "EOT\n"
            '    name = "After/Heredoc"\n'
            "  }\n"
            "}\n"
        )
        result = sanitize_name_attributes(config)
        self.assertIn('name = "orders/eu-west"', result)
        self.assertIn('name = "Write-INI"', result)
        self.assertIn('name = "After-Heredoc"', result)

    def test_indented_heredoc_marker_is_untouched(self):
        config = '  body = <<-EOT\n    name = "a/b"\n    EOT\n  name = "c/d"\n'
        result = sanitize_name_attributes(config)
        self.assertIn('name = "a/b"', result)
        self.assertIn('name = "c-d"', result)

    def test_identical_text_elsewhere_is_not_replaced_globally(self):
        config = 'name = "x/y"\nbody = <<EOT\nname = "x/y"\nEOT\n'
        self.assertEqual(sanitize_name_attributes(config), 'name = "x-y"\nbody = <<EOT\nname = "x/y"\nEOT\n')

    def test_slash_becomes_dash_in_step_name_and_deployment_action(self):
        config = '  name = "Go/No-Go"\n  deployment_action = "Go/No-Go"\n  name = "DOMAIN\\\\user"\n'
        result = sanitize_name_attributes(config)
        self.assertIn('name = "Go-No-Go"', result)
        self.assertIn('deployment_action = "Go-No-Go"', result)
        self.assertIn('name = "DOMAIN__user"', result)

    def test_empty_config(self):
        self.assertEqual(sanitize_name_attributes(""), "")
        self.assertIsNone(sanitize_name_attributes(None))

    def test_variable_name_line_is_still_sanitized(self):
        result = sanitize_name_attributes(TEMPLATE_VARIABLE.replace("Project.Terraform.Configuration", "Bad/Name"))
        self.assertIn('name         = "Bad-Name"', result)


if __name__ == "__main__":
    unittest.main()
