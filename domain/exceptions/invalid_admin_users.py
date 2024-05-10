class InvalidAdminUsers(Exception):
    def __init__(self, message, original_exception):
        super().__init__(message)
        self.original_exception = original_exception
