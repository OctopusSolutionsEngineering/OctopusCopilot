import os
import unittest

from domain.messages.generate_hcl import get_live_messages


class GetTerraformExamplesTest(unittest.TestCase):
    @unittest.skip("This is only used to generate new examples")
    def test_get_live_messages(self):
        messages = get_live_messages(os.environ.get("GH_TEST_TOKEN"))
        print(messages)
        self.assertEqual(messages[0][0], "system")
        self.assertTrue(messages[0][1].startswith("HCL: ###"))
