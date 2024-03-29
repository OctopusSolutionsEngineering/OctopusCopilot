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
    return log
