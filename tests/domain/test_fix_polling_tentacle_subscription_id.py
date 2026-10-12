import unittest

from domain.sanitizers.terraform import fix_polling_tentacle_uri

POLLING_TARGET = """resource "octopusdeploy_polling_tentacle_deployment_target" "target_print_srv_01" {
  name              = "print-srv-01"
  roles             = ["print-win"]
  ATTRIBUTE
  thumbprint        = "1234567890ABCDEF1234567890ABCDEF12345678"
}
"""


class TestFixPollingTentacleSubscriptionId(unittest.TestCase):
    def test_subscription_id_becomes_tentacle_url(self):
        result = fix_polling_tentacle_uri(POLLING_TARGET.replace("ATTRIBUTE", 'subscription_id   = "abcdefghij1234567890"'))
        self.assertIn('tentacle_url   = "poll://abcdefghij1234567890/"', result)
        self.assertNotIn("subscription_id", result)

    def test_subscription_id_with_poll_scheme_is_kept(self):
        result = fix_polling_tentacle_uri(POLLING_TARGET.replace("ATTRIBUTE", 'subscription_id = "poll://abcdefghij1234567890/"'))
        self.assertIn('tentacle_url = "poll://abcdefghij1234567890/"', result)

    def test_invalid_subscription_is_normalised_by_the_url_check(self):
        result = fix_polling_tentacle_uri(POLLING_TARGET.replace("ATTRIBUTE", 'subscription_id = "ABC"'))
        self.assertRegex(result, r'tentacle_url = "poll://[a-z0-9]{20}/"')

    def test_existing_tentacle_url_is_not_replaced(self):
        config = POLLING_TARGET.replace(
            "ATTRIBUTE",
            'tentacle_url = "poll://abcdefghij1234567890/"\n  subscription_id = "zzzzzzzzzzzzzzzzzzzz"',
        )
        result = fix_polling_tentacle_uri(config)
        self.assertIn('tentacle_url = "poll://abcdefghij1234567890/"', result)
        self.assertEqual(result.count("tentacle_url"), 1)

    def test_other_resources_are_untouched(self):
        config = 'resource "octopusdeploy_azure_service_principal" "a" {\n  subscription_id = "22222222-3333-4444-5555-666666666666"\n}\n'
        config += POLLING_TARGET.replace("ATTRIBUTE", 'tentacle_url = "poll://abcdefghij1234567890/"')
        self.assertEqual(fix_polling_tentacle_uri(config), config)


if __name__ == "__main__":
    unittest.main()
