from domain.response.copilot_response import CopilotResponse


def suggest_solution_callback_wrapper():
    def suggest_solution_callback_implementation(query, keywords, answer):
        return CopilotResponse(answer)

    return suggest_solution_callback_implementation
