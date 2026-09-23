import os
import unittest
from unittest import mock

from langchain_ollama import ChatOllama

from infrastructure.llm import OLLAMA_PROJECT_SERVICE, build_llm


class TestOllamaBuild(unittest.TestCase):
    """
    Pure build tests for the Ollama LLM.

    These construct the LLM and assert on its configuration, so they run without any
    network access to a running Ollama instance (unlike the MockRequests integration tests).
    """

    def test_default_builds_local_ollama(self):
        llm = build_llm(OLLAMA_PROJECT_SERVICE)

        self.assertIsInstance(llm, ChatOllama)
        self.assertEqual(llm.model, "qwen3.8:27b-mlx")
        self.assertEqual(llm.base_url, "http://localhost:11434")
        self.assertEqual(llm.num_ctx, 262144)
        self.assertEqual(llm.reasoning, "medium")

    def test_endpoint_env_honours_root_and_v1(self):
        for endpoint in ["http://10.0.0.5:11434/", "http://10.0.0.5:11434/v1"]:
            env = {"OLLAMA_ENDPOINT": endpoint, "OLLAMA_MODEL": "phi3"}
            with mock.patch.dict(os.environ, env):
                llm = build_llm(OLLAMA_PROJECT_SERVICE)

            self.assertEqual(llm.model, "phi3")
            self.assertEqual(llm.base_url, "http://10.0.0.5:11434")

    def test_context_length_env_override(self):
        with mock.patch.dict(os.environ, {"OLLAMA_CONTEXT_LENGTH": "32768"}):
            llm = build_llm(OLLAMA_PROJECT_SERVICE)

        self.assertEqual(llm.num_ctx, 32768)

    def test_reasoning_env_override(self):
        for value, expected in [
            ("high", "high"),
            ("True", True),
            ("false", False),
            ("None", None),
        ]:
            with mock.patch.dict(os.environ, {"OLLAMA_REASONING": value}):
                llm = build_llm(OLLAMA_PROJECT_SERVICE)

            self.assertEqual(llm.reasoning, expected)


if __name__ == "__main__":
    unittest.main()
