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
        map(lambda line: "data: " + json.dumps(
            {"choices": [{"index": 0, "delta": {"content": sanitize_message(line) + "\n"}}]}),
            result.strip().split("\n")))

    return content + "\n" + stop + "\n\n"


def convert_from_sse_response(sse_response):
    """
    Converts an SSE response into a string.
    :param sse_response: The SSE response to convert.
    :return: The string representation of the SSE response.
    """

    responses = map(lambda line: json.loads(line.replace("data: ", "")),
                    filter(lambda line: line.strip(), sse_response.split("\n")))
    content_responses = filter(lambda response: "content" in response["choices"][0]["delta"], responses)
    return "\n".join(map(lambda line: line["choices"][0]["delta"]["content"].strip(), content_responses))
