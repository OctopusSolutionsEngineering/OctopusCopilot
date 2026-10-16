import unittest

from domain.sanitizers.terraform import remove_endpoint_from_self_endpoint_targets

OFFLINE = """resource "octopusdeploy_offline_package_drop_deployment_target" "target_hr_air_gapped" {
  name                   = "HR Air-Gapped"
  applications_directory = "D:\\\\Drops\\\\HR"
  working_directory      = "D:\\\\Drops\\\\HR"
  destination {
    destination_type = "FileSystem"
    drop_folder_path = "D:\\\\Drops\\\\HR"
  }
  endpoint {
    communication_style = "OfflineDrop"
  }
  lifecycle {
    prevent_destroy = true
  }
}
"""

CLOUD = """resource "octopusdeploy_cloud_region_deployment_target" "target_hr_cloud" {
  name = "HR Cloud"
  endpoint {
    communication_style = "CloudRegion"
  }
}
"""

K8S = """resource "octopusdeploy_kubernetes_cluster_deployment_target" "target_k8s" {
  name = "Mock K8s"
  endpoint {
    communication_style = "Kubernetes"
  }
}
"""


class TestRemoveEndpointFromSelfEndpointTargets(unittest.TestCase):
    def test_observed_offline_drop_endpoint_is_removed(self):
        result = remove_endpoint_from_self_endpoint_targets(OFFLINE)
        self.assertNotIn("endpoint", result)
        self.assertIn('drop_folder_path = "D:\\\\Drops\\\\HR"', result)
        self.assertIn("lifecycle {\n    prevent_destroy = true\n  }\n}", result)

    def test_observed_cloud_region_endpoint_is_removed(self):
        result = remove_endpoint_from_self_endpoint_targets(CLOUD)
        self.assertEqual('resource "octopusdeploy_cloud_region_deployment_target" "target_hr_cloud" {\n  name = "HR Cloud"\n}\n', result)

    def test_other_targets_keep_their_endpoint(self):
        self.assertEqual(K8S, remove_endpoint_from_self_endpoint_targets(K8S))

    def test_mixed_targets(self):
        result = remove_endpoint_from_self_endpoint_targets(CLOUD + K8S + OFFLINE)
        self.assertEqual(1, result.count("endpoint {"))
        self.assertIn('communication_style = "Kubernetes"', result)

    def test_empty(self):
        self.assertEqual("", remove_endpoint_from_self_endpoint_targets(""))
        self.assertIsNone(remove_endpoint_from_self_endpoint_targets(None))


if __name__ == "__main__":
    unittest.main()
