import os
import unittest

from domain.transformers.deployments_from_progression import get_deployment_progression
from infrastructure.octopus import get_projects, get_environments, get_project_channel, get_lifecycle, \
    get_project_progression_from_ids


def get_test_cases():
    projects = get_projects(os.environ.get("TEST_OCTOPUS_API_KEY"), os.environ.get("TEST_OCTOPUS_URL"),
                            os.environ.get("TEST_OCTOPUS_SPACE_ID"))
    environments = get_environments(os.environ.get("TEST_OCTOPUS_API_KEY"), os.environ.get("TEST_OCTOPUS_URL"),
                                    os.environ.get("TEST_OCTOPUS_SPACE_ID"))

    for project in projects:
        progression = get_project_progression_from_ids(os.environ.get("TEST_OCTOPUS_SPACE_ID"),
                                                       project["Id"],
                                                       os.environ.get("TEST_OCTOPUS_API_KEY"),
                                                       os.environ.get("TEST_OCTOPUS_URL"))

        project["Channels"] = get_project_channel(os.environ.get("TEST_OCTOPUS_API_KEY"),
                                                  os.environ.get("TEST_OCTOPUS_URL"),
                                                  os.environ.get("TEST_OCTOPUS_SPACE_ID"), project["Id"])

        for channel in project["Channels"]:
            lifecycle_id = channel["LifecycleId"] if channel["LifecycleId"] else project["LifecycleId"]
            channel["Lifecycle"] = get_lifecycle(os.environ.get("TEST_OCTOPUS_API_KEY"),
                                                 os.environ.get("TEST_OCTOPUS_URL"),
                                                 os.environ.get("TEST_OCTOPUS_SPACE_ID"), lifecycle_id)
            channel["Lifecycle"]["Environments"] = []
            for phase in channel["Lifecycle"]["Phases"]:
                for environment in phase["AutomaticDeploymentTargets"]:
                    channel["Lifecycle"]["Environments"].append(
                        [env for env in environments if env["Id"] == environment][0])
                for environment in phase["OptionalDeploymentTargets"]:
                    channel["Lifecycle"]["Environments"].append(
                        [env for env in environments if env["Id"] == environment][0])

            for environment in channel["Lifecycle"]["Environments"]:
                environment["Deployments"] = get_deployment_progression(progression, environment["Id"], channel["Id"])

    test_cases = []

    for project in projects:
        for channel in project["Channels"]:
            for environment in channel["Lifecycle"]["Environments"]:
                if environment["Deployments"]:
                    test_cases.append({
                        "project": project,
                        "channel": channel,
                        "environment": environment,
                        "deployment": environment["Deployments"][0],
                    })

    return test_cases


class DynamicDeploymentExperiments(unittest.TestCase):
    def test_get_cases(self):
        test_cases = get_test_cases()
        self.assertTrue(test_cases)
