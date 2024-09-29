import unittest

from domain.tools.wrapper.function_definition import FunctionDefinition, FunctionDefinitions


class FunctionDefinitionTest(unittest.TestCase):
    def test_init(self):
        with self.assertRaises(ValueError):
            FunctionDefinition(None)

    def test_functions(self):
        def no_op():
            """
            Does nothing
            """
            pass

        def disabled_function():
            """
            Does nothing
            """
            pass

        def enabled_function():
            """
            Does nothing
            """
            pass

        functions = FunctionDefinitions([
            FunctionDefinition(no_op),
            FunctionDefinition(disabled_function, is_enabled=False),
            FunctionDefinition(enabled_function, is_enabled=True),

        ])

        with self.assertRaises(ValueError):
            functions.get_function(None)

        with self.assertRaises(Exception):
            functions.get_function("does not exist")

        with self.assertRaises(Exception):
            functions.get_function("disabled_function")

        self.assertEqual(no_op, functions.get_function("no_op"))
        self.assertEqual(enabled_function, functions.get_function("enabled_function"))

        self.assertEqual(2, len(functions.get_tools()))
