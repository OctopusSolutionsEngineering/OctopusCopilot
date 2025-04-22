import unittest
import json
from domain.security.security import is_admin_server


class TestIsAdminServer(unittest.TestCase):

    def test_is_admin_server_with_valid_server(self):
        # Setup test data
        server = "https://admin.example.com/path"
        admin_servers_json = json.dumps(["admin.example.com", "another.admin.com"])

        # Test
        result = is_admin_server(server, admin_servers_json)

        # Assert
        self.assertTrue(result)

    def test_is_admin_server_with_invalid_server(self):
        # Setup test data
        server = "https://not-admin.example.com/path"
        admin_servers_json = json.dumps(["admin.example.com", "another.admin.com"])

        # Test
        result = is_admin_server(server, admin_servers_json)

        # Assert
        self.assertFalse(result)

    def test_is_admin_server_with_none_inputs(self):
        # Test with None server
        self.assertFalse(is_admin_server(None, json.dumps(["admin.example.com"])))

        # Test with None admin_servers_json
        self.assertFalse(is_admin_server("https://admin.example.com", None))

        # Test with both None
        self.assertFalse(is_admin_server(None, None))


if __name__ == "__main__":
    unittest.main()
