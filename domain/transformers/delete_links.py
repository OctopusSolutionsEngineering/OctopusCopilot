def delete_links(input_object):
    """
    Removes the Links item from a dictionary and any nested dictionaries.
    :param input_object: The input dictionary
    :return: The dictionary with links removed
    """
    if not input_object or not (isinstance(input_object, dict) or isinstance(input_object, list)):
        return input_object

    if isinstance(input_object, dict) and "Links" in input_object:
        del input_object["Links"]

    if isinstance(input_object, list):
        for value in input_object:
            delete_links(value)

    if isinstance(input_object, dict):
        for key, value in input_object.items():
            delete_links(value)

    return input_object
