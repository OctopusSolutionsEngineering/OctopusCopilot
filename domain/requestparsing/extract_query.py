import json

import azure.functions as func

from domain.errors.error_handling import handle_error


def extract_confirmation_state_and_id(req: func.HttpRequest):
    """
    Copilot responds to confirmations with the copilot_confirmations property. This looks like the following JSON:
    {
      "role": "user",
      "content": "",
      "copilot_references": null,
      "copilot_confirmations": [
        {
          "state": "accepted",
          "confirmation": {
            "id": "123"
          }
        }
      ]
    }
    :param req:
    :return:
    """
    body_raw = req.get_body()

    if not body_raw or not body_raw.strip():
        return None, None

    try:
        body = json.loads(body_raw)

        # This is the format supplied by copilot
        if 'messages' in body and len(body.get('messages')) != 0:
            # We don't care about the chat history, just the last message
            message = body.get('messages')[-1]
            if 'copilot_confirmations' in message:
                # This is an array
                confirmation_message = message.get('copilot_confirmations', [])

                # Make sure there is 1 confirmation
                if len(confirmation_message) == 0:
                    return None, None

                # We assume that we are only confirming one action at a time
                # Return the details of the last confirmation
                return (confirmation_message[:-1].get('state'),
                        confirmation_message[:-1].get('confirmation', {}).get('id'))
    except Exception as e:
        # Probably a malformed request. Just ignore it.
        handle_error(e)
        return None, None

    return None, None


def extract_query(req: func.HttpRequest):
    """
    Traditional web based SSE only supports GET requests, so testing the integration from a HTML form
    means making a GET request with the query as a parameter. Copilot makes POST requests with the
    query in the body. This functon extracts the query for both HTML forms and Copilot requests.
    :param req: The HTTP request
    :return: The query
    """

    # This is the query from a HTML form
    query = req.params.get("message")

    if query:
        return query.strip()

    body_raw = req.get_body()

    if not body_raw or not body_raw.strip():
        return ""

    try:
        body = json.loads(body_raw)

        # This is the format supplied by copilot
        if 'messages' in body and len(body.get('messages')) != 0:
            # We don't care about the chat history, just the last message
            message = body.get('messages')[-1]
            if 'content' in message:
                return message.get('content').strip()
    except Exception as e:
        # Probably a malformed request. Just ignore it.
        handle_error(e)
        return ""

    return ""
