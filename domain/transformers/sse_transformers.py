import json


def convert_to_sse_response(result):
    """
    Converts a string to an SSE data only response.
    :param result: The text to convert to an SSE stream
    :return: The SSE data only stream
    """

    if not result:
        return ""

    # https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events/Using_server-sent_events#data-only_messages
    # "Each notification is sent as a block of text terminated by a pair of newlines."
    return "\n".join(
        map(lambda l: "data: " + json.dumps({"content": l, "role": "assistant"} + "\n"), result.split("\n"))) + "\n\n"
