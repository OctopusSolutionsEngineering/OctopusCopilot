from domain.context.octopus_context import collect_llm_context
from domain.sanitizers.sanitized_list import none_if_falesy_or_all
from infrastructure.octopus import get_space_id_and_name_from_name


def resource_specific_cli_callback(api_key, url, get_default_argument, logging):
    def resource_specific_callback_implementation(original_query, messages, space, projects, runbooks, targets,
                                                  tenants, environments, accounts, certificates, workerpools,
                                                  machinepolicies, tagsets,
                                                  steps):
        space = get_default_argument(space, 'Space')

        context = {"input": original_query}

        space_id, actual_space_name = get_space_id_and_name_from_name(space, api_key, url)

        return collect_llm_context(original_query,
                                   messages,
                                   context,
                                   space_id,
                                   projects,
                                   runbooks,
                                   targets,
                                   tenants,
                                   None,
                                   ["<all>"] if none_if_falesy_or_all(environments) else environments,
                                   None,
                                   accounts,
                                   certificates,
                                   None,
                                   workerpools,
                                   machinepolicies,
                                   tagsets,
                                   None,
                                   None,
                                   None,
                                   steps,
                                   None,
                                   None,
                                   api_key,
                                   url,
                                   logging)

    return resource_specific_callback_implementation
