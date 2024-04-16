import time
from datetime import datetime


def timing_wrapper(callback, identifier, log_query):
    try:
        start_time = time.time()
        if log_query:
            log_query(f"{identifier} start:", datetime.fromtimestamp(start_time).strftime("%H:%M:%S"))

        return callback()
    finally:
        end_time = time.time()
        execution_time = end_time - start_time
        if log_query:
            log_query(f"{identifier} end:", datetime.fromtimestamp(end_time).strftime("%H:%M:%S"))
            log_query(f"{identifier} time:", f"{execution_time} seconds")
