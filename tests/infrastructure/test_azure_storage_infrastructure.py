import unittest

from domain.featureflags.feature_flags import is_feature_enabled_for_github_user
from infrastructure.users import save_default_values, get_default_values, \
    save_users_octopus_url_from_login, get_users_details, delete_all_user_details, delete_old_user_details, \
    database_connection_test, delete_default_values, enable_feature_flag_for_user, is_feature_flagged_for_user, \
    disable_feature_flag_for_user, enable_feature_flag_for_group, is_feature_flagged_for_group, \
    disable_feature_flag_for_group, enable_feature_flag_for_all, is_feature_flagged_for_all, \
    disable_feature_flag_for_all, delete_user_details, save_users_codefresh_details_from_login, \
    get_users_codefresh_details, delete_all_codefresh_user_details, delete_old_codefresh_user_details, \
    delete_codefresh_user_details

connection_string = "DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;TableEndpoint=http://127.0.0.1:10002/devstoreaccount1;"


class UsersTest(unittest.TestCase):
    """
    Integration tests to ensure data can be saved and loaded from Azure Storage. These tests use
    Azurite to simulate the Azure Storage service locally. Run Azureite with:

    docker run -d -p 10000:10000 -p 10001:10001 -p 10002:10002 mcr.microsoft.com/azure-storage/azurite
    """

    def test_feature_flag_user(self):
        enable_feature_flag_for_user("testfeature", "testuser", connection_string)
        self.assertTrue(is_feature_flagged_for_user("testfeature", "testuser", connection_string))
        self.assertFalse(is_feature_flagged_for_user("testfeature", "anotheruser", connection_string))

        self.assertTrue(is_feature_enabled_for_github_user("testfeature", "testuser", [], connection_string))
        self.assertFalse(is_feature_enabled_for_github_user("testfeature", "anotheruser", [], connection_string))

        disable_feature_flag_for_user("testfeature", "testuser", connection_string)
        self.assertFalse(is_feature_flagged_for_user("testfeature", "testuser", connection_string))

        self.assertFalse(is_feature_flagged_for_user("unsetfeature", "testuser", connection_string))

    def test_feature_flag_group(self):
        enable_feature_flag_for_group("testgroupfeature", "testgroup", connection_string)
        self.assertTrue(is_feature_flagged_for_group("testgroupfeature", "testgroup", connection_string))
        self.assertFalse(is_feature_flagged_for_group("testgroupfeature", "anothergroup", connection_string))

        self.assertTrue(
            is_feature_enabled_for_github_user("testgroupfeature", "testuser", ["testgroup"], connection_string))
        self.assertFalse(
            is_feature_enabled_for_github_user("testgroupfeature", "testuser", ["anothergroup"], connection_string))

        disable_feature_flag_for_group("testgroupfeature", "testgroup", connection_string)
        self.assertFalse(is_feature_flagged_for_group("testgroupfeature", "testgroup", connection_string))

        self.assertFalse(is_feature_flagged_for_group("unsetfeature", "testgroup", connection_string))

    def test_feature_flag_global(self):
        enable_feature_flag_for_all("testallfeature", connection_string)
        self.assertTrue(is_feature_flagged_for_all("testallfeature", connection_string))
        self.assertTrue(
            is_feature_enabled_for_github_user("testallfeature", "testuser", ["testgroup"], connection_string))

        disable_feature_flag_for_all("testallfeature", connection_string)
        self.assertFalse(is_feature_flagged_for_all("testallfeature", connection_string))

        self.assertFalse(is_feature_flagged_for_all("unsetfeature", connection_string))

    def test_health(self):
        database_connection_test(connection_string)

    def test_default_values(self):
        save_default_values("test", "Space", "Default", connection_string)
        value = get_default_values("test", "Space", connection_string)

        self.assertEqual("Default", value)

    def test_delete_default_values(self):
        save_default_values("test", "Space", "Default", connection_string)
        delete_default_values("test", connection_string)
        value = get_default_values("test", "Space", connection_string)

        self.assertIsNone(value)

    def test_login(self):
        save_users_octopus_url_from_login("12345", "https://test.com", "API-ABCDEFG", "password", "salt",
                                          connection_string)
        user = get_users_details("12345", connection_string)

        self.assertTrue(user['OctopusUrl'])
        self.assertTrue(user['OctopusApiKey'])
        self.assertTrue(user['EncryptionTag'])
        self.assertTrue(user['EncryptionNonce'])

        delete_all_user_details(connection_string)

        with self.assertRaises(Exception):
            get_users_details("12345", connection_string)

        self.assertEqual(0, delete_old_user_details(connection_string))

    def test_logout(self):
        save_users_octopus_url_from_login("12345", "https://test.com", "API-ABCDEFG", "password", "salt",
                                          connection_string)
        user = get_users_details("12345", connection_string)

        self.assertTrue(user['OctopusUrl'])
        self.assertTrue(user['OctopusApiKey'])
        self.assertTrue(user['EncryptionTag'])
        self.assertTrue(user['EncryptionNonce'])

        delete_user_details("12345", connection_string)

        with self.assertRaises(Exception):
            get_users_details("12345", connection_string)

    def test_login_invalid_api(self):
        with self.assertRaises(ValueError):
            save_users_octopus_url_from_login("12345", "https://test.com", "invalid", "password", "salt",
                                              connection_string)

    def test_login_invalid_url(self):
        with self.assertRaises(ValueError):
            save_users_octopus_url_from_login("12345", "blah", "API-ABCDEFG", "password", "salt",
                                              connection_string)

    def test_codefresh_login(self):
        save_users_codefresh_details_from_login("12345", "000000000000000000000000.00000000000000000000000000000000",
                                                "password", "salt",
                                                connection_string)
        user = get_users_codefresh_details("12345", connection_string)

        self.assertTrue(user['CodefreshToken'])
        self.assertTrue(user['EncryptionTag'])
        self.assertTrue(user['EncryptionNonce'])

        delete_all_codefresh_user_details(connection_string)

        with self.assertRaises(Exception):
            get_users_codefresh_details("12345", connection_string)

        self.assertEqual(0, delete_old_codefresh_user_details(connection_string))

    def test_codefresh_logout(self):
        save_users_codefresh_details_from_login("12345", "000000000000000000000000.00000000000000000000000000000000",
                                                "password", "salt",
                                                connection_string)
        user = get_users_codefresh_details("12345", connection_string)

        self.assertTrue(user['CodefreshToken'])
        self.assertTrue(user['EncryptionTag'])
        self.assertTrue(user['EncryptionNonce'])

        delete_codefresh_user_details("12345", connection_string)

        with self.assertRaises(Exception):
            get_users_codefresh_details("12345", connection_string)

    def test_codefresh_login_invalid_token(self):
        with self.assertRaises(ValueError):
            save_users_codefresh_details_from_login("12345", "invalid", "password", "salt",
                                                    connection_string)
