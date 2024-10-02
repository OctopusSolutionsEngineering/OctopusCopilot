import time
from datetime import datetime

from domain.logging.app_logging import configure_logging
from domain.validation.argument_validation import (
    ensure_string_not_empty,
    ensure_not_falsy,
)

logger = configure_logging(__name__)


def timing_wrapper(callback, identifier):
    """
    Times the execution of a callback. This is important because the chat interface has timeouts and we need to know
    where most of our time is being spent.
    :param callback: The logic to time
    :param identifier: A name used to identify the callback logic
    :return: The return value of the callback
    """
    ensure_not_falsy(callback, "callback must not be None (timing_wrapper).")
    ensure_string_not_empty(
        identifier, "identifier must not be empty (timing_wrapper)."
    )

    start_time = time.time()
    logger.info(
        f"{identifier} start: {datetime.fromtimestamp(start_time).strftime('%H:%M:%S')}"
    )

    try:
        return callback()
    finally:
        end_time = time.time()
        execution_time = end_time - start_time
        logger.info(
            f"{identifier} end: {datetime.fromtimestamp(end_time).strftime('%H:%M:%S')}"
        )
        logger.info(f"{identifier} time: {execution_time} seconds")
