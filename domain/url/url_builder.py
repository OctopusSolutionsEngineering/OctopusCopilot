from urllib.parse import urlparse
import azure.functions as func

from domain.validation.argument_validation import ensure_not_falsy


def base_request_url(req: func.HttpRequest):
    """
    base_request_url returns a base URL based on headers added by a proxy, or based on the original request
    :param req: The original request
    :return: The base URL of the request
    """
    ensure_not_falsy(req, 'req must not be None (base_request_url).')

    requested_url = urlparse(req.url)
    original_host = req.headers.get("X-Forwarded-Host")
    original_proto = req.headers.get("X-Forwarded-Proto")

    return f"{original_proto}://{original_host}" if original_proto and original_host else f"{requested_url.scheme}://{requested_url.hostname}"
