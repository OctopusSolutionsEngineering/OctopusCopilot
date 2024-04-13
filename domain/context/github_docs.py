from functools import reduce

from infrastructure.http_pool import http


def get_docs_context(search_results):
    return reduce(lambda text, result: (text
                                        + http.request("GET",
                                                       result["html_url"]
                                                       .replace("/blob/", "/raw/"))
                                        .data.decode("utf-8")
                                        + "\n\n"),
                  search_results["items"][:5], "")
