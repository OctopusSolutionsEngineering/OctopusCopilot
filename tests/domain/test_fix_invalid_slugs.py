import unittest

from domain.sanitizers.terraform import fix_invalid_slugs


class TestFixInvalidSlugs(unittest.TestCase):
    def test_cjk_slug_becomes_stable_hash(self):
        config = '  slug                  = "日本語ステップ"\n'
        result = fix_invalid_slugs(config)
        self.assertRegex(result, r'slug                  = "slug-[0-9a-f]{8}"')
        self.assertEqual(fix_invalid_slugs(config), result)

    def test_lowercase_non_ascii_letters_are_kept(self):
        config = '  slug = "begrüßung"\n'
        self.assertEqual(fix_invalid_slugs(config), config)

    def test_valid_ascii_slug_is_unchanged(self):
        config = '  slug = "deploy-web-app-2"\n'
        self.assertEqual(fix_invalid_slugs(config), config)

    def test_mixed_slug_keeps_valid_part(self):
        result = fix_invalid_slugs('  slug = "step-日本語-1"\n')
        self.assertIn('slug = "step-1"', result)

    def test_uppercase_and_spaces_are_normalised(self):
        result = fix_invalid_slugs('  slug = "Deploy Web App"\n')
        self.assertIn('slug = "deploy-web-app"', result)

    def test_interpolated_slug_is_unchanged(self):
        config = '  slug = "${var.slug}"\n'
        self.assertEqual(fix_invalid_slugs(config), config)

    def test_empty_config(self):
        self.assertEqual(fix_invalid_slugs(""), "")
        self.assertIsNone(fix_invalid_slugs(None))

    def test_trailing_and_doubled_dashes_are_collapsed(self):
        config = '  slug = "run-job-from-yaml-octopus-release-number-replace--"\n  deployment_action_slug = "run-job-from-yaml-octopus-release-number-replace--"\n'
        result = fix_invalid_slugs(config)
        self.assertIn('slug = "run-job-from-yaml-octopus-release-number-replace"', result)
        self.assertIn('deployment_action_slug = "run-job-from-yaml-octopus-release-number-replace"', result)

    def test_leading_dash_and_double_dash_inside(self):
        result = fix_invalid_slugs('  slug = "-a--b"\n')
        self.assertIn('slug = "a-b"', result)


if __name__ == "__main__":
    unittest.main()
