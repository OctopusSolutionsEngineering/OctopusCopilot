import unittest

from infrastructure.callbacks import save_callback, load_callback, delete_callback, delete_old_callbacks

connection_string = "DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;TableEndpoint=http://127.0.0.1:10002/devstoreaccount1;"


class CallbackTests(unittest.TestCase):
    """
    Integration tests to ensure data can be saved and loaded from Azure Storage. These tests use
    Azurite to simulate the Azure Storage service locally. Run Azureite with:

    docker run -d -p 10000:10000 -p 10001:10001 -p 10002:10002 mcr.microsoft.com/azure-storage/azurite
    """

    def test_cleanup_function(self):
        save_callback("1234567", "testfunction", "123", "{}", "query", connection_string)
        delete_old_callbacks(0, connection_string)
        func_name, args, query = load_callback("1234567", "123", connection_string)

        self.assertIsNone(func_name)
        self.assertIsNone(args)
        self.assertIsNone(query)

    def test_save_load_function(self):
        save_callback("1234567", "testfunction", "123", "{}", "query", connection_string)
        func_name, args, query = load_callback("1234567", "123", connection_string)

        self.assertEqual("testfunction", func_name)
        self.assertEqual("{}", args)
        self.assertEqual("query", query)

    def test_save_delete_function(self):
        save_callback("1234567", "testfunction", "123", "{}", "query", connection_string)
        delete_callback("123", connection_string)
        func_name, args, query = load_callback("1234567", "123", connection_string)

        self.assertIsNone(func_name)
        self.assertIsNone(args)
        self.assertIsNone(query)

    def test_load_missing_function(self):
        delete_callback("xxx", connection_string)
        func_name, args, query = load_callback("1234567", "123", connection_string)

        self.assertIsNone(func_name)
        self.assertIsNone(args)
        self.assertIsNone(query)
