import unittest
from unittest.mock import patch
from domain.context.github_docs import get_docs_context, get_raw_url_from_blob


class TestGitHubDocs(unittest.TestCase):
    @patch("domain.context.github_docs.download_file")
    def test_get_docs_context(self, mock_download_file):
        mock_download_file.return_value = "Mocked file content"

        search_results = {
            "items": [
                {"html_url": "https://github.com/user/repo/blob/main/file1.md"},
                {"html_url": "https://github.com/user/repo/blob/main/file2.md"},
            ]
        }

        expected_result = "Mocked file content\n\nMocked file content\n\n"
        result = get_docs_context(search_results)
        self.assertEqual(result, expected_result)

        # Test with empty search results
        self.assertEqual(get_docs_context({}), "")
        self.assertEqual(get_docs_context({"items": []}), "")
        self.assertEqual(get_docs_context(None), "")

    def test_get_raw_url_from_blob(self):
        html_url = "https://github.com/user/repo/blob/main/file.md"
        expected_raw_url = "https://github.com/user/repo/raw/main/file.md"
        self.assertEqual(get_raw_url_from_blob(html_url), expected_raw_url)


if __name__ == "__main__":
    unittest.main()
