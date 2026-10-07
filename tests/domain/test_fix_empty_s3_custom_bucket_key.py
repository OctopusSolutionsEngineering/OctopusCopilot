import unittest

from domain.sanitizers.terraform import fix_empty_s3_custom_bucket_key


class FixEmptyS3CustomBucketKeyTest(unittest.TestCase):
    def test_none(self):
        self.assertIsNone(fix_empty_s3_custom_bucket_key(None))

    def test_empty_custom_key_uses_filename(self):
        config = """resource "octopusdeploy_process_step" "upload" {
  type = "Octopus.AwsUploadS3"
  execution_properties = {
    "Octopus.Action.Aws.S3.PackageOptions" = jsonencode({
      "bucketKeyBehaviour" = "Custom"
      "bucketKey"          = ""
      "bucketKeyPrefix"    = ""
    })
  }
}"""
        fixed = fix_empty_s3_custom_bucket_key(config)
        self.assertIn('"bucketKeyBehaviour" = "Filename"', fixed)
        self.assertNotIn('"Custom"', fixed)

    def test_keeps_custom_key_with_value(self):
        config = """resource "octopusdeploy_process_step" "upload" {
  execution_properties = {
    "Octopus.Action.Aws.S3.PackageOptions" = jsonencode({
      "bucketKeyBehaviour" = "Custom"
      "bucketKey"          = "assets/#{Octopus.Release.Number}.zip"
    })
  }
}"""
        self.assertEqual(config, fix_empty_s3_custom_bucket_key(config))

    def test_ignores_resources_without_bucket_key(self):
        config = """resource "octopusdeploy_process_step" "script" {
  execution_properties = {
    "bucketKeyBehaviour" = "Custom"
  }
}"""
        self.assertEqual(config, fix_empty_s3_custom_bucket_key(config))

    def test_only_affects_step_with_empty_key(self):
        config = """resource "octopusdeploy_process_step" "one" {
  execution_properties = {
    "Octopus.Action.Aws.S3.PackageOptions" = jsonencode({
      "bucketKeyBehaviour" = "Custom"
      "bucketKey"          = "site.zip"
    })
  }
}
resource "octopusdeploy_process_step" "two" {
  execution_properties = {
    "Octopus.Action.Aws.S3.PackageOptions" = jsonencode({
      "bucketKeyBehaviour" = "Custom"
      "bucketKey"          = "  "
    })
  }
}"""
        fixed = fix_empty_s3_custom_bucket_key(config)
        self.assertEqual(1, fixed.count('"bucketKeyBehaviour" = "Custom"'))
        self.assertEqual(1, fixed.count('"bucketKeyBehaviour" = "Filename"'))
