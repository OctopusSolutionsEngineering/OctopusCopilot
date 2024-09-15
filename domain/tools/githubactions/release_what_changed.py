import asyncio

from domain.context.octopus_context import max_chars_128
from domain.lookup.octopus_multi_lookup import lookup_space_level_resources
from domain.messages.describe_deployment import build_deployment_overview_prompt
from domain.performance.timing import timing_wrapper
from domain.response.copilot_response import CopilotResponse
from domain.sanitizers.sanitized_list import update_query, get_item_or_none
from domain.tools.debug import get_params_message
from domain.transformers.deployments_from_release import get_deployments_for_project
from domain.transformers.limit_array import limit_array_to_max_char_length
from domain.url.github_urls import (
    extract_owner_repo_and_commit,
    extract_owner_repo_and_issue,
)
from infrastructure.github import (
    get_commit_diff_async,
    get_commit_async,
    get_issue_comments_async,
)
from infrastructure.octopus import get_task_details_async, activity_logs_to_string
from infrastructure.openai import llm_message_query


def release_what_changed_callback_wrapper(
    github_user, github_token, octopus_details, log_query
):
    async def release_what_changed_callback_async(
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

        if not deployments or not deployments.get("Deployments"):
            return CopilotResponse(
                "No deployments found for the space, project, environment, and tenant."
            )

        # We need to build up a bunch of async calls that we can then batch up
        diff_futures = []
        commit_futures = []
        workitems_futures = []
        task_log_future = get_task_details_async(
            space_resources["space_id"],
            deployments["Deployments"][0]["TaskId"],
            api_key,
            url,
        )

        # From the deployment, get the diffs and commit details
        for build_info in deployments["Deployments"][0]["BuildInformation"]:
            if build_info.get("Commits"):
                commit_details = [
                    extract_owner_repo_and_commit(commit["LinkUrl"])
                    for commit in build_info["Commits"]
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
        for build_info in deployments["Deployments"][0]["BuildInformation"]:
            if build_info.get("WorkItems"):
                workitems_details = [
                    extract_owner_repo_and_issue(workitem["LinkUrl"])
                    for workitem in build_info["WorkItems"]
                ]

                workitems_futures = [
                    get_issue_comments_async(
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
            return_exceptions=True,
        )

        # Get the list of people associated with the commits
        committers = [
            commit["commit"]["author"]["name"] for commit in external_context[1]
        ]

        # Get the raw logs
        logs = activity_logs_to_string(external_context[3]["ActivityLogs"])

        # Trim the context
        sources_with_data = (
            len(
                list(
                    filter(
                        lambda x: not isinstance(x, Exception) and len(x) != 0,
                        external_context,
                    )
                )
            )
            + 1
        )
        max_content_per_source = int(max_chars_128 / sources_with_data)

        diff_context = limit_array_to_max_char_length(
            external_context[0], max_content_per_source
        )

        issue_context = limit_array_to_max_char_length(
            external_context[2], max_content_per_source
        )

        log_context = logs[:max_content_per_source]

        # build the context sent to the LLM
        messages = build_deployment_overview_prompt(
            context=[
                *[
                    (
                        "system",
                        "Git Diff: ###\n"
                        + context.replace("{", "{{").replace("}", "}}")
                        + "\n###",
                    )
                    for context in diff_context
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
                    for context in issue_context
                ],
                (
                    "system",
                    "Deployment Logs: ###\n"
                    + log_context.replace("{", "{{").replace("}", "}}")
                    + "\n###",
                ),
            ]
        )

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
