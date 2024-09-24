import os
import unittest

from jinja2 import Environment, FileSystemLoader, select_autoescape

from domain.config.users import get_admin_users
from domain.security.security import is_admin_user


class HtmlTemplateTest(unittest.TestCase):

    def test_login_html_renders_correct_tabs_for_admin(self):
        search_path = os.path.join(os.path.abspath(os.path.join(__file__, "../../..")), "html/templates")
        env = Environment(
            loader=FileSystemLoader(search_path),
            autoescape=select_autoescape()
        )
        template = env.get_template("login.html")
        github_user = os.environ["TEST_GH_USER"]
        rendered_template = template.render(is_admin_user=is_admin_user(github_user, get_admin_users()))
        self.assertTrue(
            "id=\"octopus-tab\"" and "id=\"codefresh-tab\"" in rendered_template, "Response was " + rendered_template
        )

    def test_login_html_renders_octopus_tab_for_non_admin(self):
        search_path = os.path.join(os.path.abspath(os.path.join(__file__, "../../..")), "html/templates")
        env = Environment(
            loader=FileSystemLoader(search_path),
            autoescape=select_autoescape()
        )
        template = env.get_template("login.html")
        rendered_template = template.render(is_admin_user=False)
        self.assertTrue(
            "id=\"codefresh-tab\"" not in rendered_template, "Response was " + rendered_template
        )
