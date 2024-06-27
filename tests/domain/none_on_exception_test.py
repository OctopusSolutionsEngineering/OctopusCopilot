import unittest

from domain.exceptions.none_on_exception import none_on_exception


def return_two():
    return "hi", 1


class TestNoneOnException(unittest.TestCase):
    def test_none_on_exception(self):
        self.assertIsNone(none_on_exception(lambda: None.blah()))
        self.assertEqual(none_on_exception(lambda: 1), 1)
        self.assertEqual(none_on_exception(return_two), ("hi", 1))
        with self.assertRaises(ValueError):
            none_on_exception(None)
