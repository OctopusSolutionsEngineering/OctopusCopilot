import unittest

from domain.sanitizers.terraform import escape_unbalanced_template_directives


class TestEscapeUnbalancedTemplateDirectives(unittest.TestCase):
    def test_observed_lone_if_in_notes_is_escaped(self):
        config = (
            'resource "octopusdeploy_process_step" "provision_storage" {\n'
            '  notes = "The requested Bicep-style interpolation and %{if} directive have no direct ARM-template equivalent."\n'
            "}\n"
        )
        result = escape_unbalanced_template_directives(config)
        self.assertIn("interpolation and %%{if} directive", result)

    def test_lone_for_and_endfor_mismatch_is_escaped(self):
        self.assertEqual(
            'value = "%%{ for s in subnets }${s}"',
            escape_unbalanced_template_directives('value = "%{ for s in subnets }${s}"'),
        )

    def test_balanced_directives_are_unchanged(self):
        config = 'value = "%{ if var.x }a%{ else }b%{ endif }%{~ for i in var.l ~}${i}%{~ endfor ~}"'
        self.assertEqual(config, escape_unbalanced_template_directives(config))

    def test_strings_without_directives_are_unchanged(self):
        config = 'value = "100%% done %{literal} and %%{escaped}"'
        self.assertEqual(config, escape_unbalanced_template_directives(config))

    def test_only_the_unbalanced_string_is_changed(self):
        config = 'a = "%{ if x }y%{ endif }"\nb = "mentions %{if} only"\n'
        result = escape_unbalanced_template_directives(config)
        self.assertIn('a = "%{ if x }y%{ endif }"', result)
        self.assertIn('b = "mentions %%{if} only"', result)

    def test_empty(self):
        self.assertEqual("", escape_unbalanced_template_directives(""))
        self.assertIsNone(escape_unbalanced_template_directives(None))


if __name__ == "__main__":
    unittest.main()
