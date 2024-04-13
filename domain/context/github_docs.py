from infrastructure.http_pool import http


def get_docs_context(search_results):
    text = ""
    # Get the first 5 docs
    for match in search_results["items"][:5]:
        raw_url = match["html_url"].replace("/blob/", "/raw/")
        resp = http.request("GET", raw_url)
        text += resp.data.decode("utf-8") + "\n\n"
