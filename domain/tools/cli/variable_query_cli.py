from domain.context.octopus_context import collect_llm_context
from domain.sanitizers.sanitized_list import none_if_falesy_or_all
from infrastructure.octopus import get_space_id_and_name_from_name


def variable_query_cli_callback(api_key, url, get_default_argument, logging):
    def variable_query_cli_callback_implementation(original_query, messages, space, projects, variables):
        space = get_default_argument(space, 'Space')

        context = {"input": original_query}

        space_id, actual_space_name = get_space_id_and_name_from_name(space, api_key, url)

        chat_response = collect_llm_context(original_query,
                                            messages,
                                            context,
                                            space_id,
                                            projects,
                                            None,
                                            None,
                                            None,
                                            None,
                                            None,
                                            None,
                                            None,
                                            None,
                                            None,
                                            None,
                                            None,
                                            None,
                                            None,
                                            None,
                                            None,
                                            None,
                                            ["<all>"] if none_if_falesy_or_all(variables) else variables,
                                            None,
                                            api_key,
                                            url,
                                            logging)

        return chat_response

    return variable_query_cli_callback_implementation
