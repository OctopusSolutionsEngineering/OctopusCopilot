import json

from domain.errors.error_handling import sanitize_message


def convert_to_sse_response(result):
    """
    Converts a string to an SSE data only response.
    :param result: The text to convert to an SSE stream
    :return: The SSE data only stream
    """

    stop = "data: " + json.dumps({"choices": [{"index": 0, "delta": {}, "finish_reason": "stop"}]})

    if not result.strip():
        return stop + "\n\n"

    # https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events/Using_server-sent_events#data-only_messages
    # "Each notification is sent as a block of text terminated by a pair of newlines."
    content = "\n".join(
        map(lambda l: "data: " + json.dumps(
            {"choices": [{"index": 0, "delta": {"content": sanitize_message(l) + "\n"}}]}),
            result.strip().split("\n")))

    return content + "\n" + stop + "\n\n"
