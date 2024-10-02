import unittest

from domain.exceptions.octopus_version_invalid import OctopusVersionInvalid
from domain.versions.octopus_version import octopus_version_at_least


class ApiKeyTest(unittest.TestCase):
    def test_api_key_validation(self):
        self.assertTrue(octopus_version_at_least("2023.3.1", "2023.3.0"))
        self.assertTrue(octopus_version_at_least("2023.4.0", "2023.3.0"))
        self.assertTrue(octopus_version_at_least("2024.2.0", "2023.3.1"))
        self.assertTrue(octopus_version_at_least("2024.2.0", "2024.2.0"))
        self.assertTrue(octopus_version_at_least(" 2024.2.0", " 2024.2.0 "))
        self.assertTrue(octopus_version_at_least(" 2024 .2 .0", " 2024 . 2 . 0 "))

        self.assertFalse(octopus_version_at_least("2022.3.1", "2023.3.0"))
        self.assertFalse(octopus_version_at_least("2022.4.0", "2023.3.0"))
        self.assertFalse(octopus_version_at_least("2022.2.0", "2023.3.1"))
        self.assertFalse(octopus_version_at_least("2022.2.0", "2024.2.0"))
        self.assertRaises(
            OctopusVersionInvalid, octopus_version_at_least, "2022.2.0.1", "2024.2.0"
        )
        self.assertRaises(
            OctopusVersionInvalid, octopus_version_at_least, "2022.2.0", "2024.2"
        )
