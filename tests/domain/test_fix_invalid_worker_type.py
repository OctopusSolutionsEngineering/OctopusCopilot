import unittest

from domain.sanitizers.terraform import fix_invalid_worker_type


class FixInvalidWorkerTypeTests(unittest.TestCase):
    def test_replaces_dynamic_with_ubuntu_default(self):
        config = 'worker_type = "Dynamic"'
        self.assertEqual('worker_type = "UbuntuDefault"', fix_invalid_worker_type(config))

    def test_replaces_windows_value_with_windows_default(self):
        config = 'worker_type  = "Windows Server"'
        self.assertEqual('worker_type  = "WindowsDefault"', fix_invalid_worker_type(config))

    def test_keeps_valid_values(self):
        for value in ["Ubuntu2204", "UbuntuDefault", "Windows2022", "WindowsDefault"]:
            config = f'worker_type = "{value}"'
            self.assertEqual(config, fix_invalid_worker_type(config))

    def test_only_changes_worker_type(self):
        config = 'name = "Dynamic"\nworker_type = "Linux"\nmy_worker_type_note = "Dynamic"'
        self.assertEqual(
            'name = "Dynamic"\nworker_type = "UbuntuDefault"\nmy_worker_type_note = "Dynamic"',
            fix_invalid_worker_type(config),
        )


if __name__ == "__main__":
    unittest.main()
