import asyncio

from domain.lookup.octopus_multi_lookup import lookup_space_level_resources
from domain.response.copilot_response import CopilotResponse
from infrastructure.octolint import run_octolint_check_async


def octolint_unused_projects_callback(octopus_details, github_user, original_query):
    def octolint_unused_projects(space):

        async def inner_function():
            check_name = "OctoLintUnusedProjects"

            api_key, url = octopus_details()

            space_resources = lookup_space_level_resources(
                url,
                api_key,
                github_user,
                original_query,
                space,
            )

            if not space_resources["space_id"]:
                return CopilotResponse(
                    "The name of the space to run the check in must be defined."
                )

            results = await run_octolint_check_async(
                api_key, url, space_resources["space_id"], check_name
            )

            wiki_page = f"Read the [documentation](https://github.com/OctopusSolutionsEngineering/OctopusRecommendationEngine/wiki/{check_name}) for more information."

            return CopilotResponse("\n\n".join([results, wiki_page]))

        return asyncio.run(inner_function())

    return octolint_unused_projects
