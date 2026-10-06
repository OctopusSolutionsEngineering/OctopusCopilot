import os
import unittest
from unittest import mock

from langchain_openai import ChatOpenAI

from infrastructure.llm import OPENAI_PROJECT_SERVICE, build_llm


class TestOpenAIBuild(unittest.TestCase):
    """
    Pure build tests for the OpenAI LLM. These construct the LLM and assert on its configuration,
    so they run without network access.
    """

    def test_default_builds_public_openai(self):
        with mock.patch.dict(os.environ, {}, clear=True):
            llm = build_llm(OPENAI_PROJECT_SERVICE)

        self.assertIsInstance(llm, ChatOpenAI)
        self.assertEqual(llm.model_name, "gpt-5")
        self.assertEqual(llm.openai_api_base, "https://api.openai.com/v1")

    def test_endpoint_and_model_env_override(self):
        env = {
            "OPENAI_ENDPOINT": "http://10.0.0.5:8000/v1",
            "OPENAI_MODEL": "my-model",
            "OPENAI_API_KEY": "secret",
        }
        with mock.patch.dict(os.environ, env):
            llm = build_llm(OPENAI_PROJECT_SERVICE)

        self.assertEqual(llm.openai_api_base, "http://10.0.0.5:8000/v1")
        self.assertEqual(llm.model_name, "my-model")
        self.assertEqual(llm.openai_api_key.get_secret_value(), "secret")

    def test_temperature_env_override(self):
        with mock.patch.dict(os.environ, {"OPENAI_TEMPERATURE": "None"}):
            llm = build_llm(OPENAI_PROJECT_SERVICE)

        self.assertIsNone(llm.temperature)


if __name__ == "__main__":
    unittest.main()
