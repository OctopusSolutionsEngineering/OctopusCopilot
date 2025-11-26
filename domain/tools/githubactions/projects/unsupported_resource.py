from domain.response.copilot_response import CopilotResponse


def unsupported_resource(type="", *args, **kwargs):
    def inner_unsupported_resource():
        # This is just a passthrough to indicate unsupported resource creation
        return CopilotResponse(
            f"Creating this kind of resource ({type}) is not yet supported."
        )

    return inner_unsupported_resource
