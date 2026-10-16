import unittest

from domain.sanitizers.terraform import escape_template_directives_in_heredocs

# Observed: an inline Terraform template stored in a project variable
OBSERVED = """resource "octopusdeploy_variable" "terraform_project_terraform_configuration_1" {
  name     = "Project.Terraform.Configuration"
  value    = <<-EOT
    locals {
      subnet_summary = "%{ for s in subnets }$${s}%{ endfor }"
    }
  EOT
}
"""


class TestEscapeTemplateDirectivesInHeredocs(unittest.TestCase):
    def test_observed_for_directive_is_escaped(self):
        result = escape_template_directives_in_heredocs(OBSERVED)
        self.assertIn('subnet_summary = "%%{ for s in subnets }$${s}%%{ endfor }"', result)
        self.assertIn("  EOT\n}", result)

    def test_already_escaped_is_unchanged(self):
        config = OBSERVED.replace("%{", "%%{")
        self.assertEqual(config, escape_template_directives_in_heredocs(config))

    def test_quoted_values_outside_heredocs_are_unchanged(self):
        config = 'resource "octopusdeploy_variable" "v" {\n  value = "%{ if x }y%{ endif }"\n}\n'
        self.assertEqual(config, escape_template_directives_in_heredocs(config))

    def test_multiple_heredocs_with_different_tags(self):
        config = (
            'a = <<EOT\n%{ if a }\nEOT\n'
            'b = 1\n'
            'c = <<-YAML\n  x: "%{y}"\n  YAML\n'
        )
        result = escape_template_directives_in_heredocs(config)
        self.assertIn("a = <<EOT\n%%{ if a }\nEOT\n", result)
        self.assertIn('c = <<-YAML\n  x: "%%{y}"\n  YAML\n', result)
        self.assertIn("b = 1\n", result)

    def test_empty(self):
        self.assertEqual("", escape_template_directives_in_heredocs(""))
        self.assertIsNone(escape_template_directives_in_heredocs(None))


if __name__ == "__main__":
    unittest.main()
