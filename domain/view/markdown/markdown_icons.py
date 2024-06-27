def get_github_state_icon(status, conclusion):
    # https://github.com/github/rest-api-description/issues/1634
    # Value of the status property can be one of: “queued”, “in_progress”, or “completed”.
    # When it’s “completed,” it makes sense to check if it finished successfully.
    # We need a value of the conclusion property.
    # Can be one of the “success”, “failure”, “neutral”, “cancelled”, “skipped”, “timed_out”, or “action_required”.

    if status == "in_progress":
        return "🔵"

    elif status == "queued":
        return "🟣"

    # status of completed is assumed from this point down, and we're displaying the conclusion

    if conclusion == "success":
        return "🟢"

    elif conclusion == "failure" or conclusion == "timed_out":
        return "🔴"

    elif conclusion == "action_required":
        return "🟠"

    elif conclusion == "cancelled" or conclusion == "neutral" or conclusion == "skipped":
        return "⚪"

    return "⚪"


def get_state_icon(state, has_warnings):
    if state == "Executing":
        return "🔵"

    if state == "Success":
        if has_warnings:
            return "🟡"
        else:
            return "🟢"

    elif state == "Failed":
        return "🔴"

    if state == "Canceled":
        return "⚪"

    elif state == "TimedOut":
        return "🔴"

    elif state == "Cancelling":
        return "🔴"

    elif state == "Queued":
        return "🟣"

    return "⚪"


def get_activity_log_state_icon(state):
    if state == "Running":
        return "🔵"

    if state == "SuccessWithWarning":
        return "🟡"

    if state == "Success":
        return "🟢"

    elif state == "Failed":
        return "🔴"

    if state == "Canceled":
        return "⚪"

    elif state == "TimedOut":
        return "🔴"

    elif state == "Cancelling":
        return "🔴"

    elif state == "Queued":
        return "🟣"

    return "⚪"
