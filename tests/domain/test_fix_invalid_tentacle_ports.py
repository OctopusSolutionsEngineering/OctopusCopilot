import unittest

from domain.sanitizers.terraform import fix_invalid_tentacle_ports

TARGET = """resource "octopusdeploy_listening_tentacle_deployment_target" "target_chaos_01" {
  tentacle_url = "https://chaos-01.example.local:PORT"
}
"""


class TestFixInvalidTentaclePorts(unittest.TestCase):
    def test_out_of_range_port_is_replaced(self):
        result = fix_invalid_tentacle_ports(TARGET.replace("PORT", "99999"))
        self.assertIn('tentacle_url = "https://chaos-01.example.local:10933"', result)

    def test_valid_port_is_unchanged(self):
        config = TARGET.replace("PORT", "10933")
        self.assertEqual(fix_invalid_tentacle_ports(config), config)

    def test_worker_uri_with_trailing_slash(self):
        config = 'resource "octopusdeploy_listening_tentacle_worker" "w" {\n  uri = "https://w1:70000/"\n}\n'
        self.assertIn('uri = "https://w1:10933/"', fix_invalid_tentacle_ports(config))

    def test_other_resources_are_untouched(self):
        config = 'resource "octopusdeploy_maven_feed" "f" {\n  uri = "https://maven:99999"\n}\n'
        self.assertEqual(fix_invalid_tentacle_ports(config), config)

    def test_empty_config(self):
        self.assertEqual(fix_invalid_tentacle_ports(""), "")
        self.assertIsNone(fix_invalid_tentacle_ports(None))


if __name__ == "__main__":
    unittest.main()
