import unittest

from domain.sanitizers.terraform import join_block_header_braces


class TestJoinBlockHeaderBraces(unittest.TestCase):
    def test_bracket_on_next_line_is_joined(self):
        config = 'resource "octopusdeploy_lifecycle" "lifecycle_hotfix"\n  {\n  name = "Hotfix"\n}\n'
        self.assertEqual(
            'resource "octopusdeploy_lifecycle" "lifecycle_hotfix" {\n  name = "Hotfix"\n}\n',
            join_block_header_braces(config),
        )

    def test_data_block_is_joined(self):
        config = 'data "octopusdeploy_feeds" "feed"\n{\n  take = 1\n}\n'
        self.assertEqual('data "octopusdeploy_feeds" "feed" {\n  take = 1\n}\n', join_block_header_braces(config))

    def test_normal_header_is_unchanged(self):
        config = 'resource "octopusdeploy_lifecycle" "lifecycle_hotfix" {\n  name = "Hotfix"\n}\n'
        self.assertEqual(config, join_block_header_braces(config))

    def test_nested_blocks_are_unchanged(self):
        config = 'resource "octopusdeploy_lifecycle" "l" {\n  phase {\n    name = "A"\n  }\n}\n'
        self.assertEqual(config, join_block_header_braces(config))

    def test_none_and_empty(self):
        self.assertIsNone(join_block_header_braces(None))
        self.assertEqual("", join_block_header_braces(""))


if __name__ == "__main__":
    unittest.main()
