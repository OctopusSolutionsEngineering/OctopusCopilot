import unittest

from domain.sanitizers.terraform import remove_runbooks_data_source

PROJECT_COUNT = '"${length(local.project_aws_lambda_projects_matches) != 0 ? 0 : 1}"'
PROJECT_ID = (
    '"${length(local.project_aws_lambda_projects_matches) != 0 ? local.project_aws_lambda_projects_matches[0].id : '
    'octopusdeploy_project.project_aws_lambda[0].id}"'
)
CONFIG = f"""resource "octopusdeploy_project" "project_aws_lambda" {{
  count = {PROJECT_COUNT}
  name  = "Lambda with Runbook"
}}
data "octopusdeploy_runbooks" "runbook_switch_load_balancer" {{
  project_id   = {PROJECT_ID}
  partial_name = "Switch Load Balancer"
  skip         = 0
  take         = 1
}}
resource "octopusdeploy_runbook" "runbook_switch_load_balancer" {{
  count                       = "${{length(data.octopusdeploy_runbooks.runbook_switch_load_balancer.runbooks) != 0 ? 0 : 1}}"
  name                        = "Switch Load Balancer"
  project_id                  = {PROJECT_ID}
}}
resource "octopusdeploy_process" "process_switch_load_balancer" {{
  runbook_id = "${{length(data.octopusdeploy_runbooks.runbook_switch_load_balancer.runbooks) != 0 ? data.octopusdeploy_runbooks.runbook_switch_load_balancer.runbooks[0].id : octopusdeploy_runbook.runbook_switch_load_balancer[0].id}}"
}}
resource "octopusdeploy_process" "process_aws_lambda_switch_load_balancer" {{
  count      = "${{length(data.octopusdeploy_runbooks.runbook_switch_load_balancer.runbooks) != 0 ? 0 : 1}}"
  runbook_id = "${{length(data.octopusdeploy_runbooks.runbook_switch_load_balancer.runbooks) != 0 ? null : octopusdeploy_runbook.runbook_switch_load_balancer[0].id}}"
}}
"""


class TestRemoveRunbooksDataSource(unittest.TestCase):
    def test_data_source_is_removed(self):
        result = remove_runbooks_data_source(CONFIG)
        self.assertNotIn("data.octopusdeploy_runbooks", result)
        self.assertNotIn('data "octopusdeploy_runbooks"', result)

    def test_runbook_gets_project_count(self):
        result = remove_runbooks_data_source(CONFIG)
        runbook = result[result.index('resource "octopusdeploy_runbook"') :]
        self.assertIn(f"count                       = {PROJECT_COUNT}", runbook)

    def test_lookup_ternary_becomes_resource_reference(self):
        result = remove_runbooks_data_source(CONFIG)
        self.assertIn('runbook_id = "${octopusdeploy_runbook.runbook_switch_load_balancer[0].id}"', result)

    def test_process_count_follows_the_runbook(self):
        result = remove_runbooks_data_source(CONFIG)
        self.assertIn(
            'count      = "${length(octopusdeploy_runbook.runbook_switch_load_balancer) == 0 ? 0 : 1}"', result
        )

    def test_null_ternary_follows_the_runbook(self):
        result = remove_runbooks_data_source(CONFIG)
        self.assertIn(
            'runbook_id = "${length(octopusdeploy_runbook.runbook_switch_load_balancer) == 0 ? null : '
            'octopusdeploy_runbook.runbook_switch_load_balancer[0].id}"',
            result,
        )

    def test_lookup_without_a_runbook_resource_is_false(self):
        config = 'x = "${length(data.octopusdeploy_runbooks.missing.runbooks) != 0 ? 0 : 1}"\n'
        config = 'data "octopusdeploy_runbooks" "missing" {\n}\n' + config
        self.assertIn('x = "${false ? 0 : 1}"', remove_runbooks_data_source(config))

    def test_runbook_without_created_project_gets_count_of_one(self):
        config = CONFIG.replace('resource "octopusdeploy_project" "project_aws_lambda"', 'resource "octopusdeploy_x" "y"')
        result = remove_runbooks_data_source(config)
        runbook = result[result.index('resource "octopusdeploy_runbook"') :]
        self.assertIn('count                       = "1"', runbook)

    def test_singular_data_source_is_removed(self):
        config = CONFIG.replace("octopusdeploy_runbooks", "octopusdeploy_runbook")
        result = remove_runbooks_data_source(config)
        self.assertNotIn('data "octopusdeploy_runbook"', result)
        self.assertNotIn("data.octopusdeploy_runbook", result)

    def test_config_without_data_source_is_unchanged(self):
        config = CONFIG[: CONFIG.index("data ")]
        self.assertEqual(config, remove_runbooks_data_source(config))

    def test_none_and_empty(self):
        self.assertIsNone(remove_runbooks_data_source(None))
        self.assertEqual("", remove_runbooks_data_source(""))


if __name__ == "__main__":
    unittest.main()
