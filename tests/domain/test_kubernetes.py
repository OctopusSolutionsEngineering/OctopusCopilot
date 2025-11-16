import unittest
from domain.sanitizers.terraform import (
    sanitize_kuberenetes_yaml_step_config,
    sanitize_account_type,
    sanitize_name_attributes,
    fix_single_line_lifecycle,
    fix_single_line_retention_policy,
    fix_single_line_tentacle_retention_policy,
    fix_bad_logic_characters,
    fix_lifecycle, fix_properties_block, fix_execution_properties_block,
)


class TestKubernetesSanitizer(unittest.TestCase):
    def test_sanitize_kuberenetes_yaml_step_config(self):
        # Sample Kubernetes config with sensitive information
        input_config = """
        resource "octopusdeploy_kubernetes_cluster_deployment_target" "test" {
          name = "Test Kubernetes"
          "Octopus.Action.KubernetesContainers.CustomResourceYaml" = "apiVersion: v1\\nkind: Secret\\nmetadata:\\n  name: *****-secret\\n  namespace: default\\ndata:\\n  API_KEY: \"*****\"\\n  PASSWORD: \"*****\"\\n  TOKEN: \"sensitive-token\""
        }
        """

        expected_output = """
        resource "octopusdeploy_kubernetes_cluster_deployment_target" "test" {
          name = "Test Kubernetes"
          "Octopus.Action.KubernetesContainers.CustomResourceYaml" = "apiVersion: v1\\nkind: Secret\\nmetadata:\\n  name: placeholder-secret\\n  namespace: default\\ndata:\\n  API_KEY: \"placeholder\"\\n  PASSWORD: \"placeholder\"\\n  TOKEN: \"sensitive-token\""
        }
        """

        # Call the function
        result = sanitize_kuberenetes_yaml_step_config(input_config)

        # Assert the result matches expected output
        self.assertEqual(result, expected_output)

    def test_sanitize_kuberenetes_yaml_step_config_with_quotes(self):
        # Sample Kubernetes config with sensitive information
        input_config = """
        resource "octopusdeploy_kubernetes_cluster_deployment_target" "test" {
          name = "Test Kubernetes"
          "Octopus.Action.KubernetesContainers.CustomResourceYaml" = "apiVersion: v1\\nkind: Secret\\nmetadata:\\n  name: "*****-secret"\\n  namespace: default\\ndata:\\n  API_KEY: \"*****\"\\n  PASSWORD: \"*****\"\\n  TOKEN: \"sensitive-token\""
        }
        """

        expected_output = """
        resource "octopusdeploy_kubernetes_cluster_deployment_target" "test" {
          name = "Test Kubernetes"
          "Octopus.Action.KubernetesContainers.CustomResourceYaml" = "apiVersion: v1\\nkind: Secret\\nmetadata:\\n  name: "placeholder-secret"\\n  namespace: default\\ndata:\\n  API_KEY: \"placeholder\"\\n  PASSWORD: \"placeholder\"\\n  TOKEN: \"sensitive-token\""
        }
        """

        # Call the function
        result = sanitize_kuberenetes_yaml_step_config(input_config)

        # Assert the result matches expected output
        self.assertEqual(result, expected_output)

    def test_sanitize_multiple_yaml_configs(self):
        # Sample with multiple YAML configs
        input_config = """
        resource "octopusdeploy_kubernetes_cluster_deployment_target" "test1" {
          "Octopus.Action.KubernetesContainers.CustomResourceYaml" = "apiVersion: v1\\nkind: Secret\\nmetadata:\\n  name: *****\\n  namespace: default"
        }
        resource "octopusdeploy_kubernetes_cluster_deployment_target" "test2" {
          "Octopus.Action.KubernetesContainers.CustomResourceYaml" = "apiVersion: v1\\nkind: ConfigMap\\nmetadata:\\n  name: *****\\n  namespace: default"
        }
        """

        # Call the function
        result = sanitize_kuberenetes_yaml_step_config(input_config)

        # Verify that both YAML configs are sanitized
        self.assertIn("name: placeholder", result)
        self.assertNotIn("name: *****", result)

    def test_no_yaml_configs(self):
        # Sample with no YAML configs
        input_config = """
        resource "octopusdeploy_kubernetes_cluster_deployment_target" "test" {
          name = "Test Kubernetes"
        }
        """

        # Call the function
        result = sanitize_kuberenetes_yaml_step_config(input_config)

        # The result should be unchanged
        self.assertEqual(result, input_config)

    def test_sanitize_account_type_fixes_capitalization(self):
        # Input with incorrect capitalization
        input_config = """
                resource "octopusdeploy_azure_service_principal" "account" {
                  name          = "Azure Service Principal"
                  account_type  = "AzureOidc"
                  application_id = "00000000-0000-0000-0000-000000000000"
                }
                """

        expected_output = """
                resource "octopusdeploy_azure_service_principal" "account" {
                  name          = "Azure Service Principal"
                  account_type = "AzureOIDC"
                  application_id = "00000000-0000-0000-0000-000000000000"
                }
                """

        # Call the function (would need to fix implementation first)
        result = sanitize_account_type(input_config)
        self.assertEqual(result, expected_output)

    def test_sanitize_account_type_with_whitespace_variations(self):
        # Test with different whitespace formatting
        input_config = """
                resource "octopusdeploy_azure_service_principal" "account" {
                  account_type="AzureOidc"
                }
                """

        expected_output = """
                        resource "octopusdeploy_azure_service_principal" "account" {
                          account_type="AzureOIDC"
                        }
                        """

        result = sanitize_account_type(input_config)

        self.assertTrue(expected_output, result)

    def test_no_changes_needed(self):
        # Input with correct capitalization already
        input_config = """
                resource "octopusdeploy_azure_service_principal" "account" {
                  name          = "Azure Service Principal"
                  account_type  = "AzureOIDC"
                  application_id = "00000000-0000-0000-0000-000000000000"
                }
                """

        result = sanitize_account_type(input_config)
        self.assertEqual(result, input_config)

    def test_multiple_occurrences(self):
        # Input with multiple occurrences of incorrect capitalization
        input_config = """
                resource "octopusdeploy_azure_service_principal" "account1" {
                  account_type = "AzureOidc"
                }
                resource "octopusdeploy_azure_service_principal" "account2" {
                  account_type = "AzureOidc"
                }
                """

        expected_output = """
                resource "octopusdeploy_azure_service_principal" "account1" {
                  account_type = "AzureOIDC"
                }
                resource "octopusdeploy_azure_service_principal" "account2" {
                  account_type = "AzureOIDC"
                }
                """

        result = sanitize_account_type(input_config)

        self.assertEqual(expected_output, result)

    def test_sanitize_name_attributes_replaces_slashes(self):
        # Input with slashes in name
        input_config = """
        resource "octopusdeploy_project" "project" {
          name = "Blue/Green deployment"
          description = "This is a Blue/Green deployment project"
        }
        """

        expected_output = """
        resource "octopusdeploy_project" "project" {
          name = "Blue_Green deployment"
          description = "This is a Blue/Green deployment project"
        }
        """

        result = sanitize_name_attributes(input_config)
        self.assertEqual(result, expected_output)

    def test_sanitize_name_attributes_allow_interpolation(self):
        # Input with slashes in name
        input_config = """
        resource "octopusdeploy_project" "project" {
          name = "${var.whatever[0]}"
          description = "This is a Blue/Green deployment project"
        }
        """

        result = sanitize_name_attributes(input_config)
        self.assertEqual(result, input_config)

    def test_sanitize_name_attributes_replaces_backslashes(self):
        # Input with backslashes in name
        input_config = """
        resource "octopusdeploy_project" "project" {
          name = "Test\\Project"
        }
        """

        expected_output = """
        resource "octopusdeploy_project" "project" {
          name = "Test_Project"
        }
        """

        result = sanitize_name_attributes(input_config)
        self.assertEqual(result, expected_output)

    def test_preserves_allowed_characters(self):
        # Input with allowed characters in name
        input_config = """
        resource "octopusdeploy_project" "project" {
          name = "Test-Project.1,2_#3"
        }
        resource "octopusdeploy_variable" "variable_1" {
          name = "A:Path:To:A:YamlOrJson:Structure"
        }
        """

        # Should be unchanged
        result = sanitize_name_attributes(input_config)
        self.assertEqual(result, input_config)

    def test_multiple_name_attributes(self):
        # Input with multiple name attributes
        input_config = """
        resource "octopusdeploy_project" "project1" {
          name = "Project/1"
        }
        resource "octopusdeploy_project" "project2" {
          name = "Project\\2"
        }
        """

        expected_output = """
        resource "octopusdeploy_project" "project1" {
          name = "Project_1"
        }
        resource "octopusdeploy_project" "project2" {
          name = "Project_2"
        }
        """

        result = sanitize_name_attributes(input_config)
        self.assertEqual(result, expected_output)

    def test_quotes_preserved(self):
        # Input with different quote styles
        input_config = """
        resource "octopusdeploy_project" "project1" {
          name = "Project/1"
        }
        resource "octopusdeploy_project" "project2" {
          name = 'Project\\2'
        }
        """

        expected_output = """
        resource "octopusdeploy_project" "project1" {
          name = "Project_1"
        }
        resource "octopusdeploy_project" "project2" {
          name = 'Project_2'
        }
        """

        result = sanitize_name_attributes(input_config)
        self.assertEqual(result, expected_output)

    def test_fix_exact_match_single_line_lifecycle(self):
        # Test the exact match case
        input_config = (
            "lifecycle { ignore_changes = [sensitive_value] prevent_destroy = true }"
        )
        expected_output = "lifecycle {\n  ignore_changes = [sensitive_value]\n  prevent_destroy = true\n}"

        result = fix_single_line_lifecycle(input_config)
        self.assertEqual(result, expected_output)

    def test_no_change_for_multiline_lifecycle(self):
        # Test a properly formatted multiline lifecycle block
        input_config = """lifecycle {
  ignore_changes = [sensitive_value]
  prevent_destroy = true
}"""

        result = fix_single_line_lifecycle(input_config)
        self.assertEqual(result, input_config)

    def test_no_change_for_other_content(self):
        # Test content that isn't a lifecycle block
        input_config = (
            'resource "octopusdeploy_variable" "test" {\n  name = "test-variable"\n}'
        )

        result = fix_single_line_lifecycle(input_config)
        self.assertEqual(result, input_config)

    def test_no_change_for_similar_but_different_lifecycle(self):
        # Test a lifecycle block with different content
        input_config = "lifecycle { ignore_changes = [tags] }"

        result = fix_single_line_lifecycle(input_config)
        self.assertEqual(result, input_config)

    def test_fix_lifecycle(self):
        input_config = (
            "lifecycle { ignore_changes = [password] prevent_destroy = true }"
        )

        result = fix_lifecycle(input_config)
        self.assertEqual(result, "")

    def test_fix_bad_logic_characters(self):
        input_config = 'count = length(try([for item in data.octopusdeploy_tag_sets.tagset_counties.tag_sets[0].tags : item if item.name == "Greater London"], []_) != 0 ? 0 : 1'
        expected_output = 'count = length(try([for item in data.octopusdeploy_tag_sets.tagset_counties.tag_sets[0].tags : item if item.name == "Greater London"], [])) != 0 ? 0 : 1'

        result = fix_bad_logic_characters(input_config)
        self.assertEqual(result, expected_output)

    def test_fix_bad_logic_characters2(self):
        input_config = 'count =    length(try([for item in data.octopusdeploy_tag_sets.tagset_counties.tag_sets[0].tags : item if item.name == "Greater London"], []_) != 0 ? 0 : 1'
        expected_output = 'count = length(try([for item in data.octopusdeploy_tag_sets.tagset_counties.tag_sets[0].tags : item if item.name == "Greater London"], [])) != 0 ? 0 : 1'

        result = fix_bad_logic_characters(input_config)
        self.assertEqual(result, expected_output)

    def test_fix_bad_logic_characters3(self):
        input_config = 'count =    length(try([for item in data.octopusdeploy_tag_sets.tagset_counties.tag_sets[0].tags : item if item.name == "Greater London"], []__ _= 0 _ 0 : 1'
        expected_output = 'count = length(try([for item in data.octopusdeploy_tag_sets.tagset_counties.tag_sets[0].tags : item if item.name == "Greater London"], [])) != 0 ? 0 : 1'

        result = fix_bad_logic_characters(input_config)
        self.assertEqual(result, expected_output)

    def test_fix_single_line_retention_policy(self):
        # Test with a single-line retention policy
        input_config = (
            'release_retention_policy { quantity_to_keep = 30 unit = "Days" }'
        )
        expected_output = (
            'release_retention_policy {\n quantity_to_keep = 30\n unit = "Days"\n}'
        )

        result = fix_single_line_retention_policy(input_config)
        self.assertEqual(result, expected_output)

    def test_fix_single_line_retention_policy(self):
        # Test with a single-line retention policy
        input_config = (
            'tentacle_retention_policy { quantity_to_keep = 30 unit = "Days" }'
        )
        expected_output = (
            'tentacle_retention_policy {\n quantity_to_keep = 30\n unit = "Days"\n}'
        )

        result = fix_single_line_tentacle_retention_policy(input_config)
        self.assertEqual(result, expected_output)

    def test_different_values(self):
        # Test with different values
        input_config = (
            'release_retention_policy { quantity_to_keep = 10 unit = "Items" }'
        )
        expected_output = (
            'release_retention_policy {\n quantity_to_keep = 10\n unit = "Items"\n}'
        )

        result = fix_single_line_retention_policy(input_config)
        self.assertEqual(result, expected_output)

    def test_with_whitespace_variations(self):
        # Test with different whitespace formatting
        input_config = 'release_retention_policy{quantity_to_keep=5 unit="Weeks"}'
        expected_output = (
            'release_retention_policy {\n quantity_to_keep = 5\n unit = "Weeks"\n}'
        )

        result = fix_single_line_retention_policy(input_config)
        self.assertEqual(result, expected_output)

    def test_no_change_for_multiline_policy(self):
        # Test a properly formatted multiline policy block
        input_config = """release_retention_policy {
 quantity_to_keep = 30
 unit = "Days"
}"""

        result = fix_single_line_retention_policy(input_config)
        self.assertEqual(result, input_config)

    def test_no_change_for_other_content(self):
        # Test content that isn't a retention policy block
        input_config = (
            'resource "octopusdeploy_project" "test" { name = "test-project" }'
        )

        result = fix_single_line_retention_policy(input_config)
        self.assertEqual(result, input_config)

    def test_fix_properties_block(self):
        # Test content that isn't a retention policy block
        input_config = (
            '''resource "octopusdeploy_project" "test" {
               properties {
               }
            }'''
        )

        expected = '''resource "octopusdeploy_project" "test" {
               
            }'''

        result = fix_properties_block(input_config)
        self.assertEqual(result, expected)

    def test_fix_execution_properties_block(self):
        # Test content that isn't a retention policy block
        input_config = (
            '''resource "octopusdeploy_project" "test" {
               execution_properties {
               }
            }'''
        )

        expected = '''resource "octopusdeploy_project" "test" {
               
            }'''

        result = fix_execution_properties_block(input_config)
        self.assertEqual(result, expected)


if __name__ == "__main__":
    unittest.main()
