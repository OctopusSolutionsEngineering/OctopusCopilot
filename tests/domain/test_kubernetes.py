import unittest
from domain.sanitizers.terraform import (
    sanitize_kuberenetes_yaml_step_config,
    sanitize_account_type,
    sanitize_name_attributes,
    fix_single_line_lifecycle,
    fix_single_line_retention_policy,
    fix_single_line_tentacle_retention_policy,
    fix_bad_logic_characters,
    fix_lifecycle,
    fix_properties_block,
    fix_execution_properties_block,
    fix_empty_properties_block,
    fix_empty_execution_properties_block,
    fix_empty_strings,
    replace_certificate_data,
    replace_passwords,
    sanitize_slugs,
    sanitize_primary_package,
    replace_resource_names_with_digit,
    fix_double_comma,
    fix_variable_type,
    add_space_id_variable,
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

    def test_commas(self):
        # Test with different values
        input_config = (
            'release_retention_policy { quantity_to_keep = 10, unit = "Items" }'
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
        input_config = """resource "octopusdeploy_project" "test" {
               properties {
               }
            }"""

        expected = """resource "octopusdeploy_project" "test" {
               
            }"""  # noqa: W293

        result = fix_properties_block(input_config)
        self.assertEqual(result, expected)

    def test_fix_double_comma(self):
        input_config = 'parameters      = [{ default_sensitive_value = null,, display_settings = { "Octopus.ControlType" = "MultiLineText" }, help_text = "The array to sort", id = "a1b2c3d4-e5f6-7890-abcd-ef1234567890", label = "Array", name = "Array" }]'

        expected = 'parameters      = [{ default_sensitive_value = null, display_settings = { "Octopus.ControlType" = "MultiLineText" }, help_text = "The array to sort", id = "a1b2c3d4-e5f6-7890-abcd-ef1234567890", label = "Array", name = "Array" }]'

        result = fix_double_comma(input_config)
        self.assertEqual(result, expected)

    def test_fix_variable_type(self):
        input_config = 'type =  "string"'

        expected = "type = string"

        result = fix_variable_type(input_config)
        self.assertEqual(result, expected)

    def test_add_space_id_variable(self):
        input_config = "hi there"

        expected = 'variable "octopus_space_id" {\n  type = string\n}\n\nhi there'

        result = add_space_id_variable(input_config)
        self.assertEqual(result, expected)

    def test_add_space_id_variable_2(self):
        input_config = 'hi there\n  variable "octopus_space_id" {\n  type = string\n}'

        result = add_space_id_variable(input_config)
        self.assertEqual(result, input_config)

    def test_fix_execution_properties_block(self):
        input_config = """resource "octopusdeploy_project" "test" {
               execution_properties {
               }
            }"""

        expected = """resource "octopusdeploy_project" "test" {
               
            }"""  # noqa: W293

        result = fix_execution_properties_block(input_config)
        self.assertEqual(result, expected)

    def test_fix_empty_properties_block(self):
        input_config = """resource "octopusdeploy_project" "test" {
               properties = {
               }
            }"""

        expected = """resource "octopusdeploy_project" "test" {
               
            }"""  # noqa: W293

        result = fix_empty_properties_block(input_config)
        self.assertEqual(result, expected)

    def test_fix_empty_properties_block(self):
        input_config = """resource "octopusdeploy_project" "test" {
               execution_properties = {
               }
            }"""

        expected = """resource "octopusdeploy_project" "test" {
               
            }"""  # noqa: W293

        result = fix_empty_execution_properties_block(input_config)
        self.assertEqual(result, expected)

    def test_fix_default_value(self):
        input = """resource "octopusdeploy_project" test" {
               default_value = ""
            }"""

        expected = """resource "octopusdeploy_project" test" {
            }"""

        result = fix_empty_strings(input)

        self.assertEqual(result, expected)

    def test_fix_default_value_2(self):
        input = """resource "octopusdeploy_project" test" {
                default_value = ""
                whatever = ""
            }"""

        expected = """resource "octopusdeploy_project" test" {
                whatever = ""
            }"""

        result = fix_empty_strings(input)

        self.assertEqual(result, expected)

    def test_fix_default_value_3(self):
        input = """resource "octopusdeploy_project" test" {
               default_value = "blah"
            }"""

        result = fix_empty_strings(input)

        self.assertEqual(result, input)

    def test_cert_data(self):
        input = """resource "octopusdeploy_certificate" "certificate_development_certificate" {
          count                             = "${length(data.octopusdeploy_certificates.certificate_development_certificate.certificates) != 0 ? 0 : 1}"
          name                              = "Development Certificate"
          password                          = "A leaked password"
          certificate_data                  = "SomeValue"
          archived                          = ""
          environments                      = []
          notes                             = ""
          tenant_tags                       = []
          tenanted_deployment_participation = "Untenanted"
          tenants                           = []
          depends_on                        = []
          lifecycle {
            ignore_changes  = [password, certificate_data]
            prevent_destroy = true
          }
        }"""

        result = replace_certificate_data(input)

        self.assertNotIn("SomeValue", result)

    def test_password(self):
        input = """resource "octopusdeploy_certificate" "certificate_development_certificate" {
          count                             = "${length(data.octopusdeploy_certificates.certificate_development_certificate.certificates) != 0 ? 0 : 1}"
          name                              = "Development Certificate"
          password                          = "A leaked password"
          certificate_data                  = "SomeValue"
          archived                          = ""
          environments                      = []
          notes                             = ""
          tenant_tags                       = []
          tenanted_deployment_participation = "Untenanted"
          tenants                           = []
          depends_on                        = []
          lifecycle {
            ignore_changes  = [password, certificate_data]
            prevent_destroy = true
          }
        }"""

        result = replace_passwords(input)

        self.assertNotIn("A leaked password", result)

    def test_sanitize_slugs(self):
        cases = [
            (
                'resource "octopusdeploy_project" "example" {\n  slug = "my***bad***slug"\n}\n',
                'resource "octopusdeploy_project" "example" {\n  \n}\n',
            ),
            (
                '  resource "octopusdeploy_project" "example" {\n  slug = "my***bad***slug"\n} ',
                '  resource "octopusdeploy_project" "example" {\n  \n} ',
            ),
            (
                'resource "octopusdeploy_project" "example" {\n  slug = "my-good-slug"\n}\n',
                'resource "octopusdeploy_project" "example" {\n  slug = "my-good-slug"\n}\n',
            ),
            (
                'resource "octopusdeploy_project" "a" {\n  slug = "ok-slug"\n}\n'
                'resource "octopusdeploy_project" "b" {\n  slug = "bad*slug"\n}\n',
                'resource "octopusdeploy_project" "a" {\n  slug = "ok-slug"\n}\n'
                'resource "octopusdeploy_project" "b" {\n  \n}\n',
            ),
        ]

        for input_config, expected in cases:
            with self.subTest(input=input_config):
                self.assertEqual(sanitize_slugs(input_config), expected)

    def test_primary_package_sanitization(self):
        """
        Tests that a malformed primary_package block is corrected.
        """
        config = """
resource "octopusdeploy_deployment_process" "deployment_process_my_app" {
  project_id = octopusdeploy_project.my_app.id

  step {
    name = "Deploy a Package"
    package_requirement = "LetOctopusDecide"
    properties = {
      "Octopus.Action.TargetRoles" = "my-role"
    }
    condition = "Success"
    start_trigger = "StartWithPrevious"

    action {
      action_type = "Octopus.DeployPackage"
      name = "Deploy a Package"
      notes = "Deploys the application package."
      run_on_server = false
      worker_pool_id = "data.octopusdeploy_worker_pools.workerpool_aws_ubuntu_2204.worker_pools[0].id"
      ", id = null, package_id = "${var.project_azure_static_content_2891_step_deploy_azure_web_app_package_staticcontent_packageid}", properties = { SelectionMode = "immediate" } }
    }
  }
}
"""
        expected = """
resource "octopusdeploy_deployment_process" "deployment_process_my_app" {
  project_id = octopusdeploy_project.my_app.id

  step {
    name = "Deploy a Package"
    package_requirement = "LetOctopusDecide"
    properties = {
      "Octopus.Action.TargetRoles" = "my-role"
    }
    condition = "Success"
    start_trigger = "StartWithPrevious"

    action {
      action_type = "Octopus.DeployPackage"
      name = "Deploy a Package"
      notes = "Deploys the application package."
      run_on_server = false
      worker_pool_id = "data.octopusdeploy_worker_pools.workerpool_aws_ubuntu_2204.worker_pools[0].id"
      primary_package = { acquisition_location = "Server", feed_id = "data.octopusdeploy_feeds.feed_octopus_server__built_in_.feeds[0].id", id = null, package_id = "${var.project_azure_static_content_2891_step_deploy_azure_web_app_package_staticcontent_packageid}", properties = { SelectionMode = "immediate" } }
    }
  }
}
"""
        sanitized_config = sanitize_primary_package(config)
        self.assertEqual(expected.strip(), sanitized_config.strip())

    def test_no_match(self):
        """
        Tests that the config is unchanged if the malformed block is not present.
        """
        config = """
resource "octopusdeploy_project" "test_project" {
  name = "Test Project"
  lifecycle_id = "Lifecycles-1"
  project_group_id = "ProjectGroups-1"
}
"""
        sanitized_config = sanitize_primary_package(config)
        self.assertEqual(config.strip(), sanitized_config.strip())

    def test_valid_primary_package_sanitization(self):
        """
        Tests that a valid primary_package block is ignored.
        """
        config = """
resource "octopusdeploy_deployment_process" "deployment_process_my_app" {
  project_id = octopusdeploy_project.my_app.id

  step {
    name = "Deploy a Package"
    package_requirement = "LetOctopusDecide"
    properties = {
      "Octopus.Action.TargetRoles" = "my-role"
    }
    condition = "Success"
    start_trigger = "StartWithPrevious"

    action {
      action_type = "Octopus.DeployPackage"
      name = "Deploy a Package"
      notes = "Deploys the application package."
      run_on_server = false
      worker_pool_id = "data.octopusdeploy_worker_pools.workerpool_aws_ubuntu_2204.worker_pools[0].id"
      primary_package = { acquisition_location = "Server", feed_id = "data.octopusdeploy_feeds.feed_octopus_server__built_in_.feeds[0].id", id = null, package_id = "${var.project_azure_static_content_2891_step_deploy_azure_web_app_package_staticcontent_packageid}", properties = { SelectionMode = "immediate" } }
    }
  }
}
"""
        expected = """
resource "octopusdeploy_deployment_process" "deployment_process_my_app" {
  project_id = octopusdeploy_project.my_app.id

  step {
    name = "Deploy a Package"
    package_requirement = "LetOctopusDecide"
    properties = {
      "Octopus.Action.TargetRoles" = "my-role"
    }
    condition = "Success"
    start_trigger = "StartWithPrevious"

    action {
      action_type = "Octopus.DeployPackage"
      name = "Deploy a Package"
      notes = "Deploys the application package."
      run_on_server = false
      worker_pool_id = "data.octopusdeploy_worker_pools.workerpool_aws_ubuntu_2204.worker_pools[0].id"
      primary_package = { acquisition_location = "Server", feed_id = "data.octopusdeploy_feeds.feed_octopus_server__built_in_.feeds[0].id", id = null, package_id = "${var.project_azure_static_content_2891_step_deploy_azure_web_app_package_staticcontent_packageid}", properties = { SelectionMode = "immediate" } }
    }
  }
}
"""
        sanitized_config = sanitize_primary_package(config)
        self.assertEqual(expected.strip(), sanitized_config.strip())

    def test_resource_names(self):
        input_config = """
        resource "octopusdeploy_kubernetes_cluster_deployment_target" "1test" {
          name = "A value"
        }
        resource "octopusdeploy_project" "project" {
          name = "A new value"
          something = octopusdeploy_kubernetes_cluster_deployment_target.1test.id
        }
        """

        expected_output = """
        resource "octopusdeploy_kubernetes_cluster_deployment_target" "_1test" {
          name = "A value"
        }
        resource "octopusdeploy_project" "project" {
          name = "A new value"
          something = octopusdeploy_kubernetes_cluster_deployment_target._1test.id
        }
        """

        result = replace_resource_names_with_digit(input_config)
        self.assertEqual(result, expected_output)

    def test_valid_resource_names(self):
        input_config = """
        resource "octopusdeploy_kubernetes_cluster_deployment_target" "test" {
          name = "A value"
        }
        resource "octopusdeploy_project" "project" {
          name = "A new value"
          something = octopusdeploy_kubernetes_cluster_deployment_target.test.id
        }
        # 1blah
        2blah
        """

        result = replace_resource_names_with_digit(input_config)
        self.assertEqual(result, input_config)


if __name__ == "__main__":
    unittest.main()
