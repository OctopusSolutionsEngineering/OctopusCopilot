from datetime import timedelta, datetime

from azure.core.exceptions import HttpResponseError
from azure.data.tables import TableServiceClient, UpdateMode

from domain.encryption.encryption import encrypt_eax, generate_password
from domain.errors.error_handling import handle_error
from domain.logging.app_logging import configure_logging
from domain.validation.argument_validation import ensure_string_not_empty
from domain.validation.codefresh_validation import is_valid_token
from domain.validation.octopus_validation import is_api_key
from domain.validation.url_validation import validate_url
from infrastructure.octopus import logging_wrapper

logger = configure_logging(__name__)


@logging_wrapper
def database_connection_test(connection_string):
    ensure_string_not_empty(
        connection_string,
        "connection_string must be the connection string (test_database).",
    )

    table_service_client = TableServiceClient.from_connection_string(
        conn_str=connection_string
    )
    table_client = table_service_client.create_table_if_not_exists("healthcheck")

    test = {"PartitionKey": "github.com", "RowKey": "test"}

    table_client.upsert_entity(test)


@logging_wrapper
def enable_feature_flag_for_user(feature_name, github_user, connection_string):
    ensure_string_not_empty(
        feature_name,
        "feature_name must be feature name (enable_feature_flag_for_user).",
    )
    ensure_string_not_empty(
        github_user,
        "github_user must be the Github user ID (enable_feature_flag_for_user).",
    )
    ensure_string_not_empty(
        connection_string,
        "connection_string must be the connection string (enable_feature_flag_for_user).",
    )

    flag = {
        "PartitionKey": "github.com",
        "RowKey": feature_name.casefold().strip(),
        github_user.casefold().strip(): True,
    }

    table_service_client = TableServiceClient.from_connection_string(
        conn_str=connection_string
    )
    table_client = table_service_client.create_table_if_not_exists("featureflagsuser")
    table_client.upsert_entity(flag)


@logging_wrapper
def enable_feature_flag_for_group(feature_name, user_group, connection_string):
    ensure_string_not_empty(
        feature_name,
        "feature_name must be feature name (enable_feature_flag_for_group).",
    )
    ensure_string_not_empty(
        user_group,
        "user_group must be the name of the user group (enable_feature_flag_for_group).",
    )
    ensure_string_not_empty(
        connection_string,
        "connection_string must be the connection string (enable_feature_flag_for_group).",
    )

    flag = {
        "PartitionKey": "github.com",
        "RowKey": feature_name.casefold().strip(),
        user_group.casefold().strip(): True,
    }

    table_service_client = TableServiceClient.from_connection_string(
        conn_str=connection_string
    )
    table_client = table_service_client.create_table_if_not_exists("featureflagsgroup")
    table_client.upsert_entity(flag)


@logging_wrapper
def enable_feature_flag_for_all(feature_name, connection_string):
    ensure_string_not_empty(
        feature_name, "feature_name must be feature name (enable_feature_flag_for_all)."
    )
    ensure_string_not_empty(
        connection_string,
        "connection_string must be the connection string (enable_feature_flag_for_all).",
    )

    flag = {
        "PartitionKey": "github.com",
        "RowKey": feature_name.casefold().strip(),
        "enabled": True,
    }

    table_service_client = TableServiceClient.from_connection_string(
        conn_str=connection_string
    )
    table_client = table_service_client.create_table_if_not_exists("featureflagsglobal")
    table_client.upsert_entity(flag)


@logging_wrapper
def disable_feature_flag_for_user(feature_name, github_user, connection_string):
    ensure_string_not_empty(
        feature_name,
        "feature_name must be feature name (disable_feature_flag_for_user).",
    )
    ensure_string_not_empty(
        github_user,
        "github_user must be the Github user ID (disable_feature_flag_for_user).",
    )
    ensure_string_not_empty(
        connection_string,
        "connection_string must be the connection string (disable_feature_flag_for_user).",
    )

    flag = {
        "PartitionKey": "github.com",
        "RowKey": feature_name.casefold().strip(),
        github_user.casefold().strip(): False,
    }

    table_service_client = TableServiceClient.from_connection_string(
        conn_str=connection_string
    )
    table_client = table_service_client.create_table_if_not_exists("featureflagsuser")
    table_client.upsert_entity(flag)


@logging_wrapper
def disable_feature_flag_for_group(feature_name, user_group, connection_string):
    ensure_string_not_empty(
        feature_name,
        "feature_name must be feature name (disable_feature_flag_for_group).",
    )
    ensure_string_not_empty(
        user_group,
        "user_group must be the name of the user group (disable_feature_flag_for_group).",
    )
    ensure_string_not_empty(
        connection_string,
        "connection_string must be the connection string (disable_feature_flag_for_group).",
    )

    flag = {
        "PartitionKey": "github.com",
        "RowKey": feature_name.casefold().strip(),
        user_group.casefold().strip(): False,
    }

    table_service_client = TableServiceClient.from_connection_string(
        conn_str=connection_string
    )
    table_client = table_service_client.create_table_if_not_exists("featureflagsgroup")
    table_client.upsert_entity(flag)


@logging_wrapper
def disable_feature_flag_for_all(feature_name, connection_string):
    ensure_string_not_empty(
        feature_name,
        "feature_name must be feature name (disable_feature_flag_for_all).",
    )
    ensure_string_not_empty(
        connection_string,
        "connection_string must be the connection string (disable_feature_flag_for_all).",
    )

    flag = {
        "PartitionKey": "github.com",
        "RowKey": feature_name.casefold().strip(),
        "enabled": False,
    }

    table_service_client = TableServiceClient.from_connection_string(
        conn_str=connection_string
    )
    table_client = table_service_client.create_table_if_not_exists("featureflagsglobal")
    table_client.upsert_entity(flag)


@logging_wrapper
def is_feature_flagged_for_user(feature_name, github_user, connection_string):
    ensure_string_not_empty(
        feature_name, "feature_name must be feature name (is_feature_flagged_for_user)."
    )
    ensure_string_not_empty(
        github_user,
        "github_user must be the Github user ID (is_feature_flagged_for_user).",
    )
    ensure_string_not_empty(
        connection_string,
        "connection_string must be the connection string (is_feature_flagged_for_user).",
    )

    try:
        table_service_client = TableServiceClient.from_connection_string(
            conn_str=connection_string
        )
        table_client = table_service_client.create_table_if_not_exists(
            "featureflagsuser"
        )
        defaults = table_client.get_entity(
            "github.com", feature_name.casefold().strip()
        )

        sanitised_github_user = github_user.casefold().strip()

        if sanitised_github_user in defaults:
            return defaults[sanitised_github_user]

        return False
    except HttpResponseError as e:
        return False


@logging_wrapper
def is_feature_flagged_for_group(feature_name, user_group, connection_string):
    ensure_string_not_empty(
        feature_name,
        "feature_name must be feature name (is_feature_flagged_for_group).",
    )
    ensure_string_not_empty(
        user_group,
        "user_group must be the name of the user group (is_feature_flagged_for_group).",
    )
    ensure_string_not_empty(
        connection_string,
        "connection_string must be the connection string (is_feature_flagged_for_group).",
    )

    try:
        table_service_client = TableServiceClient.from_connection_string(
            conn_str=connection_string
        )
        table_client = table_service_client.create_table_if_not_exists(
            "featureflagsgroup"
        )
        defaults = table_client.get_entity(
            "github.com", feature_name.casefold().strip()
        )

        sanitised_user_group = user_group.casefold().strip()

        if sanitised_user_group in defaults:
            return defaults[sanitised_user_group]

        return False
    except HttpResponseError as e:
        return False


@logging_wrapper
def is_feature_flagged_for_all(feature_name, connection_string):
    ensure_string_not_empty(
        feature_name, "feature_name must be feature name (is_feature_flagged_for_all)."
    )
    ensure_string_not_empty(
        connection_string,
        "connection_string must be the connection string (is_feature_flagged_for_all).",
    )

    try:
        table_service_client = TableServiceClient.from_connection_string(
            conn_str=connection_string
        )
        table_client = table_service_client.create_table_if_not_exists(
            "featureflagsglobal"
        )
        defaults = table_client.get_entity(
            "github.com", feature_name.casefold().strip()
        )

        if "enabled" in defaults:
            return defaults["enabled"]

        return False
    except HttpResponseError as e:
        return False


@logging_wrapper
def save_default_values(username, default_name, default_value, connection_string):
    ensure_string_not_empty(
        username, "username must be the GitHub user's ID (save_default_values)."
    )
    ensure_string_not_empty(
        default_name, "default_name must be a non-empty string (save_default_values)."
    )
    ensure_string_not_empty(
        connection_string,
        "connection_string must be the connection string (save_default_values).",
    )

    user = {
        "PartitionKey": "github.com",
        "RowKey": username,
        default_name.casefold().strip(): default_value,
    }

    table_service_client = TableServiceClient.from_connection_string(
        conn_str=connection_string
    )
    table_client = table_service_client.create_table_if_not_exists("userdefaults")
    table_client.upsert_entity(user)


@logging_wrapper
def save_profile(username, profile_name, values, connection_string):
    ensure_string_not_empty(
        username, "username must be the GitHub user's ID (save_profile)."
    )
    ensure_string_not_empty(
        profile_name, "profile_name must be a non-empty string (save_profile)."
    )
    ensure_string_not_empty(
        connection_string,
        "connection_string must be the connection string (save_profile).",
    )

    user = {"PartitionKey": "github.com_" + username, "RowKey": profile_name}

    for default_name in values:
        user[default_name] = values[default_name]

    table_service_client = TableServiceClient.from_connection_string(
        conn_str=connection_string
    )
    table_client = table_service_client.create_table_if_not_exists("userprofiles")
    table_client.upsert_entity(user)


@logging_wrapper
def get_profile(username, profile_name, connection_string):
    ensure_string_not_empty(
        username, "username must be the GitHub user's ID (get_profile)."
    )
    ensure_string_not_empty(
        profile_name, "profile_name must be a non-empty string (get_profile)."
    )
    ensure_string_not_empty(
        connection_string,
        "connection_string must be the connection string (get_profile).",
    )

    try:
        table_service_client = TableServiceClient.from_connection_string(
            conn_str=connection_string
        )
        table_client = table_service_client.create_table_if_not_exists("userprofiles")
        return table_client.get_entity("github.com_" + username, profile_name)
    except HttpResponseError as e:
        return None


@logging_wrapper
def get_profiles(username, connection_string):
    ensure_string_not_empty(
        username, "username must be the GitHub user's ID (get_profile)."
    )
    ensure_string_not_empty(
        connection_string,
        "connection_string must be the connection string (get_profile).",
    )

    try:
        table_service_client = TableServiceClient.from_connection_string(
            conn_str=connection_string
        )
        table_client = table_service_client.create_table_if_not_exists("userprofiles")
        entities = table_client.query_entities(
            "PartitionKey eq '" + "github.com_" + username + "'",
        )
        for entity in entities:
            yield entity["RowKey"]
    except HttpResponseError as e:
        return None


@logging_wrapper
def delete_default_values(username, connection_string):
    ensure_string_not_empty(
        username, "username must be the GitHub user's ID (delete_default_values)."
    )
    ensure_string_not_empty(
        connection_string,
        "connection_string must be the connection string (delete_default_values).",
    )

    table_service_client = TableServiceClient.from_connection_string(
        conn_str=connection_string
    )
    table_client = table_service_client.create_table_if_not_exists("userdefaults")
    table_client.delete_entity("github.com", username)


@logging_wrapper
def get_default_values(username, default_name, connection_string):
    ensure_string_not_empty(
        username, "username must be the GitHub user's ID (get_default_values)."
    )
    ensure_string_not_empty(
        default_name, "default_name must be a non-empty string (get_default_values)."
    )
    ensure_string_not_empty(
        connection_string,
        "connection_string must be the connection string (get_default_values).",
    )

    try:
        table_service_client = TableServiceClient.from_connection_string(
            conn_str=connection_string
        )
        table_client = table_service_client.create_table_if_not_exists("userdefaults")
        defaults = table_client.get_entity("github.com", username)

        sanitised_default_name = default_name.casefold().strip()

        if sanitised_default_name in defaults:
            return defaults[default_name.casefold().strip()]

        return None
    except HttpResponseError as e:
        return None


@logging_wrapper
def save_users_octopus_url(
    username, octopus_url, encrypted_api_key, tag, nonce, connection_string
):
    ensure_string_not_empty(
        username, "username must be the GitHub user's ID (save_users_octopus_url)."
    )
    ensure_string_not_empty(
        octopus_url, "octopus_url must be an Octopus URL (save_users_octopus_url)."
    )
    ensure_string_not_empty(
        encrypted_api_key,
        "api_key must be the ID of a service account (save_users_octopus_url).",
    )
    ensure_string_not_empty(
        tag,
        "tag must be the tag associated with the encrypted api key (save_users_octopus_url).",
    )
    ensure_string_not_empty(
        nonce,
        "nonce must be the nonce associated with the encrypted api key (save_users_octopus_url).",
    )
    ensure_string_not_empty(
        connection_string,
        "connection_string must be the connection string (save_users_octopus_url).",
    )

    user = {
        "PartitionKey": "github.com",
        "RowKey": username,
        "OctopusUrl": octopus_url,
        "OctopusApiKey": encrypted_api_key,
        "EncryptionTag": tag,
        "EncryptionNonce": nonce,
    }

    table_service_client = TableServiceClient.from_connection_string(
        conn_str=connection_string
    )
    table_client = table_service_client.create_table_if_not_exists("users")
    table_client.upsert_entity(user)


@logging_wrapper
def save_users_codefresh_details(
    username, encrypted_token, tag, nonce, connection_string
):
    ensure_string_not_empty(
        username, "username must be the GitHub user's ID (save_users_codefresh_details)."
    )
    ensure_string_not_empty(
        encrypted_token,
        "encrypted_token must be a the ID of a service account (save_users_codefresh_details).",
    )
    ensure_string_not_empty(
        tag,
        "tag must be a the tag associated with the encrypted api key (save_users_codefresh_details).",
    )
    ensure_string_not_empty(
        nonce,
        "nonce must be a the nonce associated with the encrypted api key (save_users_codefresh_details).",
    )
    ensure_string_not_empty(
        connection_string,
        "connection_string must be the connection string (save_users_codefresh_details).",
    )

    user = {
        "PartitionKey": "github.com",
        "RowKey": username,
        "CodefreshToken": encrypted_token,
        "EncryptionTag": tag,
        "EncryptionNonce": nonce,
    }

    table_service_client = TableServiceClient.from_connection_string(
        conn_str=connection_string
    )
    table_client = table_service_client.create_table_if_not_exists("codefreshusers")
    table_client.upsert_entity(user)


@logging_wrapper
def save_users_slack_token(
    username, encrypted_access_token, tag, nonce, connection_string
):
    ensure_string_not_empty(
        username, "username must be the GitHub user's ID (save_users_slack_token)."
    )
    ensure_string_not_empty(
        encrypted_access_token,
        "encrypted_access_token must be a the slack access token of a service account (save_users_slack_token).",
    )
    ensure_string_not_empty(
        tag,
        "tag must be a the tag associated with the encrypted api key (save_users_slack_token).",
    )
    ensure_string_not_empty(
        nonce,
        "nonce must be a the nonce associated with the encrypted api key (save_users_slack_token).",
    )
    ensure_string_not_empty(
        connection_string,
        "connection_string must be the connection string (save_users_slack_token).",
    )

    user = {
        "PartitionKey": "github.com",
        "RowKey": username,
        "SlackAccessToken": encrypted_access_token,
        "EncryptionTag": tag,
        "EncryptionNonce": nonce,
    }

    table_service_client = TableServiceClient.from_connection_string(
        conn_str=connection_string
    )
    table_client = table_service_client.create_table_if_not_exists("slackusers")
    table_client.upsert_entity(user)


@logging_wrapper
def save_users_slack_login(
    username, access_token, encryption_password, encryption_salt, connection_string
):
    ensure_string_not_empty(
        username, "username must be the GitHub user ID (save_users_slack_login)."
    )
    ensure_string_not_empty(
        access_token,
        "access_token must be the Slack access token URL (save_users_slack_login).",
    )
    ensure_string_not_empty(
        connection_string,
        "connection_string must be the connection string (save_users_slack_login).",
    )

    encryption_password = generate_password(encryption_password, encryption_salt)
    encrypted_api_key, tag, nonce = encrypt_eax(
        access_token, encryption_password, encryption_salt
    )
    save_users_slack_token(username, encrypted_api_key, tag, nonce, connection_string)


@logging_wrapper
def save_users_octopus_url_from_login(
    username, url, api, encryption_password, encryption_salt, connection_string
):
    ensure_string_not_empty(
        username,
        "username must be the GitHub user ID (save_users_octopus_url_from_login).",
    )
    ensure_string_not_empty(
        url, "url must be the Octopus URL (save_users_octopus_url_from_login)."
    )
    ensure_string_not_empty(
        api, "api must be the Octopus API key (save_users_octopus_url_from_login)."
    )
    ensure_string_not_empty(
        connection_string,
        "connection_string must be the connection string (save_users_octopus_url_from_login).",
    )

    if not validate_url(url):
        raise ValueError("The Octopus URL is not valid (save_users_octopus_url).")

    if not is_api_key(api):
        raise ValueError("The API key is not valid (save_users_octopus_url).")

    encryption_password = generate_password(encryption_password, encryption_salt)
    encrypted_api_key, tag, nonce = encrypt_eax(
        api, encryption_password, encryption_salt
    )
    save_users_octopus_url(
        username, url, encrypted_api_key, tag, nonce, connection_string
    )


@logging_wrapper
def save_users_codefresh_details_from_login(
    username, token, encryption_password, encryption_salt, connection_string
):
    ensure_string_not_empty(
        username,
        "username must be the GitHub user ID (save_users_codefresh_details_from_login).",
    )
    ensure_string_not_empty(
        token, "token must be the Codefresh token (save_users_codefresh_details_from_login)."
    )
    ensure_string_not_empty(
        connection_string,
        "connection_string must be the connection string (save_users_codefresh_details_from_login).",
    )

    if not is_valid_token(token):
        raise ValueError("The Token is not valid (save_users_codefresh_details_from_login).")

    encryption_password = generate_password(encryption_password, encryption_salt)
    encrypted_token, tag, nonce = encrypt_eax(
        token, encryption_password, encryption_salt
    )
    save_users_codefresh_details(
        username, encrypted_token, tag, nonce, connection_string
    )


@logging_wrapper
def get_users_details(username, connection_string):
    ensure_string_not_empty(
        username, "username must be the GitHub user's ID (get_users_details)."
    )
    ensure_string_not_empty(
        connection_string,
        "connection_string must be the connection string (save_users_octopus_url).",
    )

    table_service_client = TableServiceClient.from_connection_string(
        conn_str=connection_string
    )
    table_client = table_service_client.create_table_if_not_exists("users")
    return table_client.get_entity("github.com", username)


@logging_wrapper
def get_users_slack_details(username, connection_string):
    ensure_string_not_empty(
        username, "username must be the GitHub user's ID (get_users_slack_details)."
    )
    ensure_string_not_empty(
        connection_string,
        "connection_string must be the connection string (get_users_slack_details).",
    )

    table_service_client = TableServiceClient.from_connection_string(
        conn_str=connection_string
    )
    table_client = table_service_client.create_table_if_not_exists("slackusers")
    return table_client.get_entity("github.com", username)


@logging_wrapper
def get_users_codefresh_details(username, connection_string):
    ensure_string_not_empty(
        username, "username must be the GitHub user's ID (get_users_codefresh_details)."
    )
    ensure_string_not_empty(
        connection_string,
        "connection_string must be the connection string (get_users_codefresh_details).",
    )

    table_service_client = TableServiceClient.from_connection_string(
        conn_str=connection_string
    )
    table_client = table_service_client.create_table_if_not_exists("codefreshusers")
    return table_client.get_entity("github.com", username)


@logging_wrapper
def delete_old_user_details(connection_string):
    """
    We don't want to hold onto keys for very long. Every hour or so keys older than 8 hours are purged from the database
    and users need to log in again.
    :param connection_string: The database connection string
    :return: The number of deleted records.
    """

    ensure_string_not_empty(
        connection_string,
        "connection_string must be the connection string (delete_old_user_details).",
    )

    try:
        table_service_client = TableServiceClient.from_connection_string(
            conn_str=connection_string
        )
        table_client = table_service_client.get_table_client(table_name="users")

        old_records = (datetime.now() - timedelta(hours=8)).strftime(
            "%Y-%m-%dT%H:%M:%S.%fZ"
        )

        rows = table_client.query_entities(f"Timestamp lt datetime'{old_records}'")
        counter = 0
        for row in rows:
            counter = counter + 1
            table_client.delete_entity("github.com", row["RowKey"])

        logger.info(f"Cleaned up {counter} entries.")

        return counter

    except HttpResponseError as e:
        handle_error(e)


@logging_wrapper
def delete_old_slack_user_details(connection_string):
    """
    Clean up any old slack tokens
    :param connection_string: The database connection string
    :return: The number of deleted records.
    """

    ensure_string_not_empty(
        connection_string,
        "connection_string must be the connection string (delete_old_slack_user_details).",
    )

    try:
        table_service_client = TableServiceClient.from_connection_string(
            conn_str=connection_string
        )
        table_client = table_service_client.get_table_client(table_name="slackusers")

        old_records = (datetime.now() - timedelta(hours=8)).strftime(
            "%Y-%m-%dT%H:%M:%S.%fZ"
        )

        rows = table_client.query_entities(f"Timestamp lt datetime'{old_records}'")
        counter = 0
        for row in rows:
            counter = counter + 1
            table_client.delete_entity("github.com", row["RowKey"])

        logger.info(f"Cleaned up {counter} entries.")

        return counter

    except HttpResponseError as e:
        handle_error(e)


@logging_wrapper
def delete_old_codefresh_user_details(connection_string):
    """
    We don't want to hold onto tokens for very long. Every hour or so keys older than 8 hours are purged from the database
    and users need to log in again.
    :param connection_string: The database connection string
    :return: The number of deleted records.
    """

    ensure_string_not_empty(
        connection_string,
        "connection_string must be the connection string (delete_old_codefresh_user_details).",
    )

    try:
        table_service_client = TableServiceClient.from_connection_string(
            conn_str=connection_string
        )
        table_client = table_service_client.get_table_client(table_name="codefreshusers")

        old_records = (datetime.now() - timedelta(hours=8)).strftime(
            "%Y-%m-%dT%H:%M:%S.%fZ"
        )

        rows = table_client.query_entities(f"Timestamp lt datetime'{old_records}'")
        counter = 0
        for row in rows:
            counter = counter + 1
            table_client.delete_entity("github.com", row["RowKey"])

        logger.info(f"Cleaned up {counter} entries.")

        return counter

    except HttpResponseError as e:
        handle_error(e)


@logging_wrapper
def delete_user_details(username, connection_string):
    """
    This function is effectively a logout
    :param username: The user to log out
    :param connection_string: The database connection string
    :return: The number of deleted records.
    """

    ensure_string_not_empty(
        username, "username must be the connection string (delete_user_details)."
    )
    ensure_string_not_empty(
        connection_string,
        "connection_string must be the connection string (delete_user_details).",
    )

    try:
        table_service_client = TableServiceClient.from_connection_string(
            conn_str=connection_string
        )
        table_client = table_service_client.get_table_client(table_name="users")
        table_client.delete_entity("github.com", username)

        logger.info(f"Logged out user {username}")

    except HttpResponseError as e:
        handle_error(e)


@logging_wrapper
def delete_slack_user_details(username, connection_string):
    """
    This function is effectively a logout from slack
    :param username: The user to log out
    :param connection_string: The database connection string
    :return: The number of deleted records.
    """
    try:
        table_service_client = TableServiceClient.from_connection_string(
            conn_str=connection_string
        )
        slack_table_client = table_service_client.get_table_client(
            table_name="slackusers"
        )

        slack_table_client.delete_entity("github.com", username)

        logger.info(f"Logged out user {username} from Slack")

    except HttpResponseError as e:
        handle_error(e)


@logging_wrapper
def delete_codefresh_user_details(username, connection_string):
    """
    This function is effectively a logout
    :param username: The user to log out
    :param connection_string: The database connection string
    :return: The number of deleted records.
    """

    ensure_string_not_empty(
        username, "username must be the connection string (delete_codefresh_user_details)."
    )
    ensure_string_not_empty(
        connection_string,
        "connection_string must be the connection string (delete_codefresh_user_details).",
    )

    try:
        table_service_client = TableServiceClient.from_connection_string(
            conn_str=connection_string
        )

        cf_table_client = table_service_client.get_table_client(table_name="codefreshusers")
        cf_table_client.delete_entity("github.com", username)

        logger.info(f"Logged out user {username}")

    except HttpResponseError as e:
        handle_error(e)


@logging_wrapper
def delete_all_user_details(connection_string):
    """
    Delete all user details.
    :param connection_string: The database connection string
    """

    ensure_string_not_empty(
        connection_string,
        "connection_string must be the connection string (delete_all_user_details).",
    )

    try:
        table_service_client = TableServiceClient.from_connection_string(
            conn_str=connection_string
        )
        table_service_client.delete_table("users")

    except HttpResponseError as e:
        handle_error(e)


@logging_wrapper
def delete_all_codefresh_user_details(connection_string):
    """
    Delete all users codefresh details.
    :param connection_string: The database connection string
    """

    ensure_string_not_empty(
        connection_string,
        "connection_string must be the connection string (delete_all_codefresh_user_details).",
    )

    try:
        table_service_client = TableServiceClient.from_connection_string(
            conn_str=connection_string
        )
        table_service_client.delete_table("codefreshusers")

    except HttpResponseError as e:
        handle_error(e)
