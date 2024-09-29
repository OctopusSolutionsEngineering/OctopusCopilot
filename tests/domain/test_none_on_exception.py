import unittest

from domain.exceptions.none_on_exception import none_on_exception, default_on_exception


def return_two():
    return "hi", 1


def raise_exception():
    raise ValueError("Test exception")


class TestNoneOnException(unittest.TestCase):
    def test_none_on_exception(self):
        self.assertIsNone(none_on_exception(lambda: None.blah()))
        self.assertIsNone(none_on_exception(raise_exception))
        self.assertEqual(none_on_exception(lambda: 1), 1)
        self.assertEqual(none_on_exception(return_two), ("hi", 1))
        with self.assertRaises(ValueError):
            none_on_exception(None)

    def test_default_on_exception(self):
        self.assertIsNone(default_on_exception(lambda: None.blah(), None))
        self.assertIsNone(default_on_exception(raise_exception, None))
        self.assertEqual(default_on_exception(lambda: 1, None), 1)
        self.assertEqual(default_on_exception(return_two, None), ("hi", 1))
        with self.assertRaises(ValueError):
            default_on_exception(None, None)
