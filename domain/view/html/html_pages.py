from jinja2 import Environment, FileSystemLoader, select_autoescape

from domain.config.users import get_admin_users
from domain.requests.github.copilot_request_context import get_github_user_from_form
from domain.security.security import is_admin_user


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


def get_login_page(req, search_path="html/templates"):
    env = Environment(
        loader=FileSystemLoader(searchpath=search_path),
        autoescape=select_autoescape(),
    )
    template = env.get_template("login.html")
    return template.render(
        is_admin_user=is_admin_user(get_github_user_from_form(req), get_admin_users())
    )
