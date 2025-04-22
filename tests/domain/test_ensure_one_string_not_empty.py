import unittest
from domain.validation.argument_validation import ensure_one_string_not_empty


class TestEnsureOneStringNotEmpty(unittest.TestCase):

    def test_with_one_valid_string(self):
        # Should not raise an exception
        result = ensure_one_string_not_empty("Error message", "valid string")
        self.assertTrue(result)

    def test_with_multiple_strings_one_valid(self):
        # Should not raise an exception when at least one valid string exists
        result = ensure_one_string_not_empty(
            "Error message", "", None, "valid string", 123
        )
        self.assertTrue(result)

    def test_with_first_argument_valid(self):
        # Should not raise an exception when first string is valid
        result = ensure_one_string_not_empty("Error message", "valid string", "", None)
        self.assertTrue(result)

    def test_with_whitespace_string(self):
        # Should raise an exception for whitespace-only strings
        with self.assertRaises(ValueError):
            ensure_one_string_not_empty("Error message", "   ", "\t", "\n")

    def test_with_no_valid_strings(self):
        # Should raise an exception when no valid strings are provided
        with self.assertRaises(ValueError):
            ensure_one_string_not_empty("Error message", "", None, 123, False)

    def test_with_no_arguments(self):
        # Should raise an exception when no arguments are provided
        with self.assertRaises(ValueError):
            ensure_one_string_not_empty("Error message")

    def test_error_message_passed_through(self):
        # Should pass the error message to the exception
        custom_error = "Custom error message"
        with self.assertRaisesRegex(ValueError, custom_error):
            ensure_one_string_not_empty(custom_error, None, "")


if __name__ == "__main__":
    unittest.main()
