from jinja2 import Environment, FileSystemLoader, select_autoescape


def get_redirect_page(url, message, search_path="html/templates"):
    # Need to use client side redirection, as HTTP redirects don't play well with strict cookies when
    # the redirect page was called from a different domain. Browsers don't send cookies when the referrer
    # was from a different domain, which means the session cookie is not sent back by the page opened by
    # the redirect.
    env = Environment(
        loader=FileSystemLoader(searchpath=search_path),
        autoescape=select_autoescape(),
    )
    template = env.get_template("redirect.html")
    return template.render(
        redirect_url=url,
        message=message,
    )
