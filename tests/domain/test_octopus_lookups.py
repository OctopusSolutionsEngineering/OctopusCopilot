import unittest
from unittest.mock import patch, Mock
from domain.lookup.octopus_lookups import (
    lookup_space,
    lookup_projects,
    lookup_environments,
    lookup_tenants,
    lookup_runbooks,
)


class TestOctopusLookups(unittest.TestCase):

    @patch("domain.lookup.octopus_lookups.get_spaces_generator")
    @patch("domain.lookup.octopus_lookups.get_space_id_and_name_from_name")
    @patch("domain.lookup.octopus_lookups.get_default_argument")
    @patch("domain.lookup.octopus_lookups.sanitize_name_fuzzy")
    @patch("domain.lookup.octopus_lookups.sanitize_space")
    def test_lookup_space(
        self,
        mock_sanitize_space,
        mock_sanitize_name_fuzzy,
        mock_get_default_argument,
        mock_get_space_id_and_name_from_name,
        mock_get_spaces_generator,
    ):
        url = "https://example.com"
        api_key = "test_api_key"
        user_id = "test_user"
        original_query = "query"
        sanitized_space_name = "test_space"

        mock_sanitize_space.return_value = sanitized_space_name
        mock_sanitize_name_fuzzy.return_value = {
            "original": sanitized_space_name,
            "matched": "Test Space",
        }
        mock_get_default_argument.return_value = sanitized_space_name
        mock_get_space_id_and_name_from_name.return_value = ("Spaces-1", "Test Space")
        mock_get_spaces_generator.return_value = iter([{"Name": "Test Space"}])

        space_id, actual_space_name, warnings = lookup_space(
            url, api_key, user_id, original_query, sanitized_space_name
        )
        self.assertEqual(space_id, "Spaces-1")
        self.assertEqual(actual_space_name, "Test Space")
        self.assertEqual(warnings, [])

    @patch("domain.lookup.octopus_lookups.get_projects_generator")
    @patch("domain.lookup.octopus_lookups.get_default_argument")
    @patch("domain.lookup.octopus_lookups.sanitize_names_fuzzy")
    @patch("domain.lookup.octopus_lookups.sanitize_projects")
    def test_lookup_projects(
        self,
        mock_sanitize_projects,
        mock_sanitize_names_fuzzy,
        mock_get_default_argument,
        mock_get_projects_generator,
    ):
        url = "https://example.com"
        api_key = "test_api_key"
        user_id = "test_user"
        original_query = "query"
        space_id = "Spaces-1"
        project_name = "test_project"

        mock_sanitize_projects.return_value = project_name
        mock_sanitize_names_fuzzy.return_value = [
            {"original": project_name, "matched": "Test Project"}
        ]
        mock_get_default_argument.return_value = ["Test Project"]
        mock_get_projects_generator.return_value = iter([{"Name": "Test Project"}])

        sanitized_project_names, sanitized_projects = lookup_projects(
            url, api_key, user_id, original_query, space_id, project_name
        )
        self.assertEqual(sanitized_project_names, ["Test Project"])
        self.assertEqual(
            sanitized_projects, [{"original": project_name, "matched": "Test Project"}]
        )

    @patch("domain.lookup.octopus_lookups.get_environments_generator")
    @patch("domain.lookup.octopus_lookups.get_default_argument")
    @patch("domain.lookup.octopus_lookups.sanitize_names_fuzzy")
    @patch("domain.lookup.octopus_lookups.sanitize_environments")
    def test_lookup_environments(
        self,
        mock_sanitize_environments,
        mock_sanitize_names_fuzzy,
        mock_get_default_argument,
        mock_get_environments_generator,
    ):
        url = "https://example.com"
        api_key = "test_api_key"
        user_id = "test_user"
        original_query = "query"
        space_id = "Spaces-1"
        environment_name = "test_environment"

        mock_sanitize_environments.return_value = environment_name
        mock_sanitize_names_fuzzy.return_value = [
            {"original": environment_name, "matched": "Test Environment"}
        ]
        mock_get_default_argument.return_value = ["Test Environment"]
        mock_get_environments_generator.return_value = iter(
            [{"Name": "Test Environment"}]
        )

        sanitized_environment_names = lookup_environments(
            url, api_key, user_id, original_query, space_id, environment_name
        )
        self.assertEqual(sanitized_environment_names, ["Test Environment"])

    @patch("domain.lookup.octopus_lookups.get_tenants_generator")
    @patch("domain.lookup.octopus_lookups.get_default_argument")
    @patch("domain.lookup.octopus_lookups.sanitize_names_fuzzy")
    @patch("domain.lookup.octopus_lookups.sanitize_tenants")
    def test_lookup_tenants(
        self,
        mock_sanitize_tenants,
        mock_sanitize_names_fuzzy,
        mock_get_default_argument,
        mock_get_tenants_generator,
    ):
        url = "https://example.com"
        api_key = "test_api_key"
        user_id = "test_user"
        original_query = "query"
        space_id = "Spaces-1"
        tenant_name = "test_tenant"

        mock_sanitize_tenants.return_value = tenant_name
        mock_sanitize_names_fuzzy.return_value = [
            {"original": tenant_name, "matched": "Test Tenant"}
        ]
        mock_get_default_argument.return_value = ["Test Tenant"]
        mock_get_tenants_generator.return_value = iter([{"Name": "Test Tenant"}])

        sanitized_tenant_names = lookup_tenants(
            url, api_key, user_id, original_query, space_id, tenant_name
        )
        self.assertEqual(sanitized_tenant_names, ["Test Tenant"])

    @patch("domain.lookup.octopus_lookups.get_runbooks_generator")
    @patch("domain.lookup.octopus_lookups.get_default_argument")
    @patch("domain.lookup.octopus_lookups.sanitize_names_fuzzy")
    @patch("domain.lookup.octopus_lookups.sanitize_runbooks")
    def test_lookup_runbooks(
        self,
        mock_sanitize_runbooks,
        mock_sanitize_names_fuzzy,
        mock_get_default_argument,
        mock_get_runbooks_generator,
    ):
        url = "https://example.com"
        api_key = "test_api_key"
        user_id = "test_user"
        original_query = "query"
        space_id = "Spaces-1"
        project_id = "Projects-1"
        runbook_name = "test_runbook"

        mock_sanitize_runbooks.return_value = runbook_name
        mock_sanitize_names_fuzzy.return_value = [
            {"original": runbook_name, "matched": "Test Runbook"}
        ]
        mock_get_default_argument.return_value = ["Test Runbook"]
        mock_get_runbooks_generator.return_value = iter([{"Name": "Test Runbook"}])

        sanitized_runbook_names = lookup_runbooks(
            url, api_key, user_id, original_query, space_id, project_id, runbook_name
        )
        self.assertEqual(sanitized_runbook_names, ["Test Runbook"])


if __name__ == "__main__":
    unittest.main()
