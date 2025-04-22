import os

from domain.config.database import get_functions_connection_string
from domain.config.storyblok import get_storyblok_token
from domain.config.zendesk import get_zendesk_user, get_zendesk_token
from domain.tools.githubactions.default_values import default_value_callbacks
from domain.tools.githubactions.generate_terraform import (
    generate_terraform_callback_wrapper,
)
from domain.tools.githubactions.projects.create_k8s_project import (
    create_k8s_project_confirm_callback_wrapper,
)
from domain.tools.githubactions.release_what_changed import (
    release_what_changed_callback_wrapper,
)
from domain.tools.githubactions.suggest_solution import (
    suggest_solution_callback_wrapper,
)
from domain.tools.wrapper.function_definition import (
    FunctionDefinitions,
    FunctionDefinition,
)
from domain.tools.wrapper.general_query import (
    answer_general_query_wrapper,
    AnswerGeneralQuery,
)
from domain.tools.wrapper.generate_terraform import generate_terraform_wrapper
from domain.tools.wrapper.how_to import how_to_wrapper
from domain.tools.wrapper.projects.create_k8s_project import create_k8s_project_wrapper
from domain.tools.wrapper.release_what_changed import release_what_changed_wrapper
from domain.tools.wrapper.suggest_solution import suggest_solution_wrapper
from tests.infrastructure.octopus_config import Octopus_Api_Key, Octopus_Url


def octopus_details():
    return Octopus_Api_Key, Octopus_Url


def log_query(query, message):
    print(f"Query: {query}, Message: {message}")


def general_query_handler(query, body, messages):
    return body


def how_to_callback(query, keywords):
    return query, keywords


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
    return {
        "original_query": original_query,
        "space": space,
        "projects": projects,
        "environments": environments,
        "tenants": tenants,
        "channel": channel,
        "release_version": release_version,
        "dates": dates,
    }


def build_mock_test_tools(tool_query):
    docs_functions = [
        FunctionDefinition(tool)
        for tool in how_to_wrapper(tool_query, how_to_callback, None)
    ]

    # Functions related to the default values
    (
        set_default_value,
        remove_default_value,
        get_default_value,
        get_all_default_values,
        save_defaults_as_profile,
        load_defaults_from_profile,
        list_profiles,
    ) = default_value_callbacks(lambda: "1234567", get_functions_connection_string())

    deployment_functions = [
        FunctionDefinition(tool)
        for tool in release_what_changed_wrapper(
            tool_query,
            release_what_changed_callback,
        )
    ]

    return FunctionDefinitions(
        [
            FunctionDefinition(
                answer_general_query_wrapper(tool_query, general_query_handler),
                AnswerGeneralQuery,
            ),
            FunctionDefinition(set_default_value),
            FunctionDefinition(get_default_value),
            FunctionDefinition(get_all_default_values),
            FunctionDefinition(remove_default_value),
            FunctionDefinition(
                suggest_solution_wrapper(
                    tool_query,
                    suggest_solution_callback_wrapper(os.environ["TEST_GH_USER"]),
                    True,
                    os.environ["TEST_GH_USER"],
                    os.environ["GH_TEST_TOKEN"],
                    get_zendesk_user(),
                    get_zendesk_token(),
                    os.environ.get("SLACK_TEST_TOKEN"),
                    get_storyblok_token(),
                    os.environ.get("ENCRYPTION_PASSWORD"),
                    os.environ.get("ENCRYPTION_SALT"),
                )
            ),
            FunctionDefinition(
                generate_terraform_wrapper(
                    tool_query,
                    generate_terraform_callback_wrapper(),
                    os.environ["GH_TEST_TOKEN"],
                )
            ),
            FunctionDefinition(
                create_k8s_project_wrapper(
                    tool_query,
                    create_k8s_project_confirm_callback_wrapper(
                        os.environ["TEST_GH_USER"],
                        octopus_details,
                        log_query,
                        None,
                        None,
                    ),
                    log_query,
                )
            ),
            *deployment_functions,
        ],
        fallback=FunctionDefinitions(docs_functions),
    )
