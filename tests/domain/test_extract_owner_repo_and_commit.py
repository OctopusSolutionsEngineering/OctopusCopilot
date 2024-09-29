import unittest

from domain.url.github_urls import (
    extract_owner_repo_and_commit,
    extract_owner_repo_and_issue,
)


class EnsureTests(unittest.TestCase):
    def test_extract_owner_repo_and_commit(self):
        owner, repo, commit = extract_owner_repo_and_commit(
            "https://github.com/OctopusSolutionsEngineering/OctopusCopilot/commit/c9d97d7ddc046d283e231eb0cba7f327820258a8"
        )
        self.assertEqual("OctopusSolutionsEngineering", owner)
        self.assertEqual("OctopusCopilot", repo)
        self.assertEqual("c9d97d7ddc046d283e231eb0cba7f327820258a8", commit)

    def test_extract_owner_repo_and_commit_2(self):
        owner, repo, commit = extract_owner_repo_and_commit("https://google.com")
        self.assertIsNone(owner)
        self.assertIsNone(repo)
        self.assertIsNone(commit)

    def test_extract_owner_repo_and_issue(self):
        owner, repo, commit = extract_owner_repo_and_issue(
            "https://github.com/owner/repo/issues/2"
        )
        self.assertEqual("owner", owner)
        self.assertEqual("repo", repo)
        self.assertEqual("2", commit)

    def test_extract_owner_repo_and_issue_2(self):
        owner, repo, commit = extract_owner_repo_and_issue("https://google.com")
        self.assertIsNone(owner)
        self.assertIsNone(repo)
        self.assertIsNone(commit)
