import unittest

from domain.sanitizers.terraform import fix_delete_machines_behavior


class TestFixDeleteMachinesBehavior(unittest.TestCase):
    def test_observed_delete(self):
        config = 'machine_cleanup_policy {\n  delete_machines_behavior         = "Delete"\n  delete_machines_elapsed_timespan = 7200000000000\n}'
        result = fix_delete_machines_behavior(config)
        self.assertIn('delete_machines_behavior         = "DeleteUnavailableMachines"', result)
        self.assertIn("delete_machines_elapsed_timespan = 7200000000000", result)

    def test_delete_variants(self):
        for value in ["DeleteUnavailable", "delete_unavailable_machines", "Delete Unavailable Machines"]:
            result = fix_delete_machines_behavior(f'delete_machines_behavior = "{value}"')
            self.assertEqual('delete_machines_behavior = "DeleteUnavailableMachines"', result)

    def test_other_values_become_do_not_delete(self):
        for value in ["Never", "DoNotDeleteMachines", "Keep", ""]:
            result = fix_delete_machines_behavior(f'delete_machines_behavior = "{value}"')
            self.assertEqual('delete_machines_behavior = "DoNotDelete"', result)

    def test_valid_values_are_unchanged(self):
        config = 'delete_machines_behavior = "DeleteUnavailableMachines"\ndelete_machines_behavior = "DoNotDelete"'
        self.assertEqual(config, fix_delete_machines_behavior(config))

    def test_empty(self):
        self.assertEqual("", fix_delete_machines_behavior(""))
        self.assertIsNone(fix_delete_machines_behavior(None))


if __name__ == "__main__":
    unittest.main()
