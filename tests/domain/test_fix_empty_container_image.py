import unittest

from domain.sanitizers.terraform import fix_empty_container_image

FEED = '"${length(local.feed_ghcr_anonymous_feeds_matches) != 0 ? local.feed_ghcr_anonymous_feeds_matches[0].id : octopusdeploy_docker_container_registry.feed_ghcr_anonymous[0].id}"'


def step(container):
    return f"""resource "octopusdeploy_process_step" "process_step_build_layer" {{
  name = "Build Layer"
  {container}
  execution_properties = {{
    "Octopus.Action.Script.Syntax" = "Bash"
  }}
}}
"""


class TestFixEmptyContainerImage(unittest.TestCase):
    def test_observed_dockerfile_with_empty_image_uses_base_image(self):
        config = step(
            "container = {\n"
            '    dockerfile = "FROM python:3.12-slim\\nRUN pip install boto3"\n'
            f"    feed_id    = {FEED}\n"
            "    git_url    = null\n"
            '    image      = ""\n'
            "  }"
        )
        result = fix_empty_container_image(config)
        self.assertIn('image      = "python:3.12-slim"', result)
        self.assertIn(f"feed_id    = {FEED}", result)
        self.assertIn('"Octopus.Action.Script.Syntax" = "Bash"', result)

    def test_single_line_container_with_platform_flag(self):
        config = step(
            'container = { dockerfile = "FROM --platform=linux/amd64 node:20 AS build\\nRUN npm ci", '
            f'feed_id = {FEED}, git_url = null, image = "" }}'
        )
        self.assertIn('image = "node:20"', fix_empty_container_image(config))

    def test_empty_image_without_dockerfile_clears_feed(self):
        config = step(f'container = {{ dockerfile = null, feed_id = {FEED}, git_url = null, image = "" }}')
        result = fix_empty_container_image(config)
        self.assertIn('feed_id = null, git_url = null, image = ""', result)

    def test_container_with_image_is_unchanged(self):
        config = step(
            f'container = {{ dockerfile = null, feed_id = {FEED}, git_url = null, image = "ghcr.io/octopusdeploylabs/aws-workertools" }}'
        )
        self.assertEqual(config, fix_empty_container_image(config))

    def test_empty_image_and_empty_feed_is_unchanged(self):
        config = step('container = { dockerfile = null, feed_id = "", git_url = null, image = "" }')
        self.assertEqual(config, fix_empty_container_image(config))

    def test_multiple_steps(self):
        container = (
            'container = { dockerfile = "FROM alpine:3.20", '
            f'feed_id = {FEED}, git_url = null, image = "" }}'
        )
        result = fix_empty_container_image(step(container) + step(container))
        self.assertEqual(2, result.count('image = "alpine:3.20"'))

    def test_empty(self):
        self.assertEqual("", fix_empty_container_image(""))
        self.assertIsNone(fix_empty_container_image(None))


if __name__ == "__main__":
    unittest.main()
