def limit_array_to_max_char_length(array, max_length):
    """
    Limits the array to the max number of characters

    :param array: The array to limit
    :param max_length: The max number of characters
    :return: The limited array
    """
    current_length = 0
    for i, item in enumerate(array):
        current_length += len(item)
        if current_length > max_length:
            return array[:i]
    return array
