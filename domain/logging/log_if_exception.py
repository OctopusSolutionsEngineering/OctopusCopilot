def log_if_exception(logging, object, message):
    if not logging:
        return

    if isinstance(object, Exception):
        logging(message, str(object))
