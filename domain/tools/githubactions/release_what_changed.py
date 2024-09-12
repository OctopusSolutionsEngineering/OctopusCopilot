import asyncio

from domain.lookup.octopus_multi_lookup import lookup_space_level_resources
from domain.performance.timing import timing_wrapper
from domain.response.copilot_response import CopilotResponse
from domain.sanitizers.sanitized_list import update_query, get_item_or_none
from domain.tools.debug import get_params_message
from domain.transformers.deployments_from_release import get_deployments_for_project
from domain.url.github_urls import (
    extract_owner_repo_and_commit,
    extract_owner_repo_and_issue,
)
from infrastructure.github import get_commit_diff_async, get_commit_async
from infrastructure.octopus import get_task_details_async
from infrastructure.openai import llm_message_query


def release_what_changed_callback_wrapper(
    github_user, github_token, octopus_details, log_query
):
    async def release_what_changed_callback_async(
        messages,
        original_query,
        space,
        projects,
        environments,
        tenants,
        release_version,
    ):

        api_key, url = octopus_details()

        debug_text = get_params_message(
            github_user,
            True,
            release_what_changed_callback.__name__,
            space=space,
            projects=projects,
            release_version=release_version,
            environment=environments,
            tenant=tenants,
        )

        space_resources = lookup_space_level_resources(
            url,
            api_key,
            github_user,
            original_query,
            space,
            projects,
            environments,
            tenants,
        )

        if not space_resources["project_names"]:
            return CopilotResponse("Please specify a project name in the query.")

        if not space_resources["environment_names"]:
            return CopilotResponse("Please specify an environment name in the query.")

        debug_text.extend(
            get_params_message(
                github_user,
                False,
                release_what_changed_callback.__name__,
                space=space_resources["space_name"],
                projects=space_resources["projects"],
                release_version=release_version,
                environment=space_resources["environment_names"],
                tenant=space_resources["tenant_names"],
            )
        )

        processed_query = update_query(original_query, space_resources["projects"])
        context = {"input": processed_query}

        # Get the deployment. This is the root of all information we used to answer the prompt
        deployments = timing_wrapper(
            lambda: get_deployments_for_project(
                space_resources["space_id"],
                get_item_or_none(space_resources["project_names"], 0),
                get_item_or_none(space_resources["environment_names"], 0),
                get_item_or_none(space_resources["tenant_names"], 0),
                api_key,
                url,
                None,
                1,
                release_version,
            ),
            "Deployments",
        )

        if not deployments:
            return CopilotResponse(
                "No deployments found for the space, project, environment, and tenant."
            )

        # We need to build up a bunch of async calls that we can then batch up
        diff_futures = []
        commit_futures = []
        workitems_futures = []
        task_log_future = get_task_details_async(
            space_resources["space_id"], deployments[0]["TaskId"], api_key, url
        )

        # Get the task logs

        # From the deployment, get the diffs and commit details
        if deployments[0]["BuildInformation"].get("Commits"):
            commit_details = [
                extract_owner_repo_and_commit(commit["LinkUrl"])
                for commit in deployments[0]["BuildInformation"]["Commits"]
            ]

            diff_futures = [
                get_commit_diff_async(
                    commit_detail[0],
                    commit_detail[1],
                    commit_detail[2],
                    github_token,
                )
                for commit_detail in commit_details
            ]

            commit_futures = [
                get_commit_async(
                    commit_detail[0],
                    commit_detail[1],
                    commit_detail[2],
                    github_token,
                )
                for commit_detail in commit_details
                if commit_detail[0]
            ]

        # Get the details of any issues fixed
        if deployments[0]["BuildInformation"].get("WorkItems"):
            workitems_details = [
                extract_owner_repo_and_issue(commit["LinkUrl"])
                for commit in deployments[0]["BuildInformation"]["WorkItems"]
            ]

            workitems_futures = [
                get_commit_async(
                    workitems_details[0],
                    workitems_details[1],
                    workitems_details[2],
                    github_token,
                )
                for workitems_detail in workitems_details
                if workitems_detail[0]
            ]

        # Fire off all the external API calls
        external_context = await asyncio.gather(
            asyncio.gather(*diff_futures),
            asyncio.gather(*commit_futures),
            asyncio.gather(*workitems_futures),
            task_log_future,
        )

        # Get the list of people associated with the commits
        committers = [commit["author"]["name"] for commit in external_context[1]]

        # build the context sent to the LLM
        messages = [
            *[
                (
                    "system",
                    "Git Diff: ###\n"
                    + context.replace("{", "{{").replace("}", "}}")
                    + "\n###",
                )
                for context in external_context[0]
            ],
            (
                "system",
                "Git Committers: ###\n"
                + "\n".join(
                    committer.replace("{", "{{").replace("}", "}}")
                    for committer in committers
                )
                + "\n###",
            ),
            *[
                (
                    "system",
                    "Issue: ###\n"
                    + context.replace("{", "{{").replace("}", "}}")
                    + "\n###",
                )
                for context in external_context[3]
            ],
            (
                "system",
                "Deployment Logs: ###\n"
                + external_context[4].replace("{", "{{").replace("}", "}}")
                + "\n###",
            ),
            (
                "user",
                "Question: {input}",
            ),
            (
                "user",
                "Answer:",
            ),
        ]

        response = [llm_message_query(messages, context, log_query)]
        response.extend(space_resources["warnings"])
        response.extend(debug_text)

        return CopilotResponse("\n\n".join(response))

    def release_what_changed_callback(
        original_query, space, projects, environments, tenants, release_version
    ):
        """
        The async entrypoint for a tool called by the extension
        """
        return asyncio.run(
            release_what_changed_callback_async(
                original_query, space, projects, environments, tenants, release_version
            )
        )

    # Return the callback that in turns call the async function
    return release_what_changed_callback
