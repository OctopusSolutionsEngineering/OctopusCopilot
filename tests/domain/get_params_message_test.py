import unittest

from domain.tools.debug import get_params


class EnsureTests(unittest.TestCase):
    def test_get_params_message(self):
        self.assertEqual(get_params("start", test="test"),
                         ["start was called with the following parameters:\n* test: test"])
