from functools import reduce

from domain.defaults.defaults import get_default_argument
from domain.sanitizers.sanitize_strings import to_lower_case_or_none


def get_params_message(github_user, start, function_name, **kwargs):
    # Debug mode shows the entities extracted from the query
    debug = get_default_argument(github_user, None, "Debug")
    if not to_lower_case_or_none(debug) == "true":
        return []

    response = ["### Debug"] if start else []
    response.extend(get_params(start, function_name, **kwargs))

    return response


def get_params(start, function_name, **kwargs):
    return [
        reduce(
            lambda x, y: x + f"\n* {y[0]}: {y[1]}",
            kwargs.items(),
            function_name
            + f" was {'called' if start else 'processed'} with the following parameters:",
        )
    ]
