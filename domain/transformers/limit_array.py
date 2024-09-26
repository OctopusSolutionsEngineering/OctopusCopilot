def limit_array_to_max_char_length(array, max_length):
    """
    Limits the array to the max number of characters

    :param array: The array to limit
    :param max_length: The max number of characters
    :return: The limited array
    """
    # Anything other than an array is returned as is.
    if not isinstance(array, list):
        return array

    current_length = 0
    for i, item in enumerate(array):
        if not (isinstance(item, list) or isinstance(item, str)):
            continue
        current_length += len(item)
        if current_length > max_length:
            return array[:i]
    return array


def limit_array_to_max_items(array, max_items):
    """
    Limits the array to the max number of items, if the array is an exception, return an empty array

    :param array: The array to limit
    :param max_items: The max number of items
    :return: The limited array
    """
    if not isinstance(array, list):
        return array

    return array[:max_items]


def limit_text_in_array(array, max_length):
    if not isinstance(array, list):
        return array

    return list(map(lambda x: x if not isinstance(x, str) else x[:max_length], array))


def count_non_empty_items(array):
    if not isinstance(array, list):
        return 0

    return len(
        list(
            filter(
                lambda x: (isinstance(x, list) or isinstance(x, str)) and len(x) != 0,
                array,
            )
        )
    )


def array_or_empty_if_exception(array):
    if isinstance(array, Exception):
        return []

    return array


def object_or_none_if_exception(object):
    if isinstance(object, Exception):
        return None

    return object


def object_or_default_if_exception(object, default):
    if isinstance(object, Exception):
        return default

    return object
