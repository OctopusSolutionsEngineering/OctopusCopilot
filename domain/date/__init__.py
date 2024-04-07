from dateutil.parser import parse


def parse_unknown_format_date(date_string):
    try:
        return parse(date_string)
    except Exception as e:
        return None
