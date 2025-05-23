import hashlib
import unittest

from infrastructure.terraform_context import (
    cache_terraform,
    load_terraform_cache,
    load_terraform_context,
    save_terraform_context,
)

connection_string = "DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=http://127.0.0.1:10000/devstoreaccount1;QueueEndpoint=http://127.0.0.1:10001/devstoreaccount1;TableEndpoint=http://127.0.0.1:10002/devstoreaccount1;"


class TerraformTests(unittest.TestCase):
    """
    Integration tests to ensure data can be saved and loaded from Azure Storage. These tests use
    Azurite to simulate the Azure Storage service locally. Run Azurite with:

    docker run -d -p 10000:10000 -p 10001:10001 -p 10002:10002 --restart unless-stopped mcr.microsoft.com/azure-storage/azurite
    """

    def test_save_plan(self):
        sha = hashlib.sha256("test".encode("utf-8")).hexdigest()
        cache_terraform(sha, "template", connection_string)
        template = load_terraform_cache(sha, connection_string)

        self.assertEqual(template, "template")

    def test_load_context(self):
        save_terraform_context("example.tf", "template", connection_string)
        template = load_terraform_context("example.tf", connection_string)
        self.assertEqual(template, "template")
