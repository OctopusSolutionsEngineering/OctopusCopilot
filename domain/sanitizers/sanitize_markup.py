import re

from bs4 import BeautifulSoup
from markdown import markdown


def markdown_to_text(markdown_string):
    """Converts a markdown string to plaintext"""

    if not markdown_string:
        return ""

    # md -> html -> text since BeautifulSoup can extract text cleanly
    html = markdown(markdown_string)

    # remove code snippets
    html = re.sub(r"<pre>(.*?)</pre>", " ", html)
    html = re.sub(r"<code>(.*?)</code>", " ", html)

    # extract text
    soup = BeautifulSoup(html, "html.parser")
    text = "".join(soup.findAll(text=True))

    # Return plain text
    return re.sub("[^A-Za-z0-9]", " ", text)


def html_to_text(html):
    """Converts a html string to plaintext"""
    if not html:
        return ""

    # extract text
    soup = BeautifulSoup(html, "html.parser")
    text = "".join(soup.findAll(text=True))

    return text
