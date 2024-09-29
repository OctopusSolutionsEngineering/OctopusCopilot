import unittest

from langchain_core.prompts import ChatPromptTemplate

from domain.messages.deployment_logs import build_plain_text_prompt
from domain.messages.deployments_and_releases import build_deployments_and_releases_prompt
from domain.messages.general import build_hcl_prompt


class PromptTest(unittest.TestCase):
    def test_hcl_prompt(self):
        """
        Make sure the messages can be formatted into a prompt with the question and some hcl
        :return:
        """
        messages = build_hcl_prompt()
        template = ChatPromptTemplate.from_messages(messages)
        template.format_messages(
            hcl="hcl_context",
            input="What is your name?"
        )

    def test_plain_text_prompt(self):
        """
        Make sure the messages can be formatted into a prompt with the question and some text
        :return:
        """
        messages = build_plain_text_prompt()
        template = ChatPromptTemplate.from_messages(messages)
        template.format_messages(
            context="hcl_context",
            input="What is your name?"
        )

    def test_build_deployments_and_releases_prompt(self):
        """
        Make sure the messages can be formatted into a prompt with the question and some text
        :return:
        """
        messages = build_deployments_and_releases_prompt()
        template = ChatPromptTemplate.from_messages(messages)
        template.format_messages(
            hcl="hcl_context",
            json="json_context",
            input="What is your name?"
        )
