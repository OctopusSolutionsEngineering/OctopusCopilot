import logging
import os


class OneLineExceptionFormatter(logging.Formatter):
    def formatException(self, exc_info):
        result = super().formatException(exc_info)
        return repr(result)

    def format(self, record):
        result = super().format(record)
        if record.exc_text:
            result = result.replace("\n", "")
        return result


def configure_logging(name=__name__):
    """
    Configures the Python logging system
    :return: A custom logger
    """
    handler = logging.StreamHandler()
    formatter = OneLineExceptionFormatter(logging.BASIC_FORMAT)
    handler.setFormatter(formatter)
    log = logging.getLogger(name)
    log.setLevel(os.environ.get("LOGLEVEL", "DEBUG"))
    log.addHandler(handler)

    # The Azure SDK's HTTP logging policy logs the method, URL, and headers of every
    # request/response at INFO level, which is noisy and was ending up in the function
    # logs. Silence it regardless of the level configured for our own loggers.
    logging.getLogger("azure").setLevel(logging.WARNING)

    return log
