import unittest

from domain.sanitizers.terraform import add_fallback_to_bare_worker_pool_lookups

LOOKUPS = """data "octopusdeploy_worker_pools" "workerpool_hosted_ubuntu" {
  partial_name = "Hosted Ubuntu"
}
data "octopusdeploy_worker_pools" "workerpool_build_pool" {
  partial_name = "Build Pool"
}
locals {
  workerpool_hosted_ubuntu_worker_pools_matches = [for pool in data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools : pool if pool.name == "Hosted Ubuntu"]
  workerpool_build_pool_worker_pools_matches = [for pool in data.octopusdeploy_worker_pools.workerpool_build_pool.worker_pools : pool if pool.name == "Build Pool"]
}
"""


def step(reference):
    return LOOKUPS + f'resource "octopusdeploy_process_step" "s" {{\n  worker_pool_id = "${{{reference}}}"\n}}\n'


class TestAddFallbackToBareWorkerPoolLookups(unittest.TestCase):
    def test_bare_hosted_ubuntu_local_falls_back_to_default_pool(self):
        result = add_fallback_to_bare_worker_pool_lookups(step("local.workerpool_hosted_ubuntu_worker_pools_matches[0].id"))
        self.assertIn('worker_pool_id = "${try(local.workerpool_hosted_ubuntu_worker_pools_matches[0].id, "")}"', result)

    def test_bare_hosted_ubuntu_data_falls_back_to_default_pool(self):
        result = add_fallback_to_bare_worker_pool_lookups(
            step("data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id")
        )
        self.assertIn(
            'worker_pool_id = "${try(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id, "")}"',
            result,
        )

    def test_other_pool_tries_hosted_ubuntu_then_default(self):
        result = add_fallback_to_bare_worker_pool_lookups(step("local.workerpool_build_pool_worker_pools_matches[0].id"))
        self.assertIn(
            'worker_pool_id = "${try(local.workerpool_build_pool_worker_pools_matches[0].id, '
            'local.workerpool_hosted_ubuntu_worker_pools_matches[0].id, "")}"',
            result,
        )

    def test_created_pool_is_left_alone(self):
        config = (
            'resource "octopusdeploy_static_worker_pool" "workerpool_build_pool" {\n  count = 1\n}\n'
            + step("local.workerpool_build_pool_worker_pools_matches[0].id")
        )
        self.assertEqual(config, add_fallback_to_bare_worker_pool_lookups(config))

    def test_existing_ternary_is_left_alone(self):
        config = step(
            "length(local.workerpool_hosted_ubuntu_worker_pools_matches) != 0 ? "
            "local.workerpool_hosted_ubuntu_worker_pools_matches[0].id : null"
        )
        self.assertEqual(config, add_fallback_to_bare_worker_pool_lookups(config))

    def test_worker_pool_variable_value_is_fixed(self):
        config = LOOKUPS + 'resource "octopusdeploy_variable" "v" {\n  value = "${local.workerpool_hosted_ubuntu_worker_pools_matches[0].id}"\n}\n'
        self.assertIn('value = "${try(local.workerpool_hosted_ubuntu_worker_pools_matches[0].id, "")}"',
                      add_fallback_to_bare_worker_pool_lookups(config))

    def test_target_default_worker_pool_is_fixed(self):
        # Observed: a cloud region target's default worker pool used a bare lookup of a pool the space lacked
        config = (
            LOOKUPS
            + 'resource "octopusdeploy_cloud_region_deployment_target" "target_hr_cloud" {\n'
            + '  default_worker_pool_id            = "${local.workerpool_default_worker_pool_worker_pools_matches[0].id}"\n'
            + "}\n"
        )
        result = add_fallback_to_bare_worker_pool_lookups(config)
        self.assertIn('default_worker_pool_id            = "${try(', result)
        self.assertIn('workerpool_default_worker_pool', result)
        self.assertIn(', "")}"', result)

    def test_none_and_empty(self):
        self.assertIsNone(add_fallback_to_bare_worker_pool_lookups(None))
        self.assertEqual("", add_fallback_to_bare_worker_pool_lookups(""))


if __name__ == "__main__":
    unittest.main()
