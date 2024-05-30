from domain.sanitizers.sanitized_list import sanitize_list
from domain.validation.argument_validation import ensure_string_not_empty
from infrastructure.users import is_feature_flagged_for_user, is_feature_flagged_for_all, is_feature_flagged_for_group


def is_feature_enabled_for_github_user(feature_name: str, github_user: str, user_groups: list,
                                       connection_string: str) -> bool:
    """
    Check if a feature is enabled for a GitHub user

    :param feature_name: The name of the feature. This is case-insensitive.
    :param github_user: The github user ID. This is case-insensitive.
    :param user_groups: Optional groups the user belongs to. The items in the list are case-insensitive.
    :param connection_string: The Azure storage connection string
    :return: True if the feature is enabled, and false otherwise
    """
    ensure_string_not_empty(feature_name, 'feature_name must be the name of the feature '
                                          '(is_feature_enabled_for_github_user).')
    ensure_string_not_empty(github_user, 'github_user must be the GitHub user ID (is_feature_enabled_for_github_user).')
    ensure_string_not_empty(connection_string,
                            'connection_string must be the Azure storage connection string '
                            '(is_feature_enabled_for_github_user).')

    # If the feature is enabled for everyone, return true
    if is_feature_flagged_for_all(feature_name, connection_string):
        return True

    sanitized_user_groups = sanitize_list(user_groups)

    # If the feature is enabled for the group
    if next(filter(lambda group: is_feature_flagged_for_group(feature_name, group, connection_string),
                                  sanitized_user_groups), False):
        return True

    # If the feature is enabled for the user, return true
    if is_feature_flagged_for_user(feature_name, github_user, connection_string):
        return True

    return False
