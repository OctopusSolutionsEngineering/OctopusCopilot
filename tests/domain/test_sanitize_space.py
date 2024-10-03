import unittest
from domain.sanitizers.sanitized_list import sanitize_space


class TestSanitizeSpace(unittest.TestCase):
    def test_sanitize_space_with_default_in_query(self):
        query = "default space"
        input_list = ["default", "Space 1", "Space 2"]
        result = sanitize_space(query, input_list)
        self.assertEqual(result, "default")

    def test_sanitize_space_without_default_in_query(self):
        query = "some other space"
        input_list = ["default", "Space 1", "Space 2"]
        result = sanitize_space(query, input_list)
        self.assertIsNone(result)

    def test_sanitize_space_empty_query(self):
        query = ""
        input_list = ["default", "Space 1", "Space 2"]
        result = sanitize_space(query, input_list)
        self.assertIsNone(result)

    def test_sanitize_space_no_matching_space(self):
        query = "nonexistent space"
        input_list = ["default"]
        result = sanitize_space(query, input_list)
        self.assertIsNone(result)

    def test_sanitize_space_empty_input_list(self):
        query = "default space"
        input_list = []
        result = sanitize_space(query, input_list)
        self.assertIsNone(result)


if __name__ == "__main__":
    unittest.main()
