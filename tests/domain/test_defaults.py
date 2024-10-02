import unittest
from unittest.mock import patch
from domain.defaults.defaults import get_default_argument, get_default_argument_list


class TestDefaults(unittest.TestCase):
    @patch("domain.defaults.defaults.get_default_values")
    @patch("domain.defaults.defaults.get_functions_connection_string")
    def test_get_default_argument(
        self, mock_get_functions_connection_string, mock_get_default_values
    ):
        mock_get_functions_connection_string.return_value = "mock_connection_string"
        mock_get_default_values.return_value = "default_value"

        self.assertEqual(
            get_default_argument("user1", "", "default_name"), "default_value"
        )
        self.assertEqual(
            get_default_argument("user1", "argument", "default_name"), "argument"
        )
        self.assertEqual(
            get_default_argument("", "argument", "default_name"), "argument"
        )
        self.assertEqual(
            get_default_argument(None, "argument", "default_name"), "argument"
        )
        self.assertEqual(
            get_default_argument("user1", None, "default_name"), "default_value"
        )

    @patch("domain.defaults.defaults.get_default_values")
    @patch("domain.defaults.defaults.get_functions_connection_string")
    def test_get_default_argument_list(
        self, mock_get_functions_connection_string, mock_get_default_values
    ):
        mock_get_functions_connection_string.return_value = "mock_connection_string"
        mock_get_default_values.return_value = "default_value"

        self.assertEqual(
            get_default_argument_list("user1", "", "default_name"), ["default_value"]
        )
        self.assertEqual(
            get_default_argument_list("user1", "argument", "default_name"), ["argument"]
        )
        self.assertEqual(
            get_default_argument_list("", "argument", "default_name"), ["argument"]
        )
        self.assertEqual(
            get_default_argument_list(None, "argument", "default_name"), ["argument"]
        )
        self.assertEqual(
            get_default_argument_list("user1", None, "default_name"), ["default_value"]
        )
        self.assertEqual(
            get_default_argument_list("user1", ["arg1", "arg2"], "default_name"),
            ["arg1", "arg2"],
        )


if __name__ == "__main__":
    unittest.main()
