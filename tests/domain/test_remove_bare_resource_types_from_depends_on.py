import unittest

from domain.sanitizers.terraform import remove_bare_resource_types_from_depends_on

STEP = """resource "octopusdeploy_process_step" "process_step_argo_cd_rollouts_deploy_rollout" {
  name                  = "Deploy Rollout"
  type                  = "Octopus.KubernetesDeployRawYaml"
  process_id            = "${octopusdeploy_process.process_argo_cd_rollouts[0].id}"
  depends_on            = [DEPENDENCIES]
}
"""


def step(dependencies):
    return STEP.replace("DEPENDENCIES", dependencies)


class TestRemoveBareResourceTypesFromDependsOn(unittest.TestCase):
    def test_bare_resource_type_is_removed(self):
        result = remove_bare_resource_types_from_depends_on(step("octopusdeploy_process"))
        self.assertIn("depends_on            = []", result)
        self.assertIn("octopusdeploy_process.process_argo_cd_rollouts[0].id", result)

    def test_resource_addresses_are_kept(self):
        result = remove_bare_resource_types_from_depends_on(
            step("octopusdeploy_process, octopusdeploy_environment.environment_development")
        )
        self.assertIn("depends_on            = [ octopusdeploy_environment.environment_development]", result)

    def test_multiline_list(self):
        result = remove_bare_resource_types_from_depends_on(
            step("\n    octopusdeploy_process,\n    octopusdeploy_process_step.process_step_get_rollout\n  ")
        )
        self.assertNotRegex(result, r"\boctopusdeploy_process,")
        self.assertIn("octopusdeploy_process_step.process_step_get_rollout", result)

    def test_valid_configuration_is_unchanged(self):
        config = step("octopusdeploy_environment.environment_development")
        self.assertEqual(config, remove_bare_resource_types_from_depends_on(config))

    def test_empty_list_is_unchanged(self):
        config = step("")
        self.assertEqual(config, remove_bare_resource_types_from_depends_on(config))

    def test_none_and_empty(self):
        self.assertIsNone(remove_bare_resource_types_from_depends_on(None))
        self.assertEqual("", remove_bare_resource_types_from_depends_on(""))


if __name__ == "__main__":
    unittest.main()
