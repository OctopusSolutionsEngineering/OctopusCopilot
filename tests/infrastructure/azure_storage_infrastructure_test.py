import unittest

from infrastructure.users import save_default_values, get_default_values, \
    save_users_octopus_url_from_login, get_users_details, delete_all_user_details, delete_old_user_details

connection_string = "DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;TableEndpoint=http://127.0.0.1:10002/devstoreaccount1;"


class UsersTest(unittest.TestCase):
    """
    Integration tests to ensure data can be saved and loaded from Azure Storage. These tests use
    Azurite to simulate the Azure Storage service locally. Run Azureite with:
    
    docker run -d -p 10000:10000 -p 10001:10001 -p 10002:10002 mcr.microsoft.com/azure-storage/azurite
    """

    def test_default_values(self):
        save_default_values("test", "Space", "Default", connection_string)
        value = get_default_values("test", "Space", connection_string)

        self.assertEqual("Default", value)

    def test_login(self):
        save_users_octopus_url_from_login("12345", "https://test.com", "apikey", "password", "salt", connection_string)
        user = get_users_details("12345", connection_string)

        self.assertTrue(user['OctopusUrl'])
        self.assertTrue(user['OctopusApiKey'])
        self.assertTrue(user['EncryptionTag'])
        self.assertTrue(user['EncryptionNonce'])

        delete_all_user_details(connection_string)

        with self.assertRaises(Exception):
            get_users_details("test", connection_string)

        self.assertEqual(0, delete_old_user_details(connection_string))
