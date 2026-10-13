import unittest

from domain.sanitizers.terraform import remove_undeclared_depends_on_references

CONFIG = """data "octopusdeploy_tag_sets" "tagset_placeholder" {
  partial_name = "Placeholder"
}
resource "octopusdeploy_environment" "environment_development" {
  name = "Development"
}
resource "octopusdeploy_process" "process_kubernetes_web_app" {
  depends_on = [DEPENDENCIES]
}
"""


def config(dependencies):
    return CONFIG.replace("DEPENDENCIES", dependencies)


class TestRemoveUndeclaredDependsOnReferences(unittest.TestCase):
    def test_undeclared_resource_is_removed(self):
        result = remove_undeclared_depends_on_references(config("octopusdeploy_tag_set.tagset_placeholder"))
        self.assertIn("depends_on = []", result)

    def test_declared_resource_is_kept(self):
        result = remove_undeclared_depends_on_references(
            config("octopusdeploy_tag_set.tagset_placeholder, octopusdeploy_environment.environment_development")
        )
        self.assertIn("depends_on = [ octopusdeploy_environment.environment_development]", result)

    def test_declared_data_source_is_kept(self):
        dependencies = "data.octopusdeploy_tag_sets.tagset_placeholder"
        self.assertEqual(config(dependencies), remove_undeclared_depends_on_references(config(dependencies)))

    def test_undeclared_data_source_is_removed(self):
        result = remove_undeclared_depends_on_references(config("data.octopusdeploy_feeds.feed_missing"))
        self.assertIn("depends_on = []", result)

    def test_resource_of_another_type_with_the_same_label_is_not_a_declaration(self):
        # The data source is labelled tagset_placeholder, but it does not declare the resource of that label
        result = remove_undeclared_depends_on_references(config("octopusdeploy_tag_sets.tagset_placeholder"))
        self.assertIn("depends_on = []", result)

    def test_non_octopus_entries_are_kept(self):
        dependencies = "module.network"
        self.assertEqual(config(dependencies), remove_undeclared_depends_on_references(config(dependencies)))

    def test_multiline_list(self):
        result = remove_undeclared_depends_on_references(
            config("\n    octopusdeploy_tag_set.tagset_placeholder,\n    octopusdeploy_environment.environment_development\n  ")
        )
        self.assertNotIn("octopusdeploy_tag_set.tagset_placeholder", result)
        self.assertIn("octopusdeploy_environment.environment_development", result)

    def test_none_and_empty(self):
        self.assertIsNone(remove_undeclared_depends_on_references(None))
        self.assertEqual("", remove_undeclared_depends_on_references(""))


if __name__ == "__main__":
    unittest.main()
