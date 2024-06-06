def get_date_difference_summary(difference):
    if difference.days > 0:
        return f"{difference.days} days"
    if difference.seconds > 3600:
        return f"{difference.seconds // 3600} hours"
    if difference.seconds > 60:
        return f"{difference.seconds // 60} minutes"
    return f"{difference.seconds} seconds"
