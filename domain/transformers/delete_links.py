def delete_links(input_dict):
    """
    Removes the Links item from a dictionary and any nested dictionaries.
    :param input_dict: The input dictionary
    :return: The dictionary with links removed
    """
    if not input_dict or not isinstance(input_dict, dict):
        return input_dict

    if "Links" in input_dict:
        del input_dict["Links"]

    for key, value in input_dict.items():
        if isinstance(value, dict):
            delete_links(value)

    return input_dict
