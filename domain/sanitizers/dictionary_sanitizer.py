def dictionary_has_value(key, dictionary):
    if dictionary is None:
        return False

    if isinstance(dictionary, dict):
        if not dictionary.get(key):
            return False

        value = dictionary[key]
        return len(value) > 0

    return False
