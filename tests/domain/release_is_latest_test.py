import unittest

from domain.query.query_inspector import release_is_latest


class ReleaseIsLatestTest(unittest.TestCase):
    def test_release_is_latest(self):
        self.assertTrue(release_is_latest(None))
        self.assertTrue(release_is_latest(""))
        self.assertTrue(release_is_latest(" "))
        self.assertTrue(release_is_latest("latest"))
        self.assertTrue(release_is_latest("latest "))
        self.assertTrue(release_is_latest("most recent"))
        self.assertFalse(release_is_latest("second last"))
