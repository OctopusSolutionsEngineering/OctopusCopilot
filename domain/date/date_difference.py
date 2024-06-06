def get_date_difference_summary(difference):
    if difference.days > 0:
        return f"{difference.days} day{'s' if difference.days > 1 else ''}"
    if difference.seconds > 3600:
        hours = difference.seconds // 3600
        return f"{hours} hour{'s' if hours > 1 else ''}"
    if difference.seconds > 60:
        minutes = difference.seconds // 60
        return f"{minutes} minute{'s' if minutes > 1 else ''}"
    return f"{difference.seconds} second{'s' if difference.seconds > 1 else ''}"
