import json

from domain.config.openai import max_context
from domain.context.octopus_context import collect_llm_context
from domain.performance.timing import timing_wrapper
from domain.sanitizers.sanitized_list import (
    sanitize_list,
    get_item_or_none,
    sanitize_environments,
    sanitize_tenants,
)
from domain.transformers.deployments_from_release import get_deployments_for_project
from infrastructure.octopus import get_space_id_and_name_from_name, get_dashboard


def releases_query_cli_callback(api_key, url, get_default_argument, logging):
    def releases_query_callback_implementation(
        original_query,
        messages,
        space,
        projects,
        environments,
        channels,
        releases,
        tenants,
        dates,
    ):
        space = get_default_argument(space, "Space")

        context = {"input": original_query}

        space_id, actual_space_name = get_space_id_and_name_from_name(
            space, api_key, url
        )

        # We need some additional JSON data to answer this question
        if projects:
            # We only need the deployments, so strip out the rest of the JSON
            deployments = timing_wrapper(
                lambda: get_deployments_for_project(
                    space_id,
                    get_item_or_none(sanitize_list(projects), 0),
                    sanitize_environments(original_query, environments),
                    sanitize_tenants(tenants),
                    api_key,
                    url,
                    dates,
                    max_context,
                ),
                "Deployments",
            )
            context["json"] = json.dumps(deployments, indent=2)
        else:
            context["json"] = get_dashboard(space_id, api_key, url)

        chat_response = collect_llm_context(
            original_query,
            messages,
            context,
            space_id,
            projects,
            None,
            None,
            tenants,
            None,
            environments,
            None,
            None,
            None,
            None,
            None,
            None,
            None,
            None,
            channels,
            releases,
            None,
            None,
            dates,
            api_key,
            "",
            url,
            logging,
        )

        return chat_response

    return releases_query_callback_implementation
