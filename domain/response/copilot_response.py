class CopilotResponse:
    """
    Represents a response to the Copilot platform. Responses include the response text, and optionally a prompt.
    """

    def __init__(self, response, prompt_title=None, prompt_message=None, prompt_id=None):
        self.response = response
        self.prompt_title = prompt_title
        self.prompt_message = prompt_message
        self.prompt_id = prompt_id
