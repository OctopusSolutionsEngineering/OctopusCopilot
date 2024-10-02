import unittest
from unittest.mock import patch
from domain.featureflags.feature_flags import is_feature_enabled_for_github_user


class TestFeatureFlags(unittest.TestCase):
    @patch("domain.featureflags.feature_flags.is_feature_flagged_for_all")
    @patch("domain.featureflags.feature_flags.is_feature_flagged_for_user")
    @patch("domain.featureflags.feature_flags.is_feature_flagged_for_group")
    @patch("domain.sanitizers.sanitized_list.sanitize_list")
    @patch("domain.validation.argument_validation.ensure_string_not_empty")
    def test_is_feature_enabled_for_github_user(
        self,
        mock_ensure_string_not_empty,
        mock_sanitize_list,
        mock_is_feature_flagged_for_group,
        mock_is_feature_flagged_for_user,
        mock_is_feature_flagged_for_all,
    ):
        feature_name = "test_feature"
        github_user = "test_user"
        user_groups = ["group1", "group2"]
        connection_string = "test_connection_string"

        # Test when feature is enabled for all
        mock_is_feature_flagged_for_all.return_value = True
        self.assertTrue(
            is_feature_enabled_for_github_user(
                feature_name, github_user, user_groups, connection_string
            )
        )

        # Test when feature is enabled for a group
        mock_is_feature_flagged_for_all.return_value = False
        mock_sanitize_list.return_value = user_groups
        mock_is_feature_flagged_for_group.side_effect = (
            lambda feature, group, conn: group == "group1"
        )
        self.assertTrue(
            is_feature_enabled_for_github_user(
                feature_name, github_user, user_groups, connection_string
            )
        )

        # Test when feature is enabled for a user
        mock_is_feature_flagged_for_group.side_effect = (
            lambda feature, group, conn: False
        )
        mock_is_feature_flagged_for_user.return_value = True
        self.assertTrue(
            is_feature_enabled_for_github_user(
                feature_name, github_user, user_groups, connection_string
            )
        )

        # Test when feature is not enabled
        mock_is_feature_flagged_for_user.return_value = False
        self.assertFalse(
            is_feature_enabled_for_github_user(
                feature_name, github_user, user_groups, connection_string
            )
        )

    @patch("domain.featureflags.feature_flags.is_feature_flagged_for_all")
    @patch("domain.featureflags.feature_flags.is_feature_flagged_for_user")
    @patch("domain.featureflags.feature_flags.is_feature_flagged_for_group")
    @patch("domain.sanitizers.sanitized_list.sanitize_list")
    def test_is_feature_enabled_for_github_user(
        self,
        mock_sanitize_list,
        mock_is_feature_flagged_for_group,
        mock_is_feature_flagged_for_user,
        mock_is_feature_flagged_for_all,
    ):
        feature_name = "test_feature"
        github_user = "test_user"
        user_groups = ["group1", "group2"]
        connection_string = "test_connection_string"

        # Test when feature is enabled for all
        mock_is_feature_flagged_for_all.return_value = True
        self.assertTrue(
            is_feature_enabled_for_github_user(
                feature_name, github_user, user_groups, connection_string
            )
        )

        # Test when feature is enabled for a group
        mock_is_feature_flagged_for_all.return_value = False
        mock_sanitize_list.return_value = user_groups
        mock_is_feature_flagged_for_group.side_effect = (
            lambda feature, group, conn: group == "group1"
        )
        self.assertTrue(
            is_feature_enabled_for_github_user(
                feature_name, github_user, user_groups, connection_string
            )
        )

        # Test when feature is enabled for a user
        mock_is_feature_flagged_for_group.side_effect = (
            lambda feature, group, conn: False
        )
        mock_is_feature_flagged_for_user.return_value = True
        self.assertTrue(
            is_feature_enabled_for_github_user(
                feature_name, github_user, user_groups, connection_string
            )
        )

        # Test when feature is not enabled
        mock_is_feature_flagged_for_user.return_value = False
        self.assertFalse(
            is_feature_enabled_for_github_user(
                feature_name, github_user, user_groups, connection_string
            )
        )


if __name__ == "__main__":
    unittest.main()
