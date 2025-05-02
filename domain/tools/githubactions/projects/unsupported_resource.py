from domain.response.copilot_response import CopilotResponse


def unsupported_resource(*args, **kwargs):
    return CopilotResponse("Creating this kind of resource is not yet supported.")
