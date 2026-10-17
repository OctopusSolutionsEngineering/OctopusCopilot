import unittest

from domain.sanitizers.terraform import fix_misplaced_octostache_else


class TestFixMisplacedOctostacheElse(unittest.TestCase):
    def test_observed_run_condition(self):
        config = '"Octopus.Step.ConditionVariableExpression" = "#{if Wave.SkipSmokeTests == \\"True\\"}false#{/if}#{else}true#{/else}"'
        result = fix_misplaced_octostache_else(config)
        self.assertEqual(
            '"Octopus.Step.ConditionVariableExpression" = "#{if Wave.SkipSmokeTests == \\"True\\"}false#{else}true#{/if}"',
            result,
        )

    def test_unless_block(self):
        config = '"#{unless Octopus.Deployment.Error}true#{/unless}#{else}false#{/else}"'
        self.assertEqual(
            '"#{unless Octopus.Deployment.Error}true#{else}false#{/unless}"', fix_misplaced_octostache_else(config)
        )

    def test_every_occurrence_is_fixed(self):
        line = '"#{if A}x#{/if}#{else}y#{/else}"\n'
        result = fix_misplaced_octostache_else(line * 3)
        self.assertEqual('"#{if A}x#{else}y#{/if}"\n' * 3, result)

    def test_valid_else_is_unchanged(self):
        config = '"#{if A == \\"B\\"}x#{else}y#{/if}"'
        self.assertEqual(config, fix_misplaced_octostache_else(config))

    def test_empty(self):
        self.assertEqual("", fix_misplaced_octostache_else(""))
        self.assertIsNone(fix_misplaced_octostache_else(None))


if __name__ == "__main__":
    unittest.main()
