import unittest

from domain.sanitizers.terraform import fix_use_guided_infrastructure


class FixUseGuidedInfrastructureTests(unittest.TestCase):
    def test_removes_false_value(self):
        config = "use_guided_infrastructure = false"
        self.assertEqual("", fix_use_guided_infrastructure(config))

    def test_removes_true_value(self):
        config = "use_guided_infrastructure = true"
        self.assertEqual("", fix_use_guided_infrastructure(config))

    def test_removes_with_extra_whitespace_around_equals(self):
        config = "use_guided_infrastructure   =   false"
        self.assertEqual("", fix_use_guided_infrastructure(config))

    def test_removes_inline_within_block(self):
        config = (
            "resource \"octopusdeploy_deployment_target\" \"target\" {\n"
            "  use_guided_infrastructure = false\n"
            "  name = \"my-target\"\n"
            "}"
        )
        result = fix_use_guided_infrastructure(config)
        self.assertNotIn("use_guided_infrastructure", result)
        self.assertIn('name = "my-target"', result)

    def test_removes_multiple_occurrences(self):
        config = (
            "use_guided_infrastructure = false\n"
            "use_guided_infrastructure = true\n"
        )
        result = fix_use_guided_infrastructure(config)
        self.assertNotIn("use_guided_infrastructure", result)

    def test_does_not_remove_other_properties(self):
        config = 'name = "my-target"'
        self.assertEqual(config, fix_use_guided_infrastructure(config))

    def test_returns_empty_string_unchanged(self):
        self.assertEqual("", fix_use_guided_infrastructure(""))

    def test_raises_on_none_input(self):
        with self.assertRaises(TypeError):
            fix_use_guided_infrastructure(None)

    def test_does_not_remove_partial_match(self):
        # A property that merely contains "use_guided_infrastructure" as a substring
        # but is not an assignment should not be removed
        config = '# use_guided_infrastructure is not needed'
        self.assertEqual(config, fix_use_guided_infrastructure(config))


if __name__ == "__main__":
    unittest.main()

