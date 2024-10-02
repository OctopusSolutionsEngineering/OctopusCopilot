import asyncio
import json

from domain.categorization.octopus_target import (
    project_includes_azure_steps,
    project_includes_aws_steps,
    project_includes_gcp_steps,
    project_includes_windows_steps,
    has_unknown_steps,
)
from domain.context.octopus_context import max_chars_128
from domain.counters.counters import count_items_with_data
from domain.lookup.octopus_multi_lookup import lookup_space_level_resources
from domain.messages.describe_deployment import build_deployment_overview_prompt
from domain.nlp.nlp import nlp_get_keywords
from domain.performance.timing import timing_wrapper
from domain.response.copilot_response import CopilotResponse
from domain.sanitizers.sanitize_strings import strip_leading_whitespace
from domain.sanitizers.sanitized_list import (
    update_query,
    get_item_or_none,
    sanitize_dates,
    sanitize_channels,
    get_item_or_default,
)
from domain.tools.debug import get_params_message
from domain.transformers.deployments_from_release import get_deployments_for_project
from domain.transformers.limit_array import (
    limit_array_to_max_char_length,
    limit_array_to_max_items,
    limit_text_in_array,
    array_or_empty_if_exception,
    object_or_default_if_exception,
)
from domain.transformers.text_to_context import (
    get_context_from_text_array,
    get_context_from_string,
)
from domain.url.github_urls import (
    extract_owner_repo_and_commit,
    extract_owner_repo_and_issue,
)
from infrastructure.github import (
    get_commit_diff_async,
    get_commit_async,
    get_issue_comments_async,
    get_issues_comments,
    get_issues,
)
from infrastructure.octopus import (
    get_task_details_async,
    activity_logs_to_string,
    get_failed_step,
)
from infrastructure.octoterra import get_octoterra_space_async
from infrastructure.openai import llm_message_query
from infrastructure.zendesk import get_tickets_comments, get_tickets

max_issues = 10


def release_what_changed_callback_wrapper(
    is_admin,
    github_user,
    github_token,
    zendesk_user,
    zendesk_token,
    octopus_details,
    log_query,
):
    async def release_what_changed_callback_async(
        original_query,
        space,
        projects,
        environments,
        tenants,
        channel,
        release_version,
        dates,
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
            channel=channel,
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
                sanitize_dates(dates),
                1,
                release_version,
                sanitize_channels(channel),
            ),
            "Deployments",
        )

        if not deployments or not deployments.get("Deployments"):
            return CopilotResponse(
                "No deployments found for the space, project, environment, and tenant."
            )

        # We need to build up a bunch of async calls that we can then batch up
        diff_futures, commit_futures = get_commit_futures(deployments)
        workitems_futures = get_workitem_futures(deployments)
        task_log_future = get_task_details_async(
            space_resources["space_id"],
            deployments["Deployments"][0]["TaskId"],
            api_key,
            url,
        )

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
            commit["commit"]["author"]["name"]
            for commit in array_or_empty_if_exception(external_context[1])
        ]

        # Get the raw logs
        logs = activity_logs_to_string(
            object_or_default_if_exception(external_context[3], {}).get("ActivityLogs")
        )

        # Get the name of the failed step
        failed_step = get_failed_step(
            object_or_default_if_exception(external_context[3], {}).get("ActivityLogs")
        )

        # If the deployment failed, get the keywords and search for tickets and issues
        failure_context, keywords = await get_failure_context(
            original_query, space_resources, failed_step, deployments, logs
        )

        debug_text.extend(
            get_params_message(
                github_user,
                False,
                release_what_changed_callback.__name__,
                space=space_resources["space_name"],
                projects=space_resources["project_names"],
                release_version=release_version,
                environment=space_resources["environment_names"],
                tenant=space_resources["tenant_names"],
                channel=channel,
                keywords=keywords,
            )
        )

        # Trim the context
        sources_with_data = (
            count_items_with_data(external_context)
            + count_items_with_data(failure_context)
            + 1
        )
        max_content_per_source = int(max_chars_128 / sources_with_data)

        # We limit the overall length of all the items in the content to their own content window size,
        # but also limit the length of any individual item to the max_content_per_source. This means
        # that we can at least get some context from each source, even if it's not the full context.

        diff_context = limit_array_to_max_char_length(
            limit_text_in_array(
                array_or_empty_if_exception(external_context[0]), max_content_per_source
            ),
            max_content_per_source,
        )

        issue_context = limit_array_to_max_char_length(
            limit_text_in_array(
                array_or_empty_if_exception(external_context[2]), max_content_per_source
            ),
            max_content_per_source,
        )

        support_ticket_context = limit_array_to_max_char_length(
            limit_text_in_array(
                array_or_empty_if_exception(get_item_or_none(failure_context, 0)),
                max_content_per_source,
            ),
            max_content_per_source,
        )

        support_issue_context = limit_array_to_max_char_length(
            limit_text_in_array(
                array_or_empty_if_exception(get_item_or_none(failure_context, 1)),
                max_content_per_source,
            ),
            max_content_per_source,
        )

        octoterra_context = object_or_default_if_exception(
            get_item_or_default(failure_context, 2, ""), ""
        )[-max_content_per_source:]

        # Limit the logs, and trim the start if required.
        # This is because any errors are important and those will be towards the end of the logs.
        log_context = logs[-max_content_per_source:]

        # build the context sent to the LLM
        messages = build_deployment_overview_prompt(
            context=[
                *get_context_from_string(
                    octoterra_context, "Octopus Project Terraform Configuration"
                ),
                *get_context_from_text_array(diff_context, "Deployment Git Diff"),
                *get_context_from_text_array(issue_context, "Deployment Issue"),
                *get_context_from_text_array(
                    support_ticket_context, "General Support Ticket"
                ),
                *get_context_from_text_array(support_issue_context, "General Issue"),
                *get_context_from_string(log_context, "Deployment Logs"),
                *get_context_from_string("\n".join(committers), "Git Committers"),
                *get_context_from_string(
                    json.dumps(deployments["Deployments"][0]), "Deployment JSON"
                ),
                *(
                    [
                        (
                            "system",
                            'The supplied "Octopus Project Terraform Configuration" context is the Terraform representation of the Octopus project that was deployed.',
                        )
                    ]
                    if octoterra_context
                    else []
                ),
                *(
                    [
                        (
                            "system",
                            'The supplied "Deployment Git Diff" context lists the git diffs included in the deployment.',
                        )
                    ]
                    if diff_context
                    else []
                ),
                *(
                    [
                        (
                            "system",
                            'The supplied "Deployment Issue" context lists the issues resolved by the deployment.',
                        )
                    ]
                    if issue_context
                    else []
                ),
                (
                    "system",
                    'The supplied "Git Committers" context lists the developers who contributed to the deployment.',
                ),
                (
                    "system",
                    'The supplied "Deployment Logs" context provides the Octopus deployment logs.',
                ),
                (
                    "system",
                    'The supplied "Deployment JSON" context provides details about the Octopus deployment.',
                ),
                *(
                    [
                        (
                            "system",
                            strip_leading_whitespace(
                                """The supplied "General Support Ticket" context relates to previous help desk tickets that may relate to the errors seen in the deployment logs.
                                Any personally identifiable information in the general support tickets has been removed and replace with placeholders.
                                The placeholders must be ignored and not used in the response."""
                            ),
                        ),
                        (
                            "system",
                            'The supplied "General Issue" context relates to previous issues that may relate to the errors seen in the deployment logs.',
                        ),
                        (
                            "system",
                            """The supplied "Octopus Project Terraform Configuration" context includes the configuration of the step that failed in the deployment.
                            The step retry feature is enabled if the step's action has the Octopus.Action.AutoRetry.MaximumCount property set greater than 0.
                            The step retry feature is enabled on the step via the Octopus web portal by checking the "Allow reties" option in the "Retries" section in the "Conditions" group.
                            You will be penalized if you mention the Octopus.Action.AutoRetry.MaximumCount property directly.
                            If the issue is related to an intermittent failure, you must suggest the step retry feature if it is not already enabled.
                            If the step runs a script, you must inspect the script and provide an example script that may resolve the issue.""",
                        ),
                        (
                            "system",
                            strip_leading_whitespace(
                                """You must list any relevant solutions or suggestions relating to the errors in the "Deployment Logs" from the "General Support Ticket" and "General Issue" context.
                                You will be penalized if you do not include this information in your response."""
                            ),
                        ),
                        *(
                            [
                                (
                                    "system",
                                    strip_leading_whitespace(
                                        """You must assume that the deployment was to the Azure cloud provider.
                                        You must suggest a solution to the errors in the "Deployment Logs" context that prevented the deployment from succeeding.
                                        You must pay attention to specific error messages, file names, and line numbers in the error.
                                        """
                                    ),
                                )
                            ]
                            if project_includes_azure_steps(octoterra_context)
                            else []
                        ),
                        *(
                            [
                                (
                                    "system",
                                    strip_leading_whitespace(
                                        """You must assume that the deployment was to the AWS cloud provider.
                                        You must suggest a solution to the errors in the "Deployment Logs" context that prevented the deployment from succeeding.
                                        You must pay attention to specific error messages, file names, and line numbers in the error.
                                        """
                                    ),
                                )
                            ]
                            if project_includes_aws_steps(octoterra_context)
                            else []
                        ),
                        *(
                            [
                                (
                                    "system",
                                    strip_leading_whitespace(
                                        """You must assume that the deployment was to the Google cloud provider.
                                        You must suggest a solution to the errors in the "Deployment Logs" context that prevented the deployment from succeeding.
                                        You must pay attention to specific error messages, file names, and line numbers in the error.
                                        """
                                    ),
                                )
                            ]
                            if project_includes_gcp_steps(octoterra_context)
                            else []
                        ),
                        *(
                            [
                                (
                                    "system",
                                    strip_leading_whitespace(
                                        """You must assume that the deployment was to a Windows server.
                                        You must suggest a solution to the errors in the "Deployment Logs" context that prevented the deployment from succeeding.
                                        You must pay attention to specific error messages, file names, and line numbers in the error.
                                        """
                                    ),
                                )
                            ]
                            if project_includes_windows_steps(octoterra_context)
                            else []
                        ),
                        *(
                            [
                                (
                                    "system",
                                    strip_leading_whitespace(
                                        """You must suggest a solution to the last error in the "Deployment Logs" context that prevented the deployment from succeeding.
                                        You must pay attention to specific error messages, file names, and line numbers in the logs."""
                                    ),
                                )
                            ]
                            if has_unknown_steps(octoterra_context)
                            else []
                        ),
                    ]
                    if deployment_is_failure(deployments)
                    else []
                ),
            ],
            default_output=[
                (
                    "system",
                    strip_leading_whitespace(
                        """If the user does not ask for specific information you must provide a list of the "Git Committers".
                        You will be penalized for including the list of "Git Committers" in the response if the user asks for specific information."""
                    ),
                ),
                *(
                    [
                        (
                            "system",
                            strip_leading_whitespace(
                                """If the user does not ask for specific information you must list each file from the "Deployment Git Diff" and provide a summary of the changes.
                                You will be penalized for including the "Deployment Git Diff" in the response if the user asks for specific information."""
                            ),
                        )
                    ]
                    if diff_context
                    else []
                ),
                *(
                    [
                        (
                            "system",
                            strip_leading_whitespace(
                                """If the user does not ask for specific information you must provide a summary of the "Deployment Issue" in the response.
                                You will be penalized for including the "Deployment Issue" in the response if the user asks for specific information."""
                            ),
                        )
                    ]
                    if issue_context
                    else []
                ),
                (
                    "system",
                    strip_leading_whitespace(
                        """If the user does not ask for specific information you must provide a summary of the "Deployment Logs" in the response.
                        You will be penalized for including the "Deployment Logs" in the response if the user asks for specific information."""
                    ),
                ),
                (
                    "system",
                    strip_leading_whitespace(
                        """If the user does not ask for specific information you must provide a summary of the "Deployment JSON" in the response.
                        You will be penalized for including the "Deployment JSON" in the response if the user asks for specific information.
                        You will be penalized if you print the JSON literally."""
                    ),
                ),
            ],
        )

        response = [llm_message_query(messages, context, log_query)]
        response.extend(space_resources["warnings"])
        response.extend(debug_text)

        return CopilotResponse("\n\n".join(response))

    def release_what_changed_callback(
        original_query,
        space,
        projects,
        environments,
        tenants,
        channel,
        release_version,
        dates,
    ):
        """
        The async entrypoint for a tool called by the extension
        """
        return asyncio.run(
            release_what_changed_callback_async(
                original_query,
                space,
                projects,
                environments,
                tenants,
                channel,
                release_version,
                dates,
            )
        )

    def get_commit_futures(deployments):
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
                    if commit_detail[0]
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

                return diff_futures, commit_futures

        return [], []

    def get_workitem_futures(deployments):
        # Get the details of any issues fixed
        for build_info in deployments["Deployments"][0]["BuildInformation"]:
            if build_info.get("WorkItems"):
                workitems_details = [
                    extract_owner_repo_and_issue(workitem["LinkUrl"])
                    for workitem in build_info["WorkItems"]
                ]

                return [
                    get_issue_comments_async(
                        workitems_details[0],
                        workitems_details[1],
                        workitems_details[2],
                        github_token,
                    )
                    for workitems_detail in workitems_details
                    if workitems_detail[0]
                ]

        return []

    async def get_failure_context(
        original_query, space_resources, failed_step, deployments, logs
    ):
        api_key, url = octopus_details()

        if deployment_is_failure(deployments):
            keywords = nlp_get_keywords(logs[:max_chars_128])
            initial_search = await asyncio.gather(
                get_tickets(is_admin, keywords, None, zendesk_user, zendesk_token),
                get_issues(keywords, github_token),
                return_exceptions=True,
            )

            return (
                await asyncio.gather(
                    get_tickets_comments(
                        limit_array_to_max_items(
                            array_or_empty_if_exception(initial_search[0]), max_issues
                        ),
                        zendesk_user,
                        zendesk_token,
                    ),
                    get_issues_comments(
                        limit_array_to_max_items(
                            array_or_empty_if_exception(initial_search[1]), max_issues
                        ),
                        github_token,
                    ),
                    get_octoterra_space_async(
                        api_key,
                        url,
                        original_query,
                        space_resources["space_id"],
                        project_names=get_item_or_none(
                            space_resources["project_names"], 0
                        ),
                        step_names=[failed_step or "<all>"],
                        max_attribute_length=10000,
                    ),
                    return_exceptions=True,
                ),
                keywords,
            )

        return [], None

    def deployment_is_failure(deployments):
        return deployments["Deployments"][0]["TaskState"] == "Failed"

    # Return the callback that in turns call the async function
    return release_what_changed_callback
