import time
from datetime import datetime

from domain.logging.app_logging import configure_logging

logger = configure_logging(__name__)


def timing_wrapper(callback, identifier):
    try:
        start_time = time.time()
        logger.info(f"{identifier} start: {datetime.fromtimestamp(start_time).strftime('%H:%M:%S')}")

        return callback()
    finally:
        end_time = time.time()
        execution_time = end_time - start_time
        logger.info(f"{identifier} end: {datetime.fromtimestamp(end_time).strftime('%H:%M:%S')}")
        logger.info(f"{identifier} time: {execution_time} seconds")
