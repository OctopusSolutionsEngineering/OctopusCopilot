from domain.response.copilot_response import CopilotResponse


def release_what_changed_callback_wrapper(github_user, octopus_details, log_query):
    def release_what_changed_callback(original_query, space, projects, release_version):
        return CopilotResponse("hi")
