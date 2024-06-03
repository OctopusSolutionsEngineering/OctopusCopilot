from langchain_core.tools import StructuredTool


class FunctionDefinition:
    """
    This class captures a function, its name, and the tool representation used
    by OpenAI.
    """

    def __init__(self, function, is_enabled=True, schema=None, callback=None):
        """
        Given a function, store the function, the name of the function, and
        the OpenAI tool representation of the function.
        :param function: The function that the LLM can call
        :param is_enabled: Whether the function is enabled or not
        :param schema: The pydantic schema of the function
        :param callback: The callback function to use if the original function needs to confirm an action
        """

        if function is None:
            raise ValueError('function must reference a valid function.')

        if not callable(function):
            raise ValueError('function is not callable: ' + str(function))

        self.name = function.__name__
        self.function = function
        self.tool = StructuredTool.from_function(function, schema)
        self.enabled = is_enabled
        self.callback = callback


class FunctionDefinitions:
    """
    This class represents a collection of FunctionDefinition objects.
    """

    def __init__(self, functions, fallback=None, invalid=None):
        """
        Construct a collection of function tools that can be used by OpenAI.
        :param functions: The list of functions to use as tool
        :param fallback: If the functions do not match, use this function as a fallback
        :param invalid: Sometimes an LLM will invent a function name. In this case, we use this function to handle the response.
        """
        self.functions = [function for function in functions if function]
        self.fallback = fallback
        self.invalid = invalid

    def get_tools(self):
        """
        Generate a set of tools that can be passed to OpenAI
        :return: The OpenAI tools
        """
        enabled_tools = filter(lambda f: f.enabled, self.functions)
        return list(map(lambda f: f.tool, enabled_tools))

    def has_fallback(self):
        return self.fallback is not None

    def get_fallback_tool(self):
        """
        Get the fallback tool
        :return: The OpenAI tools
        """
        return FunctionDefinitions([self.fallback])

    def get_callback_function(self, function_name):
        """
        Get the callback function that matches the supplied name
        :param function_name: The name of the function
        :return: The callback function associated with the name
        """

        if not function_name:
            raise ValueError('function_name must be a non-empty string.')

        enabled_functions = filter(lambda f: f.enabled, self.functions)
        function = list(filter(lambda f: f.name == function_name, enabled_functions))
        if len(function) == 1:
            return function[0].callback

        raise Exception(f"Callback for function {function_name} was not found")

    def get_function(self, function_name):
        """
        Get the function that matches the supplied name
        :param function_name: The name of the function
        :return: The function associated with the name
        """

        if not function_name:
            raise ValueError('function_name must be a non-empty string.')

        enabled_functions = filter(lambda f: f.enabled, self.functions)
        function = list(filter(lambda f: f.name == function_name, enabled_functions))
        if len(function) == 1:
            return function[0].function

        # If the LLM gave us an invalid function name, we can defer the response to the optional
        # invalid function fallback.
        if self.invalid:
            return self.invalid.function

        raise Exception(f"Function {function_name} was not found")
