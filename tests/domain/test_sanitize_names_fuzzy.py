import unittest
from unittest.mock import Mock
from domain.sanitizers.sanitized_list import sanitize_names_fuzzy, sanitize_name_fuzzy


class TestSanitizeNamesFuzzy(unittest.TestCase):
    def test_sanitize_names_fuzzy_exact_match(self):
        names_generator = Mock(
            return_value=iter([{"Name": "Project Alpha"}, {"Name": "Project Beta"}])
        )
        projects = ["Project Alpha"]
        result = sanitize_names_fuzzy(names_generator, projects)
        self.assertEqual(
            result, [{"original": "Project Alpha", "matched": "Project Alpha"}]
        )

    def test_sanitize_names_fuzzy_case_insensitive_match(self):
        names_generator = Mock(
            return_value=iter([{"Name": "project alpha"}, {"Name": "Project Beta"}])
        )
        projects = ["Project Alpha"]
        result = sanitize_names_fuzzy(names_generator, projects)
        self.assertEqual(
            result, [{"original": "Project Alpha", "matched": "project alpha"}]
        )

    def test_sanitize_names_fuzzy_fuzzy_match(self):
        names_generator = Mock(
            return_value=iter([{"Name": "Proj Alpha"}, {"Name": "Project Beta"}])
        )
        projects = ["Project Alpha"]
        result = sanitize_names_fuzzy(names_generator, projects)
        self.assertEqual(
            result, [{"original": "Project Alpha", "matched": "Proj Alpha"}]
        )

    def test_sanitize_names_fuzzy_no_match(self):
        names_generator = Mock(
            return_value=iter([{"Name": "Project Gamma"}, {"Name": "Project Delta"}])
        )
        projects = ["Project Alpha"]
        result = sanitize_names_fuzzy(names_generator, projects)
        self.assertEqual(
            result, [{"matched": "Project Delta", "original": "Project Alpha"}]
        )

    def test_sanitize_name_fuzzy_exact_match(self):
        names_generator = Mock(
            return_value=iter([{"Name": "Project Alpha"}, {"Name": "Project Beta"}])
        )
        name = "Project Alpha"
        result = sanitize_name_fuzzy(names_generator, name)
        self.assertEqual(
            result, {"original": "Project Alpha", "matched": "Project Alpha"}
        )

    def test_sanitize_name_fuzzy_case_insensitive_match(self):
        names_generator = Mock(
            return_value=iter([{"Name": "project alpha"}, {"Name": "Project Beta"}])
        )
        name = "Project Alpha"
        result = sanitize_name_fuzzy(names_generator, name)
        self.assertEqual(
            result, {"original": "Project Alpha", "matched": "project alpha"}
        )

    def test_sanitize_name_fuzzy_fuzzy_match(self):
        names_generator = Mock(
            return_value=iter([{"Name": "Proj Alpha"}, {"Name": "Project Beta"}])
        )
        name = "Project Alpha"
        result = sanitize_name_fuzzy(names_generator, name)
        self.assertEqual(result, {"original": "Project Alpha", "matched": "Proj Alpha"})

    def test_sanitize_name_fuzzy_no_match(self):
        names_generator = Mock(
            return_value=iter([{"Name": "Project Gamma"}, {"Name": "Project Delta"}])
        )
        name = "Project Alpha"
        result = sanitize_name_fuzzy(names_generator, name)
        self.assertEqual(
            result, {"original": "Project Alpha", "matched": "Project Delta"}
        )


if __name__ == "__main__":
    unittest.main()
