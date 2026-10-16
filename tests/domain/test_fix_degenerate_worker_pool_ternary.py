import unittest

from domain.sanitizers.terraform import fix_degenerate_worker_pool_ternary

LOCAL = "local.workerpool_default_worker_pool_worker_pools_matches"


class TestFixDegenerateWorkerPoolTernary(unittest.TestCase):
    def test_observed_local_ternary_falls_back_to_empty(self):
        config = f'  default_worker_pool_id = "${{length({LOCAL}) != 0 ? {LOCAL}[0].id : {LOCAL}[0].id}}"\n'
        self.assertEqual(
            f'  default_worker_pool_id = "${{try({LOCAL}[0].id, "")}}"\n',
            fix_degenerate_worker_pool_ternary(config),
        )

    def test_data_lookup_ternary(self):
        lookup = "data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools"
        config = f'worker_pool_id = "${{length({lookup}) != 0 ? {lookup}[0].id : {lookup}[0].id}}"'
        self.assertEqual(f'worker_pool_id = "${{try({lookup}[0].id, "")}}"', fix_degenerate_worker_pool_ternary(config))

    def test_real_fallback_is_unchanged(self):
        other = "local.workerpool_hosted_ubuntu_worker_pools_matches"
        config = f'x = "${{length({LOCAL}) != 0 ? {LOCAL}[0].id : {other}[0].id}}"'
        self.assertEqual(config, fix_degenerate_worker_pool_ternary(config))

    def test_non_worker_pool_ternary_is_unchanged(self):
        env = "local.environment_dev_matches"
        config = f'x = "${{length({env}) != 0 ? {env}[0].id : {env}[0].id}}"'
        self.assertEqual(config, fix_degenerate_worker_pool_ternary(config))

    def test_empty(self):
        self.assertEqual("", fix_degenerate_worker_pool_ternary(""))
        self.assertIsNone(fix_degenerate_worker_pool_ternary(None))


if __name__ == "__main__":
    unittest.main()
