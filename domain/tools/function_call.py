class FunctionCall:
    def __init__(self, function, args):
        self.function = function
        self.function_args = args

    def call_function(self):
        return self.function(**self.function_args)
