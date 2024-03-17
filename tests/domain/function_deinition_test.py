import unittest

from domain.tools.function_definition import FunctionDefinition, FunctionDefinitions


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

        functions = FunctionDefinitions([FunctionDefinition(no_op)])

        with self.assertRaises(ValueError):
            functions.get_function(None)

        with self.assertRaises(Exception):
            functions.get_function("does not exist")

        self.assertEqual(no_op, functions.get_function("no_op"))
