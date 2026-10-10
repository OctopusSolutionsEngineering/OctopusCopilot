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


if __name__ == "__main__":
    unittest.main()
