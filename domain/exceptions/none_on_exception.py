from domain.logging.app_logging import configure_logging
from domain.validation.argument_validation import ensure_not_falsy

logger = configure_logging(__name__)


def none_on_exception(function):
    """
    A wrapper function that returns none instead of throwing an exception
    :param function: The function to call
    :return: The return value of the function, or None if an exception was thrown
    """
    ensure_not_falsy(function, "function must not be None (none_on_exception).")
    try:
        return function()
    except Exception as e:
        logger.error(e)
        return None


def default_on_exception(function, default):
    """
    A wrapper function that returns a default instead of throwing an exception
    :param function: The function to call
    :param default The value to return if there is an exception
    :return: The return value of the function, or the default value if an exception was thrown
    """
    ensure_not_falsy(function, "function must not be None (default_on_exception).")
    try:
        return function()
    except Exception as e:
        logger.error(e)
        return default


async def default_on_exception_async(function, default):
    """
    A wrapper function that returns a default instead of throwing an exception
    :param function: The function to call
    :param default The value to return if there is an exception
    :return: The return value of the function, or the default value if an exception was thrown
    """
    ensure_not_falsy(function, "function must not be None (default_on_exception).")
    try:
        return await function()
    except Exception as e:
        logger.error(e)
        return default
