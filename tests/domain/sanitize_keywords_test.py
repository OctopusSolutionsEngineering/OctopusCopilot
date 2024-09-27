import unittest

from domain.sanitizers.sanitize_keywords import sanitize_keywords


class TestSanitizeKeywords(unittest.TestCase):
    def test_sanitize_keywords_basic(self):
        keywords = ["octopus", "deploy", "python", "code"]
        result = sanitize_keywords(keywords, max_keywords=3)
        self.assertEqual(result, ["python", "code"])

    def test_sanitize_keywords_with_invalid_keywords(self):
        keywords = ["octopus", "deploy", "python", "code"]
        invalid_keywords = ["python"]
        result = sanitize_keywords(
            keywords, max_keywords=3, invalid_keywords=invalid_keywords
        )
        self.assertEqual(result, ["octopus", "deploy", "code"])

    def test_sanitize_keywords_max_keywords(self):
        keywords = ["octopus", "deploy", "python", "code", "test"]
        result = sanitize_keywords(keywords, max_keywords=2)
        self.assertEqual(result, ["python", "code"])

    def test_sanitize_keywords_empty_list(self):
        keywords = []
        result = sanitize_keywords(keywords, max_keywords=3)
        self.assertEqual(result, [])

    def test_sanitize_keywords_all_invalid(self):
        keywords = ["octopus", "deploy", "octopus deploy"]
        result = sanitize_keywords(keywords, max_keywords=3)
        self.assertEqual(result, [])

    def test_sanitize_keywords_case_insensitive(self):
        keywords = ["Octopus", "Deploy", "python", "Code"]
        result = sanitize_keywords(keywords, max_keywords=3)
        self.assertEqual(result, ["python", "Code"])
