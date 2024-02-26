import unittest

from infrastructure.octopus import get_octopus_project_names_response


class EnsureTests(unittest.TestCase):
    def test_get_octopus_project_names_response(self):
        self.assertEqual(get_octopus_project_names_response("Default", ["Project1"]),
                         "I found 1 projects in the space \"Default\":\n* Project1")
        self.assertEqual(get_octopus_project_names_response("", ["Project1"]),
                         "I found 1 projects:\n* Project1")
        self.assertEqual(get_octopus_project_names_response("", []),
                         "I found no projects.")
        self.assertEqual(get_octopus_project_names_response(None, None),
                         "I found no projects.")
        self.assertEqual(get_octopus_project_names_response("Default", []),
                         "I found no projects in the space Default.")
