from langchain_core.tools import StructuredTool

from domain.tools.function_call import FunctionCall


class FunctionDefinition:
    def __init__(self, function):
        self.name = function.__name__
        self.function = function
        self.tool = StructuredTool.from_function(function)


class FunctionDefinitions:
    def __init__(self, functions):
        self.functions = functions

    def get_tools(self):
        return list(map(lambda f: f.tool, self.functions))

    def call_function(self, function_call: FunctionCall):
        function = list(filter(lambda f: f.name == function_call.function_name, self.functions))
        if len(function) == 1:
            return function[0].function(**function_call.function_args)

        raise Exception(f"Function {function_call.function_name} was not found")
