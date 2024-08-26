from domain.response.copilot_response import CopilotResponse
from domain.tools.debug import get_params_message


def suggest_solution_callback_wrapper(github_user):
    def suggest_solution_callback_implementation(query, keywords, answer):
        response = [answer]

        response.extend(get_params_message(github_user, True,
                                           suggest_solution_callback_implementation.__name__,
                                           keywords=keywords))

        return CopilotResponse(answer)

    return suggest_solution_callback_implementation
