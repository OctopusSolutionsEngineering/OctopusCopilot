import unittest

from domain.validation.default_value_validation import validate_default_value_name


class DefaultValueValidationTest(unittest.TestCase):
    def test_validation_fail(self):
        with self.assertRaises(ValueError) as value_error:
            validate_default_value_name("blah")

        the_exception = value_error.exception
        self.assertTrue("Invalid default name \"blah\"" in the_exception.args[0])

    def test_validation_succeed(self):
        validate_default_value_name("environment")
        validate_default_value_name("project")
        validate_default_value_name("space")
        validate_default_value_name("channel")
