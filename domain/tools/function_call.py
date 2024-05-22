class FunctionCall:
    """
    This class represents a function and its arguments.
    """

    def __init__(self, function, name, args):
        if function is None:
            raise ValueError('function must reference a valid function.')

        if not callable(function):
            raise ValueError('function is not callable: ' + str(function))

        self.function = function
        self.name = name
        self.function_args = args

    def call_function(self):
        """
        Execute the function with the arguments
        :return: The result of the function call
        """
        if not self.function_args:
            return self.function()

        return self.function(**self.function_args)
