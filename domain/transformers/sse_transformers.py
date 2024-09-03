import json
import re

from domain.errors.error_handling import sanitize_message


def convert_to_sse_response(
    result, prompt_title=None, prompt_message=None, prompt_id=None
):
    """
    Converts a string to an SSE data only response. Optionally includes a confirmation prompt.
    :param result: The text to convert to an SSE stream
    :return: The SSE data only stream
    """

    if not result.strip():
        return build_stop_message() + "\n\n"

    content = build_output_messages(result)

    if prompt_title and prompt_message and prompt_id:
        # This is a standalone message that must be separated by two newlines
        content.append(
            "\n"
            + build_confirmation_event(prompt_title, prompt_message, prompt_id)
            + "\n"
        )

    content.append(build_stop_message())

    # https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events/Using_server-sent_events#data-only_messages
    # "Each notification is sent as a block of text terminated by a pair of newlines."
    return "\n".join(content) + "\n\n"


def convert_from_sse_response(sse_response):
    """
    Converts an SSE response into a string.
    :param sse_response: The SSE response to convert.
    :return: The string representation of the SSE response.
    """

    responses = map(
        lambda line: json.loads(line.replace("data: ", "")),
        filter(lambda line: line.strip(), sse_response.split("\n")),
    )
    content_responses = filter(
        lambda response: "content" in response["choices"][0]["delta"], responses
    )
    return "\n".join(
        map(
            lambda line: line["choices"][0]["delta"]["content"].strip(),
            content_responses,
        )
    )


def get_confirmation_id(sse_response):
    """
    Get the confirmation id from an SSE response.
    :param sse_response: The SSE response to get the confirmation id from.
    :return: The confirmation id.
    """
    responses = map(
        lambda line: json.loads(re.sub("^data:\\s*", "", line)),
        filter(lambda line: line.strip().startswith("data:"), sse_response.split("\n")),
    )
    confirmation_responses = filter(
        lambda response: response.get("type") == "action", responses
    )
    return next(
        map(
            lambda response: response["confirmation"]["id"],
            confirmation_responses,
        )
    )


def build_output_messages(message):
    return list(
        map(
            lambda line: "data: "
            + json.dumps(
                {
                    "choices": [
                        {
                            "index": 0,
                            "delta": {"content": sanitize_message(line) + "\n"},
                        }
                    ]
                }
            ),
            message.strip().split("\n"),
        )
    )


def build_stop_message():
    return "data: " + json.dumps(
        {"choices": [{"index": 0, "delta": {}, "finish_reason": "stop"}]}
    )


def build_confirmation_event(prompt_title, prompt_message, prompt_id):
    return (
        "event: copilot_confirmation\n"
        + "data: "
        + json.dumps(
            {
                "type": "action",
                "title": prompt_title,
                "message": prompt_message,
                "confirmation": {"id": prompt_id},
            }
        )
    )
