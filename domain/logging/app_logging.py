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

    # Presidio warns at WARNING level whenever spaCy tags an entity (e.g. WORK_OF_ART,
    # CARDINAL) that it has no PII mapping for, even though it keeps the entity anyway.
    # That warning is noise, not an actionable error, so silence it too.
    logging.getLogger("presidio-analyzer").setLevel(logging.ERROR)

    return log
