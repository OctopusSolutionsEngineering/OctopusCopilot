from langchain_core.tools import StructuredTool


class FunctionDefinition:
    """
    This class captures a function, its name, and the tool representation used
    by OpenAI.
    """

    def __init__(self, function, schema=None):
        """
        Given a function, store the function, the name of the function, and
        the OpenAI tool representation of the function.
        :param function: The function that the LLM can call
        :param schema: The pydantic schema of the function
        """

        if function is None:
            raise ValueError('function must reference a valid function.')

        self.name = function.__name__
        self.function = function
        self.tool = StructuredTool.from_function(function, schema)


class FunctionDefinitions:
    """
    This class represents a collection of FunctionDefinition objects.
    """

    def __init__(self, functions):
        self.functions = functions

    def get_tools(self):
        """
        Generate a set of tools that can be passed to OpenAI
        :return: The OpenAI tools
        """
        return list(map(lambda f: f.tool, self.functions))

    def get_function(self, function_name):
        """
        Get the function that matches the supplied name
        :param function_name: The name of the function
        :return: The function associated with the name
        """

        if not function_name:
            raise ValueError('function_name must be a non-empty string.')

        function = list(filter(lambda f: f.name == function_name, self.functions))
        if len(function) == 1:
            return function[0].function

        raise Exception(f"Function {function_name} was not found")
