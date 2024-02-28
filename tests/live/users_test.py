import re
import unittest

from infrastructure.users import save_default_values, get_default_values, save_login_uuid, delete_login_uuid, \
    save_users_octopus_url_from_login, get_users_details, delete_all_user_details, delete_old_user_details, \
    delete_old_user_login_records

connection_string = "DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;TableEndpoint=http://127.0.0.1:10002/devstoreaccount1;"


class UsersTest(unittest.TestCase):
    def test_default_values(self):
        save_default_values("test", "Space", "Default", connection_string)
        value = get_default_values("test", "Space", connection_string)

        self.assertEqual("Default", value)

    def test_save_uuid(self):
        uuid = save_login_uuid("test", connection_string)
        self.assertTrue(self.valid_uuid(uuid))
        delete_login_uuid(uuid, connection_string)

        with self.assertRaises(Exception):
            save_users_octopus_url_from_login(uuid, "https://test.com", "apikey", "password", "salt", connection_string)

        self.assertEqual(0, delete_old_user_login_records(connection_string))

    def test_login(self):
        uuid = save_login_uuid("test", connection_string)
        save_users_octopus_url_from_login(uuid, "https://test.com", "apikey", "password", "salt", connection_string)
        user = get_users_details("test", connection_string)

        self.assertTrue(user['OctopusUrl'])
        self.assertTrue(user['OctopusApiKey'])
        self.assertTrue(user['EncryptionTag'])
        self.assertTrue(user['EncryptionNonce'])

        delete_all_user_details(connection_string)

        with self.assertRaises(Exception):
            get_users_details("test", connection_string)

        self.assertEqual(0, delete_old_user_details(connection_string))

    def valid_uuid(self, uuid):
        regex = re.compile('^[a-f0-9]{8}-?[a-f0-9]{4}-?4[a-f0-9]{3}-?[89ab][a-f0-9]{3}-?[a-f0-9]{12}\Z', re.I)
        match = regex.match(uuid)
        return bool(match)
