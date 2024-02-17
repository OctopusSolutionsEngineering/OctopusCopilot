class FunctionCall:
    """
    This class represents a function and its arguments.
    """

    def __init__(self, function, args):
        self.function = function
        self.function_args = args

    def call_function(self):
        """
        Execute the function with the arguments
        :return: The result of the function call
        """
        return self.function(**self.function_args)
