import unittest

from openai import RateLimitError
from retry import retry

from domain.transformers.minify_strings import minify_strings
from domain.transformers.sse_transformers import convert_from_sse_response
from function_app import copilot_handler_internal
from tests.application.copilot_chat_test import build_request


class CopilotChatTest(unittest.TestCase):
    """
    Tests that do not rely on an Octopus instance.
    """

    @retry(RateLimitError, tries=3, delay=2)
    def test_general_solution(self):
        prompt = minify_strings("""Suggest a solution for the following issue:

            Hello Octopus Support,

            Today we discovered an interesting behavior, which does look like a bug, and would like to have some assistance on it.

            With one of our new projects we started observing Helm step failures – Octopus is unable to find values from the chart. For example, we have this deployment (done today in the morning):

            <URL>

            This project was previously set to get additional values from file in the chart (we have used this approach multiple times before, and it still works for other projects like <URL>), but for this one we were getting this error:

            Upon further investigation, I noticed two things:

                Projects that are working have no Octopus.Action[helm-upgrade].Helm.TemplateValuesSources system variable, but the one that is failing – does have it.
                Projects that are working have this line in logs: Unable to find values files at path `values.PPE.yaml`. Chart package contains root directory with chart name, so looking for values in there.

            So my current theory is that something changed in Helm step, and now there is no heuristic to find values like we had before, and thus new projects are failing (because working directory for the step is not the folder of the chart, but the staging area). I was able to get the project working by forcefully passing additional arguments (-f redpanda-wholesale-us\values.STAGING.yaml) and making it look directly in the chart folder, but that’s a workaround – we would prefer a proper fix from your side.

            You can log in to our instance to check things, but please revert any changes you do.
            """)
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode('utf8'))

        # This response could be anything, but it should mention helm
        print(response_text)
        self.assertTrue("helm" in response_text.casefold(), "Response was " + response_text)

    @retry(RateLimitError, tries=3, delay=2)
    def test_general_solution2(self):
        prompt = minify_strings("""Suggest a solution for the following issue:
             Hi,
             We have a guardrail in our deployment process which checks whether the packages in the current version that is being deployed are different to the last successful release to that environment. 
             If they are, we trigger a manual approval process.
             The challenge with this is, when this is expected and we approve this, if this project gets automatically triggered (which we want to happen every day), it triggers the manual approval each time. 
             Is there a meta-argument or way to determine if the release is an auto-deploy that we can detect, and therefore ignore the package version check? 
             Auto deploy triggered manual approval:
             Cheers,
             Chris
            """)
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode('utf8'))

        # This response could be anything, but it should mention helm
        print(response_text)
        self.assertTrue("approval" in response_text.casefold(), "Response was " + response_text)

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_sample_hcl(self):
        prompt = "Generate a Terraform module with an environment called \"Development\", a project group called \"Test\", and a project called \"Hello World\" with a single Powershell script step that echoes the text \"Hello World\"."
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode('utf8'))

        self.assertTrue('resource "octopusdeploy_environment"' in response_text.casefold(),
                        "Response was " + response_text)
        self.assertTrue('resource "octopusdeploy_project_group"' in response_text.casefold(),
                        "Response was " + response_text)
        self.assertTrue('resource "octopusdeploy_project"' in response_text.casefold(),
                        "Response was " + response_text)
        self.assertTrue('resource "octopusdeploy_deployment_process"' in response_text.casefold(),
                        "Response was " + response_text)
