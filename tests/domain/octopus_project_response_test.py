import unittest

from domain.view.markdown.markdown_dashboards import get_octopus_project_names_response


class EnsureTests(unittest.TestCase):
    def test_get_octopus_project_names_response(self):
        self.assertEqual(get_octopus_project_names_response("Default", ["Deploy Web App Container"]),
                         "I found 1 projects in the space \"Default\":\n* Deploy Web App Container")
        self.assertEqual(get_octopus_project_names_response("", ["Deploy Web App Container"]),
                         "I found 1 projects:\n* Deploy Web App Container")
        self.assertEqual(get_octopus_project_names_response("", []),
                         "I found no projects.")
        self.assertEqual(get_octopus_project_names_response(None, None),
                         "I found no projects.")
        self.assertEqual(get_octopus_project_names_response("Default", []),
                         "I found no projects in the space Default.")
