from functools import reduce

from infrastructure.github import download_file
from infrastructure.http_pool import http

max_docs_results = 5


def get_docs_context(search_results, max_results=max_docs_results):
    if (
        not search_results
        or "items" not in search_results
        or not isinstance(search_results["items"], list)
    ):
        return ""

    return reduce(
        lambda text, result: (
            text + download_file(get_raw_url_from_blob(result["html_url"])) + "\n\n"
        ),
        search_results["items"][:max_results],
        "",
    )


def get_raw_url_from_blob(html_url):
    return html_url.replace("/blob/", "/raw/")
