import unittest
from domain.sanitizers.sanitized_list import update_query


class TestUpdateQuery(unittest.TestCase):
    def test_update_query_with_exact_match(self):
        original_query = "Deploy project Alpha"
        sanitized_projects = [{"original": "Alpha", "matched": "Project Alpha"}]
        result = update_query(original_query, sanitized_projects)
        self.assertEqual(result, "Deploy project Project Alpha")

    def test_update_query_with_multiple_matches(self):
        original_query = "Deploy project Alpha and Beta"
        sanitized_projects = [
            {"original": "Alpha", "matched": "Project Alpha"},
            {"original": "Beta", "matched": "Project Beta"},
        ]
        result = update_query(original_query, sanitized_projects)
        self.assertEqual(result, "Deploy project Project Alpha and Project Beta")

    def test_update_query_with_no_matches(self):
        original_query = "Deploy project Alpha"
        sanitized_projects = []
        result = update_query(original_query, sanitized_projects)
        self.assertEqual(result, "Deploy project Alpha")

    def test_update_query_with_partial_match(self):
        original_query = "Deploy project Alpha and Gamma"
        sanitized_projects = [{"original": "Alpha", "matched": "Project Alpha"}]
        result = update_query(original_query, sanitized_projects)
        self.assertEqual(result, "Deploy project Project Alpha and Gamma")


if __name__ == "__main__":
    unittest.main()
