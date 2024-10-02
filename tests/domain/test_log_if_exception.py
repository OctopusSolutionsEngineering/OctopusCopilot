import unittest
from unittest.mock import Mock
from domain.logging.log_if_exception import log_if_exception


class TestLogIfException(unittest.TestCase):
    def test_log_if_exception_with_exception(self):
        mock_logging = Mock()
        exception = Exception("Test exception")
        log_if_exception(mock_logging, exception, "Error occurred")
        mock_logging.assert_called_once_with("Error occurred", "Test exception")

    def test_log_if_exception_without_exception(self):
        mock_logging = Mock()
        log_if_exception(mock_logging, "Not an exception", "Error occurred")
        mock_logging.assert_not_called()

    def test_log_if_exception_with_none_logging(self):
        log_if_exception(None, Exception("Test exception"), "Error occurred")
        # No assertion needed, just ensuring no exception is raised


if __name__ == "__main__":
    unittest.main()
