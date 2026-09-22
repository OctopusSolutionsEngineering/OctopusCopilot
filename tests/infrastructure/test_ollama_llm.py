import os
import unittest
from unittest import mock

from langchain_openai import ChatOpenAI

from infrastructure.llm import AZURE_PROJECT_OLLAMA_SERVICE, build_llm


def _api_key_value(llm):
    api_key = llm.openai_api_key
    if hasattr(api_key, "get_secret_value"):
        return api_key.get_secret_value()
    return api_key


class TestOllamaBuild(unittest.TestCase):
    """
    Pure build tests for the Ollama LLM.

    These construct the LLM and assert on its configuration, so they run without any
    network access to a running Ollama instance (unlike the MockRequests integration tests).
    """

    def test_default_builds_local_ollama(self):
        llm = build_llm(AZURE_PROJECT_OLLAMA_SERVICE)

        self.assertIsInstance(llm, ChatOpenAI)
        self.assertEqual(llm.model_name, "qwen3.8:27b-mlx")
        base_url = str(llm.openai_api_base)
        self.assertIn("localhost:11434", base_url)
        self.assertTrue(base_url.endswith("/v1"))
        self.assertEqual(_api_key_value(llm), "ollama")

    def test_endpoint_env_honours_root_and_v1(self):
        env = {"OLLAMA_ENDPOINT": "http://10.0.0.5:11434/", "OLLAMA_MODEL": "phi3"}
        with mock.patch.dict(os.environ, env):
            llm = build_llm(AZURE_PROJECT_OLLAMA_SERVICE)

        self.assertEqual(llm.model_name, "phi3")
        base_url = str(llm.openai_api_base)
        self.assertIn("10.0.0.5:11434", base_url)
        self.assertTrue(base_url.endswith("/v1"))

    def test_api_key_env_override(self):
        with mock.patch.dict(os.environ, {"OLLAMA_API_KEY": "secret"}):
            llm = build_llm(AZURE_PROJECT_OLLAMA_SERVICE)

        self.assertEqual(_api_key_value(llm), "secret")


if __name__ == "__main__":
    unittest.main()
