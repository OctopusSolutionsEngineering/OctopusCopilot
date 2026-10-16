import asyncio
import unittest
from unittest.mock import AsyncMock, patch

from domain.exceptions.spacebuilder import SpaceBuilderRequestFailed
from domain.tools.githubactions.projects import create_template_project

MODULE = "domain.tools.githubactions.projects.create_template_project"

# Observed second pass response: only a variable and a locals block, which applied with 0 resources added
NO_RESOURCES = """variable "octopus_space_id" {
  type = string
}
locals {
  feature_script_notes = "The requested literal $${env:COMPUTERNAME} is escaped"
}
"""

WITH_RESOURCES = """variable "octopus_space_id" {
  type = string
}
resource "octopusdeploy_project_group" "project_group_insurance" {
  name = "Insurance"
}
"""

FULL_PROJECT = WITH_RESOURCES + "".join(
    f'resource "octopusdeploy_environment" "environment_{i}" {{\n  name = "Env {i}"\n}}\n' for i in range(5)
)

# Observed second pass response: only the step whose reference was broken, with process_id = "${null}"
LONE_STEP = """variable "octopus_space_id" {
  type = string
}
resource "octopusdeploy_process_step" "process_step_warm_cache" {
  name       = "Warm Cache"
  type       = "Octopus.Script"
  process_id = "${null}"
}
"""


def run_retry(previous_configuration=WITH_RESOURCES):
    return asyncio.run(
        create_template_project.retry_terraform_plan(
            "api_key",
            None,
            "https://example.octopus.app",
            "Spaces-1",
            "My Project",
            "Create a project",
            previous_configuration,
            None,
            None,
            [],
            [],
            lambda *args, **kwargs: None,
            "Error: original plan failure",
            None,
        )
    )


class TestRetryTerraformPlan(unittest.TestCase):
    def test_second_pass_without_resources_raises_original_error(self):
        plan = AsyncMock()
        with patch(f"{MODULE}.llm_message_query", return_value=NO_RESOURCES), patch(
            f"{MODULE}.create_terraform_plan", plan
        ):
            with self.assertRaises(SpaceBuilderRequestFailed) as context:
                run_retry()

        self.assertEqual("Error: original plan failure", str(context.exception))
        plan.assert_not_called()

    def test_second_pass_with_only_changed_blocks_raises_original_error(self):
        plan = AsyncMock()
        with patch(f"{MODULE}.llm_message_query", return_value=LONE_STEP), patch(
            f"{MODULE}.create_terraform_plan", plan
        ):
            with self.assertRaises(SpaceBuilderRequestFailed) as context:
                run_retry(FULL_PROJECT)

        self.assertEqual("Error: original plan failure", str(context.exception))
        plan.assert_not_called()

    def test_second_pass_keeping_most_resources_is_planned(self):
        plan = AsyncMock(return_value={"data": {"id": "plan-2"}})
        # Five of the six resources survive the fix
        fixed = FULL_PROJECT.replace(
            'resource "octopusdeploy_environment" "environment_4" {\n  name = "Env 4"\n}\n', ""
        )
        with patch(f"{MODULE}.llm_message_query", return_value=fixed), patch(
            f"{MODULE}.create_terraform_plan", plan
        ):
            configuration, response = run_retry(FULL_PROJECT)

        self.assertEqual("plan-2", response["data"]["id"])
        plan.assert_called_once()

    def test_second_pass_with_resources_is_planned(self):
        plan = AsyncMock(return_value={"data": {"id": "plan-1"}})
        with patch(f"{MODULE}.llm_message_query", return_value=WITH_RESOURCES), patch(
            f"{MODULE}.create_terraform_plan", plan
        ):
            configuration, response = run_retry()

        self.assertIn('resource "octopusdeploy_project_group"', configuration)
        self.assertEqual("plan-1", response["data"]["id"])
        plan.assert_called_once()


if __name__ == "__main__":
    unittest.main()
