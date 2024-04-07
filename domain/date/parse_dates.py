from datetime import timezone

from dateutil.parser import parse


def parse_unknown_format_date(date_string):
    try:
        date = parse(date_string)

        # We need an offset aware date, so assume utc if the date format has no timezone
        if not is_offset_aware(date):
            date = date.replace(tzinfo=timezone.utc)

        return date

    except Exception as e:
        return None


def is_offset_aware(dt):
    return dt.tzinfo is not None and dt.tzinfo.utcoffset(dt) is not None
