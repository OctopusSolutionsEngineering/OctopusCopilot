import unittest

from domain.sanitizers.terraform import fix_container_null_feed_id


def step(container):
    return f"""resource "octopusdeploy_process_step" "process_step_run_db_migrations" {{
  name = "Run DB Migrations"
  {container}
  execution_properties = {{
    "Octopus.Action.Script.ScriptFileName" = "migrate.sh"
  }}
}}
"""


class TestFixContainerNullFeedId(unittest.TestCase):
    def test_observed_dockerfile_with_null_feed_uses_empty_string(self):
        config = step(
            'container = { dockerfile = "FROM amazon/aws-cli:2.15.0\\nRUN yum install -y jq && echo \\"$${HOME}\\" '
            '&& printf \\"%%{x}\\"", feed_id = null, git_url = null, image = "amazon/aws-cli:2.15.0" }'
        )
        result = fix_container_null_feed_id(config)
        self.assertIn('feed_id = "", git_url = null, image = "amazon/aws-cli:2.15.0" }', result)
        self.assertIn('echo \\"$${HOME}\\"', result)

    def test_null_image_uses_dockerfile_base_image(self):
        config = step('container = { dockerfile = "FROM python:3.12-slim\\nRUN pip install boto3", feed_id = null, git_url = null, image = null }')
        result = fix_container_null_feed_id(config)
        self.assertIn('feed_id = "", git_url = null, image = "python:3.12-slim" }', result)

    def test_multi_line_container(self):
        config = step(
            "container = {\n"
            '    dockerfile = "FROM node:20\\nRUN npm ci"\n'
            "    feed_id    = null\n"
            "    git_url    = null\n"
            '    image      = "node:20"\n'
            "  }"
        )
        result = fix_container_null_feed_id(config)
        self.assertIn('feed_id    = ""', result)

    def test_feed_reference_is_kept(self):
        feed = '"${octopusdeploy_docker_container_registry.feed_ghcr[0].id}"'
        config = step(f'container = {{ dockerfile = null, feed_id = {feed}, git_url = null, image = "ghcr.io/octopusdeploylabs/k8s-workertools" }}')
        self.assertEqual(config, fix_container_null_feed_id(config))

    def test_all_null_container_is_unchanged(self):
        config = step("container = { dockerfile = null, feed_id = null, git_url = null, image = null }")
        self.assertEqual(config, fix_container_null_feed_id(config))

    def test_no_container(self):
        config = step("")
        self.assertEqual(config, fix_container_null_feed_id(config))
        self.assertEqual("", fix_container_null_feed_id(""))
        self.assertIsNone(fix_container_null_feed_id(None))


if __name__ == "__main__":
    unittest.main()
