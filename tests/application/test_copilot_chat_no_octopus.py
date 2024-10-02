import os
import unittest

from openai import RateLimitError
from retry import retry

from domain.transformers.minify_strings import minify_strings
from domain.transformers.sse_transformers import convert_from_sse_response
from function_app import copilot_handler_internal
from infrastructure.users import save_default_values
from tests.application.test_copilot_chat import (
    build_no_octopus_request,
    build_no_octopus_encrypted_github_request,
)


class CopilotChatTest(unittest.TestCase):
    """
    Tests that do not rely on an Octopus instance.
    """

    def test_profile(self):
        github_user = os.environ["TEST_GH_USER"]
        save_default_values(
            github_user,
            "project",
            "Deploy Web App Container",
            os.environ["AzureWebJobsStorage"],
        )

        prompt = 'Save the profile named "MyTestProfile".'

        response = copilot_handler_internal(build_no_octopus_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        print(response_text)
        self.assertTrue(
            "saved profile" in response_text.casefold(), "Response was " + response_text
        )

        prompt = 'Load the profile named "MyTestProfile".'

        response = copilot_handler_internal(build_no_octopus_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        print(response_text)
        self.assertTrue(
            "loaded profile" in response_text.casefold(),
            "Response was " + response_text,
        )

        prompt = "List the profiles."

        response = copilot_handler_internal(build_no_octopus_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        print(response_text)
        self.assertTrue(
            "MyTestProfile" in response_text,
            "Response was " + response_text,
        )

    @retry(RateLimitError, tries=3, delay=2)
    def test_general_solution(self):
        prompt = minify_strings(
            """Suggest a solution for the following issue:

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
            """
        )
        response = copilot_handler_internal(build_no_octopus_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        # This response could be anything, but it should mention helm
        print(response_text)
        self.assertTrue(
            "helm" in response_text.casefold(), "Response was " + response_text
        )

    @retry(RateLimitError, tries=3, delay=2)
    def test_general_solution3(self):
        prompt = minify_strings(
            """Suggest a solution for the following issue:
Hello
 I am writing to you, because we are using Octopus for deployment between two sites, where we synchronize between the sites using custom scripts. We want to change the way we are working from the custom scripts
 to be using two instances of Octopus and the Space Cloner tool:
 GitHub - OctopusDeployLabs/SpaceCloner: A tool to clone/sync a space, project, and/or other items between different spaces in the same Octopus Deploy instances or spaces in different
 instances..
 We are, unfortunately, a little bit unsure about the future of the space cloner tool, will this be available and maintained in the future, or do you recommend using other tools going forward?
 Best wishes
 Jesper Rugård
This content is classified as Internal
Querying with solutions: https://octopusdeploy.slack.com/archives/C041XDRL04D/p1725354661479129
Hi Jesper,
As you’ve noted, Space Cloner has not been updated in some time, and is not likely to receive significant updates in future.
However, we have another tool that is well suited to cloning resources between spaces called Octoterra (https://github.com/OctopusSolutionsEngineering/OctopusTerraformExport).
Octoterra serialises an Octopus space to a Terraform module. The Terraform module can then be applied to a new space, effectively recreating (or cloning) the resources between spaces.
The documentation at https://octopus.com/docs/platform-engineering/managing-space-resources and https://octopus.com/docs/platform-engineering/managing-project-resources provides instructions and a sample video demonstrating the use of Octoterra.
However, there may be other solutions provided by the base Octopus platform that may also provide a solution. Are you provide some more information on the problem you are looking to solve by cloning resources between spaces?
Further details:
 Our current solution is based on two octopus installations that synchronize via custom scripts using Octopus Migrator – which is not supported anymore and keeping us from upgrading our octopus installations.
 We have a proposal for changing this that is based on introducing spaces, and using the space cloner for synchronizing between the environments. We currently have development, test, hosting test,
 staging and production environments. This dev and test environments are hosted at the developer company (DL) and the rest by the hosting company (UL). See the drawing below for a sketch of the proposed setup.
 Deployment process is thought as going like this:
The process for deploying to Staging/IntTest/Production, facilitated by the new setup, is described briefly below.
1.
Packages are built by Jenkins and pushed to UL-Octopus built-in NuGet-repo.
2.
UL uses Package Sync Export step at UL-Octopus to create an encrypted and signed zip.
3.
UL uses Package Sync Import step at DL-Octopus to import the NuGet-packages exported in 2).
4.
UL runs synchronization A, bringing UL-Octopus.Dev and DL-Octopus.Dev spaces into sync.
5.
DL performs a dry run of synchronization B. Changes are reviewed.
6.
If review is approved, DL attaches change-set listed in 3) to release-ticket, and performs the changes by running synchronization
 B.
7.
DL executes Release Tool to create releases in Production space.
8.
DL performs deployment according to ticket/release note.
 Best wishes
 Jesper
Thank you for providing that detailed information Jesper.
From your diagram, the hosting company Octopus instance (UL-Octopus) is where development work is performed. You then have the developer company Octopus instance (DL-Octopus) where production deployments take place. So, at a high level, the goal is to have a process that:
  Synchronises packages between the built-in feeds in UL-Octopus and DL-Octopus  Synchronises the UL-Octopus Dev space with the DL-Octopus Dev space  Synchronises the DL-Octopus Dev space with the DL-Octopus Production space after testing is performed
            """
        )
        response = copilot_handler_internal(build_no_octopus_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        # This response could be anything, but it should mention helm
        print(response_text)
        self.assertTrue(
            "cloner" in response_text.casefold(), "Response was " + response_text
        )

    @retry(RateLimitError, tries=3, delay=2)
    def test_general_solution_encrypted_token(self):
        """
        This test simulates passing encrypted github tokens like the web interface does.
        """
        prompt = minify_strings(
            """Suggest a solution for the following issue:

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
            """
        )
        response = copilot_handler_internal(
            build_no_octopus_encrypted_github_request(prompt)
        )
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        # This response could be anything, but it should mention helm
        print(response_text)
        self.assertTrue(
            "helm" in response_text.casefold(), "Response was " + response_text
        )

    @retry(RateLimitError, tries=3, delay=2)
    def test_general_solution2(self):
        prompt = minify_strings(
            """Suggest a solution for the following issue:
             Hi,
             We have a guardrail in our deployment process which checks whether the packages in the current version that is being deployed are different to the last successful release to that environment.
             If they are, we trigger a manual approval process.
             The challenge with this is, when this is expected and we approve this, if this project gets automatically triggered (which we want to happen every day), it triggers the manual approval each time.
             Is there a meta-argument or way to determine if the release is an auto-deploy that we can detect, and therefore ignore the package version check?
             Auto deploy triggered manual approval:
             Cheers,
             Chris
            """
        )
        response = copilot_handler_internal(build_no_octopus_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        # This response could be anything, but it should mention helm
        print(response_text)
        self.assertTrue(
            "approval" in response_text.casefold(), "Response was " + response_text
        )

    @retry(RateLimitError, tries=3, delay=2)
    def test_general_solution4(self):
        prompt = minify_strings(
            """Suggest a solution for the following issue: I have multiple tentacles shared between spaces. Are these tentacles counted as 1 item in the license, or does each tentacle count multiple times under the license?
            """
        )
        response = copilot_handler_internal(build_no_octopus_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        # This response could be anything, but it should mention tentacle
        print(response_text)
        self.assertTrue(
            "tentacle" in response_text.casefold(), "Response was " + response_text
        )

    @retry(RateLimitError, tries=3, delay=2)
    def test_general_solution5(self):
        prompt = minify_strings(
            """Suggest a solution for the following issue with the custom search queries "Helm", "Explicit Key Values", "transform":
            I have multiple tentacles shared between spaces. Are these tentacles counted as 1 item in the license, or does each tentacle count multiple times under the license?
            """
        )
        response = copilot_handler_internal(build_no_octopus_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        # This response could be anything, but it should mention tentacle
        print(response_text)
        self.assertIn("helm", response_text.casefold(), "Response was " + response_text)
        self.assertIn(
            "explicit key values",
            response_text.casefold(),
            "Response was " + response_text,
        )
        self.assertIn(
            "transform", response_text.casefold(), "Response was " + response_text
        )

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_sample_hcl(self):
        prompt = 'Generate a Terraform module with an environment called "Development", a project group called "Test", and a project called "Hello World" with a single Powershell script step that echoes the text "Hello World".'
        response = copilot_handler_internal(build_no_octopus_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertIn(
            'resource "octopusdeploy_environment"',
            response_text.casefold(),
            "Response was " + response_text,
        )
        self.assertIn(
            'resource "octopusdeploy_project_group"',
            response_text.casefold(),
            "Response was " + response_text,
        )
        self.assertIn(
            'resource "octopusdeploy_project"',
            response_text.casefold(),
            "Response was " + response_text,
        )
        self.assertIn(
            'resource "octopusdeploy_deployment_process"',
            response_text.casefold(),
            "Response was " + response_text,
        )
