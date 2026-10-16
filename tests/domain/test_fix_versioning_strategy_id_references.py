import unittest

from domain.sanitizers.terraform import fix_versioning_strategy_id_references

PROJECT = 'resource "octopusdeploy_project" "project_r17_edge_gateway" {\n  count = 1\n  name  = "R17 Edge Gateway"\n}\n'
STRATEGY = (
    'resource "octopusdeploy_project_versioning_strategy" "project_r17_edge_gateway" {\n'
    '  project_id = "${octopusdeploy_project.project_r17_edge_gateway[0].id}"\n'
    "}\n"
)
OBSERVED = (
    'resource "octopusdeploy_runbook" "runbook_sync_all" {\n'
    '  project_id = "${length(local.matches) != 0 ? local.matches[0].id : '
    'octopusdeploy_project_versioning_strategy.project_r17_edge_gateway[0].id}"\n'
    "}\n"
)


class TestFixVersioningStrategyIdReferences(unittest.TestCase):
    def test_observed_reference_is_pointed_at_the_project(self):
        result = fix_versioning_strategy_id_references(PROJECT + STRATEGY + OBSERVED)
        self.assertIn("local.matches[0].id : octopusdeploy_project.project_r17_edge_gateway[0].id}", result)
        self.assertNotIn("octopusdeploy_project_versioning_strategy.project_r17_edge_gateway[0].id", result)
        # The strategy block itself is untouched
        self.assertIn(STRATEGY, result)

    def test_reference_without_index(self):
        config = PROJECT + 'x = "${octopusdeploy_project_versioning_strategy.project_r17_edge_gateway.id}"\n'
        self.assertIn(
            'x = "${octopusdeploy_project.project_r17_edge_gateway.id}"',
            fix_versioning_strategy_id_references(config),
        )

    def test_undeclared_project_is_unchanged(self):
        config = STRATEGY + OBSERVED
        self.assertEqual(config, fix_versioning_strategy_id_references(config))

    def test_other_attributes_are_unchanged(self):
        config = PROJECT + 'x = "${octopusdeploy_project_versioning_strategy.project_r17_edge_gateway[0].project_id}"\n'
        self.assertEqual(config, fix_versioning_strategy_id_references(config))

    def test_empty(self):
        self.assertEqual("", fix_versioning_strategy_id_references(""))
        self.assertIsNone(fix_versioning_strategy_id_references(None))


if __name__ == "__main__":
    unittest.main()
