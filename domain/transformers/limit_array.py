def limit_array_to_max_char_length(array, max_length):
    """
    Limits the array to the max number of characters

    :param array: The array to limit
    :param max_length: The max number of characters
    :return: The limited array
    """
    if isinstance(array, Exception):
        return []

    current_length = 0
    for i, item in enumerate(array):
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
    return array[:max_items] if not isinstance(array, Exception) else []
