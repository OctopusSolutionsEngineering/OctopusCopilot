import unittest
from domain.sanitizers.kubernetes import sanitize_kuberenetes_yaml_step_config


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


if __name__ == "__main__":
    unittest.main()
