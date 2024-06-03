def list_empty_or_match(source_list, item_map, item):
    if not source_list:
        return True
    return next(filter(lambda x: item == item_map(x), source_list), None)
