class OpenAIContentFilter(Exception):
    def __init__(self, original_exception):
        self.original_exception = original_exception


class OpenAITokenLengthExceeded(Exception):
    def __init__(self, original_exception):
        self.original_exception = original_exception


class OpenAIBadRequest(Exception):
    def __init__(self, original_exception):
        self.original_exception = original_exception
