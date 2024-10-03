import unittest
from unittest.mock import patch
from domain.lookup.octopus_multi_lookup import lookup_space_level_resources


class TestLookupSpaceLevelResources(unittest.TestCase):
    @patch("domain.lookup.octopus_multi_lookup.lookup_space")
    @patch("domain.lookup.octopus_multi_lookup.lookup_projects")
    @patch("domain.lookup.octopus_multi_lookup.lookup_environments")
    @patch("domain.lookup.octopus_multi_lookup.lookup_tenants")
    def test_lookup_space_level_resources(
        self,
        mock_lookup_tenants,
        mock_lookup_environments,
        mock_lookup_projects,
        mock_lookup_space,
    ):
        # Mock the return values of the lookup functions
        mock_lookup_space.return_value = ("Spaces-1", "Space 1", ["warning1"])
        mock_lookup_projects.return_value = (["Project 1"], [{"Name": "Project 1"}])
        mock_lookup_environments.return_value = ["Environment 1"]
        mock_lookup_tenants.return_value = ["Tenant 1"]

        url = "http://example.com"
        api_key = "fake_api_key"
        github_user = "fake_user"
        original_query = "query"
        space = "Space 1"
        projects = ["Project 1"]
        environments = ["Environment 1"]
        tenants = ["Tenant 1"]

        result = lookup_space_level_resources(
            url,
            api_key,
            github_user,
            original_query,
            space,
            projects,
            environments,
            tenants,
        )

        self.assertEqual(result["space_id"], "Spaces-1")
        self.assertEqual(result["space_name"], "Space 1")
        self.assertEqual(result["warnings"], ["warning1"])
        self.assertEqual(result["project_names"], ["Project 1"])
        self.assertEqual(result["projects"], [{"Name": "Project 1"}])
        self.assertEqual(result["environment_names"], ["Environment 1"])
        self.assertEqual(result["tenant_names"], ["Tenant 1"])

    @patch("domain.lookup.octopus_multi_lookup.lookup_space")
    def test_lookup_space_level_resources_only_space(
        self,
        mock_lookup_space,
    ):
        # Mock the return values of the lookup functions
        mock_lookup_space.return_value = ("Spaces-1", "Space 1", ["warning1"])

        url = "http://example.com"
        api_key = "fake_api_key"
        github_user = "fake_user"
        original_query = "query"
        space = "Space 1"

        result = lookup_space_level_resources(
            url,
            api_key,
            github_user,
            original_query,
            space,
            None,
            None,
            None,
        )

        self.assertEqual(result["space_id"], "Spaces-1")
        self.assertEqual(result["space_name"], "Space 1")
        self.assertEqual(result["warnings"], ["warning1"])
        self.assertEqual(result["project_names"], [])
        self.assertEqual(result["projects"], [])
        self.assertEqual(result["environment_names"], [])
        self.assertEqual(result["tenant_names"], [])


if __name__ == "__main__":
    unittest.main()
