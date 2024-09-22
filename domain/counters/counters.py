def count_items_with_data(items):
    """
    Counts the number of items in an array that are not empty or exceptions.
    :param items: The list of items to count
    :return: The number of non-empty items
    """
    if not items:
        return 0

    return len(
        list(
            filter(
                lambda x: x and not isinstance(x, Exception),
                items,
            )
        )
    )
