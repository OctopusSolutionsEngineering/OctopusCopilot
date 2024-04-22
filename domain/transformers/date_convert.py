from domain.validation.argument_validation import ensure_not_falsy


def datetime_to_str(dt):
    ensure_not_falsy(dt, 'dt must not be falsy (datetime_to_str).')
    return dt.isoformat()
