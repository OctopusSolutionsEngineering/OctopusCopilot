import unittest

from domain.sanitizers.terraform import remove_duplicate_definitions


class DuplicateRemovalTest(unittest.TestCase):
    def test_remove_duplicate_definitions_none(self):
        self.assertEqual("", remove_duplicate_definitions(None))

    def test_remove_duplicate_definitions(self):
        fixed = remove_duplicate_definitions(
            """resource "octopusdeploy_project" "project" {
    name = "Test Project"
}
resource "octopusdeploy_project" "project" {
    name = "Test Project"
}
resource "octopusdeploy_project" "project2" {
    name = "Test Project"
}"""
        )
        self.assertEqual(
            """resource "octopusdeploy_project" "project" {
    name = "Test Project"
}
resource "octopusdeploy_project" "project2" {
    name = "Test Project"
}""",
            fixed,
        )

    def test_remove_duplicate_definitions_nested(self):
        fixed = remove_duplicate_definitions(
            """resource "octopusdeploy_project" "project" {
    name = "Test Project"
    nested {
        something = "value"
    }
}
resource "octopusdeploy_project" "project" {
    name = "Test Project"
    nested {
        something = "value"
    }
}
resource "octopusdeploy_project" "project2" {
    name = "Test Project"
    nested {
        something = "value"
    }
}"""
        )
        self.assertEqual(
            """resource "octopusdeploy_project" "project" {
    name = "Test Project"
    nested {
        something = "value"
    }
}
resource "octopusdeploy_project" "project2" {
    name = "Test Project"
    nested {
        something = "value"
    }
}""",
            fixed,
        )

    def test_remove_duplicate_definitions_nested_inline(self):
        fixed = remove_duplicate_definitions(
            """resource "octopusdeploy_project" "project" {
    name = "Test Project"
    nested {
        something = "${var.value}"
    }
}
resource "octopusdeploy_project" "project" {
    name = "Test Project"
    nested {
        something = "${var.value}"
    }
}
resource "octopusdeploy_project" "project2" {
    name = "Test Project"
    nested {
        something = "${var.value}"
    }
}"""
        )
        self.assertEqual(
            """resource "octopusdeploy_project" "project" {
    name = "Test Project"
    nested {
        something = "${var.value}"
    }
}
resource "octopusdeploy_project" "project2" {
    name = "Test Project"
    nested {
        something = "${var.value}"
    }
}""",
            fixed,
        )

    def test_remove_duplicate_definitions_nested_weird_indents(self):
        """
        This is known not to work. It is a limitation of the current implementation that it does not handle
        nested blocks with inconsistent indentation or inline definitions properly.
        """
        fixed = remove_duplicate_definitions(
            """resource "octopusdeploy_project" "project" {
    name = "Test Project"
    nested {
        something = "${var.value}"
}
}
resource "octopusdeploy_project" "project" {
    name = "Test Project"
    nested {
        something = "${var.value}"
}
}
resource "octopusdeploy_project" "project2" {
    name = "Test Project"
    nested {
        something = "${var.value}"
}
}"""
        )

        # This is known not to work.
        self.assertNotEqual(
            """resource "octopusdeploy_project" "project" {
    name = "Test Project"
    nested {
        something = "${var.value}"
}
}
resource "octopusdeploy_project" "project2" {
    name = "Test Project"
    nested {
        something = "${var.value}"
}
}""",
            fixed,
        )

    def test_valid_definitions_nested_weird_indents(self):
        fixed = remove_duplicate_definitions(
            """resource "octopusdeploy_project" "project3" {
    name = "Test Project"
    nested {
        something = "${var.value}"
}
}
resource "octopusdeploy_project" "project" {
    name = "Test Project"
    nested {
        something = "${var.value}"
}
}
resource "octopusdeploy_project" "project2" {
    name = "Test Project"
    nested {
        something = "${var.value}"
}
}"""
        )

        self.assertEqual(
            """resource "octopusdeploy_project" "project3" {
    name = "Test Project"
    nested {
        something = "${var.value}"
}
}
resource "octopusdeploy_project" "project" {
    name = "Test Project"
    nested {
        something = "${var.value}"
}
}
resource "octopusdeploy_project" "project2" {
    name = "Test Project"
    nested {
        something = "${var.value}"
}
}""",
            fixed,
        )

    def test_remove_duplicate_definitions_nested_inline1(self):
        fixed = remove_duplicate_definitions(
            """resource "octopusdeploy_project" "project" {
    name = "Test Project"
    nested {something = "${var.value}"}
}
resource "octopusdeploy_project" "project" {
    name = "Test Project"
    nested {something = "${var.value}"}
}
resource "octopusdeploy_project" "project2" {
    name = "Test Project"
    nested {something = "${var.value}"}
}"""
        )
        self.assertEqual(
            """resource "octopusdeploy_project" "project" {
    name = "Test Project"
    nested {something = "${var.value}"}
}
resource "octopusdeploy_project" "project2" {
    name = "Test Project"
    nested {something = "${var.value}"}
}""",
            fixed,
        )

    def test_remove_no_duplicate_definitions(self):
        fixed = remove_duplicate_definitions(
            """resource "octopusdeploy_project" "project" {
    name = "Test Project"
}
resource "octopusdeploy_project" "project3" {
    name = "Test Project"
}
resource "octopusdeploy_project" "project2" {
    name = "Test Project"
}"""
        )
        self.assertEqual(
            """resource "octopusdeploy_project" "project" {
    name = "Test Project"
}
resource "octopusdeploy_project" "project3" {
    name = "Test Project"
}
resource "octopusdeploy_project" "project2" {
    name = "Test Project"
}""",
            fixed,
        )

    def test_remove_duplicate_data_definitions(self):
        fixed = remove_duplicate_definitions(
            """data "octopusdeploy_projects" "project" {
    name = "Test Project"
}
data "octopusdeploy_projects" "project" {
    name = "Test Project"
}
data "octopusdeploy_projects" "project2" {
    name = "Test Project"
}"""
        )
        self.assertEqual(
            """data "octopusdeploy_projects" "project" {
    name = "Test Project"
}
data "octopusdeploy_projects" "project2" {
    name = "Test Project"
}""",
            fixed,
        )

    def test_remove_duplicate_variable_definitions(self):
        fixed = remove_duplicate_definitions(
            """variable "octopusdeploy_projects" "project" {
    name = "Test Project"
}
variable "octopusdeploy_projects" "project" {
    name = "Test Project"
}
variable "octopusdeploy_projects" "project2" {
    name = "Test Project"
}"""
        )
        self.assertEqual(
            """variable "octopusdeploy_projects" "project" {
    name = "Test Project"
}
variable "octopusdeploy_projects" "project2" {
    name = "Test Project"
}""",
            fixed,
        )

    def test_remove_duplicate_output_definitions(self):
        fixed = remove_duplicate_definitions(
            """output "octopusdeploy_projects" "project" {
    name = "Test Project"
}
output "octopusdeploy_projects" "project" {
    name = "Test Project"
}
output "octopusdeploy_projects" "project2" {
    name = "Test Project"
}"""
        )
        self.assertEqual(
            """output "octopusdeploy_projects" "project" {
    name = "Test Project"
}
output "octopusdeploy_projects" "project2" {
    name = "Test Project"
}""",
            fixed,
        )
