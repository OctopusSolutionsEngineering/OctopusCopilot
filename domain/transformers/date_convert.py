from domain.validation.argument_validation import ensure_is_datetime


def datetime_to_str(dt):
    ensure_is_datetime(dt, "dt must be a date (datetime_to_str).")

    return dt.isoformat()
