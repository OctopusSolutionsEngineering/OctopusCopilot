import unittest

from domain.sanitizers.terraform import add_trailing_slash_to_listening_worker_uri

WORKER = """resource "octopusdeploy_listening_tentacle_worker" "worker_worker_01" {
  name              = "worker-01"
  uri               = "https://worker-01.example.local:10933"
  thumbprint        = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
  worker_pool_ids   = []
}
"""


class TestAddTrailingSlashToListeningWorkerUri(unittest.TestCase):
    def test_slash_is_added(self):
        result = add_trailing_slash_to_listening_worker_uri(WORKER)
        self.assertIn('uri               = "https://worker-01.example.local:10933/"', result)

    def test_existing_slash_is_unchanged(self):
        config = WORKER.replace(':10933"', ':10933/"')
        self.assertEqual(add_trailing_slash_to_listening_worker_uri(config), config)

    def test_uri_with_path_is_unchanged(self):
        config = WORKER.replace(':10933"', ':10933/tentacle"')
        self.assertEqual(add_trailing_slash_to_listening_worker_uri(config), config)

    def test_other_resources_are_untouched(self):
        config = WORKER.replace("octopusdeploy_listening_tentacle_worker", "octopusdeploy_feed")
        config = 'resource "octopusdeploy_listening_tentacle_deployment_target" "t" {\n  uri = "https://web-01:10933"\n}\n' + config
        self.assertEqual(add_trailing_slash_to_listening_worker_uri(config), config)

    def test_several_workers(self):
        config = WORKER + WORKER.replace("worker_01", "worker_02").replace("worker-01", "worker-02")
        result = add_trailing_slash_to_listening_worker_uri(config)
        self.assertEqual(result.count(':10933/"'), 2)

    def test_empty_config(self):
        self.assertEqual(add_trailing_slash_to_listening_worker_uri(""), "")
        self.assertIsNone(add_trailing_slash_to_listening_worker_uri(None))


if __name__ == "__main__":
    unittest.main()
