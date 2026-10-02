import unittest

from domain.sanitizers.terraform import (
    fix_maven_feed_acquisition_options,
    fix_check_targets_available_template_url,
    fix_check_smtp_server_configured_template_url,
    CHECK_SMTP_SERVER_CONFIGURED_TEMPLATE_URL,
    fix_default_guided_failure_mode,
    fix_underscore_quoted_strings,
    sanitize_primary_package,
    remove_primary_package,
    fix_community_step_template_count,
    escape_bare_interpolations,
    remove_worker_pool_from_target_steps,
    fix_script_source,
    remove_balanced_attribute,
    CONTAINER_START_REGEX,
    CHECK_TARGETS_AVAILABLE_TEMPLATE_URL,
)


class TestMavenFeedAcquisitionOptions(unittest.TestCase):
    def test_replaces_not_acquired_in_maven_feed(self):
        config = """resource "octopusdeploy_maven_feed" "feed_octopus_maven_feed" {
  count = 1
  name  = "Octopus Maven"
  package_acquisition_location_options = ["ExecutionTarget", "NotAcquired"]
  lifecycle {
    ignore_changes = [password]
  }
}
resource "octopusdeploy_docker_container_registry" "feed_docker_hub" {
  package_acquisition_location_options = ["ExecutionTarget", "NotAcquired"]
}"""
        result = fix_maven_feed_acquisition_options(config)
        self.assertIn(
            'feed_octopus_maven_feed" {\n  count = 1\n  name  = "Octopus Maven"\n  package_acquisition_location_options = ["Server", "ExecutionTarget"]',
            result,
        )
        # The Docker feed is left alone
        self.assertEqual(
            result.count('["ExecutionTarget", "NotAcquired"]'),
            1,
        )


    def test_leaves_maven_feed_without_option_unchanged(self):
        config = """resource "octopusdeploy_maven_feed" "feed_octopus_maven_feed" {
  name     = "Octopus Maven"
  feed_uri = "https://maven.octopus.com/repository/maven-public/"
}"""
        self.assertEqual(fix_maven_feed_acquisition_options(config), config)

    def test_leaves_correct_maven_feed_options_unchanged(self):
        config = """resource "octopusdeploy_maven_feed" "feed_octopus_maven_feed" {
  package_acquisition_location_options = ["Server", "ExecutionTarget"]
}"""
        self.assertEqual(fix_maven_feed_acquisition_options(config), config)

    def test_only_touches_the_maven_feed_when_followed_by_other_resources(self):
        config = """resource "octopusdeploy_maven_feed" "feed_a" {
  package_acquisition_location_options = ["ExecutionTarget", "NotAcquired"]
}
resource "octopusdeploy_nuget_feed" "feed_b" {
  package_acquisition_location_options = ["ExecutionTarget", "NotAcquired"]
}
resource "octopusdeploy_maven_feed" "feed_c" {
  package_acquisition_location_options = ["NotAcquired"]
}"""
        result = fix_maven_feed_acquisition_options(config)
        self.assertEqual(result.count('["Server", "ExecutionTarget"]'), 2)
        self.assertEqual(result.count('["ExecutionTarget", "NotAcquired"]'), 1)
        self.assertNotIn('["NotAcquired"]', result)


class TestCheckTargetsAvailableTemplateUrl(unittest.TestCase):
    def test_replaces_block_release_progression_url(self):
        config = """data "octopusdeploy_community_step_template" "communitysteptemplate_check_targets_available" {
  website = "https://library.octopus.com/step-templates/78a182b3-5369-4e13-9292-b7f991295ad1"
}
data "octopusdeploy_community_step_template" "communitysteptemplate_block_release_progression" {
  website = "https://library.octopus.com/step-templates/78a182b3-5369-4e13-9292-b7f991295ad1"
}"""
        result = fix_check_targets_available_template_url(config)
        self.assertIn(f'website = "{CHECK_TARGETS_AVAILABLE_TEMPLATE_URL}"', result)
        self.assertEqual(result.count("78a182b3-5369-4e13-9292-b7f991295ad1"), 1)

    def test_leaves_correct_url_unchanged(self):
        config = f"""data "octopusdeploy_community_step_template" "communitysteptemplate_octopus___check_targets_available" {{
  website = "{CHECK_TARGETS_AVAILABLE_TEMPLATE_URL}"
}}"""
        self.assertEqual(fix_check_targets_available_template_url(config), config)

    def test_replaces_any_wrong_url_including_name_prefix(self):
        config = """data "octopusdeploy_community_step_template" "communitysteptemplate_octopus___check_targets_available" {
  website = "https://library.octopus.com/step-templates/00000000-0000-0000-0000-000000000000"
}"""
        result = fix_check_targets_available_template_url(config)
        self.assertIn(f'website = "{CHECK_TARGETS_AVAILABLE_TEMPLATE_URL}"', result)
        self.assertNotIn("00000000-0000-0000-0000-000000000000", result)

    def test_leaves_other_community_templates_unchanged(self):
        config = """data "octopusdeploy_community_step_template" "communitysteptemplate_scan_for_vulnerabilities" {
  website = "https://library.octopus.com/step-templates/a38bfff8-8dde-4dd6-9fd0-c90bb4709d5a"
}
data "octopusdeploy_step_template" "steptemplate_check_targets_available" {
  name = "Octopus - Check Targets Available"
}"""
        self.assertEqual(fix_check_targets_available_template_url(config), config)

    def test_only_rewrites_the_matching_block_when_followed_by_others(self):
        config = """data "octopusdeploy_community_step_template" "communitysteptemplate_check_targets_available" {
  website = "https://library.octopus.com/step-templates/78a182b3-5369-4e13-9292-b7f991295ad1"
}
data "octopusdeploy_community_step_template" "communitysteptemplate_scan_for_vulnerabilities" {
  website = "https://library.octopus.com/step-templates/a38bfff8-8dde-4dd6-9fd0-c90bb4709d5a"
}"""
        result = fix_check_targets_available_template_url(config)
        self.assertIn(CHECK_TARGETS_AVAILABLE_TEMPLATE_URL, result)
        self.assertIn("a38bfff8-8dde-4dd6-9fd0-c90bb4709d5a", result)
        self.assertNotIn("78a182b3-5369-4e13-9292-b7f991295ad1", result)


class TestCheckSmtpServerConfiguredTemplateUrl(unittest.TestCase):
    def test_replaces_invented_guid(self):
        config = """data "octopusdeploy_community_step_template" "communitysteptemplate_octopus___check_smtp_server_configured" {
  website = "https://library.octopus.com/step-templates/ad8126be-3f3b-4b3b-8b3b-3b3b3b3b3b3b"
}"""
        result = fix_check_smtp_server_configured_template_url(config)
        self.assertIn(f'website = "{CHECK_SMTP_SERVER_CONFIGURED_TEMPLATE_URL}"', result)
        self.assertNotIn("3b3b3b3b3b3b", result)

    def test_leaves_correct_url_unchanged(self):
        config = f"""data "octopusdeploy_community_step_template" "communitysteptemplate_octopus___check_smtp_server_configured" {{
  website = "{CHECK_SMTP_SERVER_CONFIGURED_TEMPLATE_URL}"
}}"""
        self.assertEqual(fix_check_smtp_server_configured_template_url(config), config)

    def test_leaves_other_templates_unchanged(self):
        config = """data "octopusdeploy_community_step_template" "communitysteptemplate_scan_for_vulnerabilities" {
  website = "https://library.octopus.com/step-templates/a38bfff8-8dde-4dd6-9fd0-c90bb4709d5a"
}
data "octopusdeploy_step_template" "steptemplate_octopus___check_smtp_server_configured" {
  name = "Octopus - Check SMTP Server Configured"
}"""
        self.assertEqual(fix_check_smtp_server_configured_template_url(config), config)


class TestDefaultGuidedFailureMode(unittest.TestCase):
    def test_replaces_invalid_default(self):
        config = 'default_guided_failure_mode       = "Default"'
        self.assertEqual(
            fix_default_guided_failure_mode(config),
            'default_guided_failure_mode       = "EnvironmentDefault"',
        )

    def test_replaces_other_invalid_values(self):
        for value in ["RetryAndFail", "", "on", "true"]:
            config = f'default_guided_failure_mode = "{value}"'
            self.assertEqual(
                fix_default_guided_failure_mode(config),
                'default_guided_failure_mode = "EnvironmentDefault"',
            )

    def test_leaves_valid_values_unchanged(self):
        for value in ["EnvironmentDefault", "On", "Off"]:
            config = f'default_guided_failure_mode = "{value}"'
            self.assertEqual(fix_default_guided_failure_mode(config), config)

    def test_does_not_touch_use_guided_failure(self):
        config = "use_guided_failure           = false"
        self.assertEqual(fix_default_guided_failure_mode(config), config)


class TestUnderscoreQuotedStrings(unittest.TestCase):
    def test_fixes_equals_comparison(self):
        config = 'count = "${length(try([for item in x.tags : item if item.name == _"Gold_"], [])) != 0 ? 0 : 1}"'
        self.assertEqual(
            fix_underscore_quoted_strings(config),
            'count = "${length(try([for item in x.tags : item if item.name == "Gold"], [])) != 0 ? 0 : 1}"',
        )

    def test_fixes_not_equals_comparison(self):
        self.assertEqual(
            fix_underscore_quoted_strings('a != _"b_"'), 'a != "b"'
        )

    def test_leaves_valid_comparisons_unchanged(self):
        config = 'item.name == "Gold" && other == "my_name_"'
        self.assertEqual(fix_underscore_quoted_strings(config), config)


class TestMultiLinePrimaryPackage(unittest.TestCase):
    def test_repairs_truncated_multi_line_primary_package(self):
        config = """  properties = {
  }
  "
    id                   = null
    package_id           = "storefront.web"
    properties           = { SelectionMode = "immediate" }
  }
  execution_properties = {"""
        result = sanitize_primary_package(config)
        self.assertIn(
            'primary_package = { acquisition_location = "Server"', result
        )
        self.assertIn('package_id = "storefront.web"', result)
        self.assertNotIn('\n  "\n', result)
        self.assertIn("execution_properties = {", result)

    def test_leaves_valid_multi_line_primary_package_unchanged(self):
        config = """  primary_package = {
    acquisition_location = "Server"
    id                   = null
    package_id           = "storefront.web"
    properties           = { SelectionMode = "immediate" }
  }"""
        self.assertEqual(sanitize_primary_package(config), config)


class TestRemovePrimaryPackage(unittest.TestCase):
    def test_removes_block_with_interpolated_feed_id(self):
        text = (
            '  primary_package = { acquisition_location = "Server", '
            'feed_id = "${length(a.feeds) != 0 ? a.feeds[0].id : b[0].id}", id = null, '
            'package_id = "storefront.web", properties = { SelectionMode = "immediate" } }\n'
            '  execution_properties = {}'
        )
        result = remove_primary_package(text)
        self.assertNotIn("primary_package", result)
        self.assertNotIn("package_id", result)
        self.assertNotIn('", id = null', result)
        self.assertIn("execution_properties = {}", result)

    def test_removes_multi_line_block_with_nested_properties(self):
        text = """  primary_package = {
    acquisition_location = "Server"
    id                   = null
    package_id           = "x"
    properties           = { SelectionMode = "immediate" }
  }
  next_attribute = "kept"
"""
        result = remove_primary_package(text)
        self.assertNotIn("primary_package", result)
        self.assertNotIn("package_id", result)
        self.assertIn('next_attribute = "kept"', result)
        self.assertEqual(result.count("{"), result.count("}"))

    def test_removes_empty_block_and_multiple_blocks(self):
        text = "primary_package = {}\nx = 1\nprimary_package = { a = 1 }\ny = 2"
        result = remove_primary_package(text)
        self.assertNotIn("primary_package", result)
        self.assertIn("x = 1", result)
        self.assertIn("y = 2", result)

    def test_leaves_unbalanced_block_unchanged(self):
        text = 'primary_package = { package_id = "x"'
        self.assertEqual(remove_primary_package(text), text)

    def test_inline_script_step_drops_a_primary_package_with_interpolation(self):
        config = """resource "octopusdeploy_process_step" "s" {
  name = "Deploy"
  primary_package = { acquisition_location = "Server", feed_id = "${length(a.feeds) != 0 ? a.feeds[0].id : b[0].id}", id = null, package_id = "storefront.web", properties = { SelectionMode = "immediate" } }
  execution_properties = {
    "Octopus.Action.Script.ScriptSource" = "Inline"
    "Octopus.Action.Script.ScriptBody" = "echo hi"
  }
}"""
        fixed = fix_script_source(config)
        self.assertNotIn("primary_package", fixed)
        self.assertNotIn("package_id", fixed)
        self.assertNotIn('", id = null', fixed)
        self.assertEqual(fixed.count("{"), fixed.count("}"))


class TestCommunityStepTemplateCount(unittest.TestCase):
    BROKEN = """data "octopusdeploy_step_template" "steptemplate_scan_for_vulnerabilities" {
  name = "Scan for Vulnerabilities"
}
data "octopusdeploy_community_step_template" "communitysteptemplate_scan_for_vulnerabilities" {
  website = "https://library.octopus.com/step-templates/a38bfff8-8dde-4dd6-9fd0-c90bb4709d5a"
}
resource "octopusdeploy_community_step_template" "communitysteptemplate_scan_for_vulnerabilities" {
  count = "${length(data.octopusdeploy_community_step_template.communitysteptemplate_scan_for_vulnerabilities.steps) != 0 ? 0 : 1}"
  community_action_template_id = "x"
}"""

    def test_fixes_count_to_test_the_space_step_template(self):
        result = fix_community_step_template_count(self.BROKEN)
        self.assertIn(
            'count = "${data.octopusdeploy_step_template.steptemplate_scan_for_vulnerabilities.step_template != null ? 0 : 1}"',
            result,
        )
        self.assertNotIn("!= 0 ? 0 : 1", result)
        self.assertIn('community_action_template_id = "x"', result)

    def test_leaves_correct_count_unchanged(self):
        config = self.BROKEN.replace(
            'count = "${length(data.octopusdeploy_community_step_template.communitysteptemplate_scan_for_vulnerabilities.steps) != 0 ? 0 : 1}"',
            'count = "${data.octopusdeploy_step_template.steptemplate_scan_for_vulnerabilities.step_template != null ? 0 : 1}"',
        )
        self.assertEqual(fix_community_step_template_count(config), config)

    def test_leaves_resource_without_matching_step_template_data_unchanged(self):
        config = """resource "octopusdeploy_community_step_template" "communitysteptemplate_other" {
  count = "${length(data.octopusdeploy_community_step_template.communitysteptemplate_other.steps) != 0 ? 0 : 1}"
}"""
        self.assertEqual(fix_community_step_template_count(config), config)

    def test_fixes_each_template_independently(self):
        second = self.BROKEN.replace("scan_for_vulnerabilities", "check_targets_available")
        result = fix_community_step_template_count(self.BROKEN + "\n" + second)
        self.assertIn("steptemplate_scan_for_vulnerabilities.step_template != null", result)
        self.assertIn("steptemplate_check_targets_available.step_template != null", result)


class TestEscapeBareInterpolations(unittest.TestCase):
    def test_escapes_bare_identifier(self):
        config = 'value = "Environment = \\"${TF_VAR_region}\\""'
        self.assertEqual(
            escape_bare_interpolations(config),
            'value = "Environment = \\"$${TF_VAR_region}\\""',
        )

    def test_leaves_attribute_references_unchanged(self):
        config = 'x = "${var.name}" y = "${data.a.b.c[0].id}" z = "${length(a)}"'
        self.assertEqual(escape_bare_interpolations(config), config)

    def test_does_not_double_escape(self):
        config = 'x = "$${TF_VAR_region}"'
        self.assertEqual(escape_bare_interpolations(config), config)

    def test_leaves_for_expression_iterator_unchanged(self):
        config = 'x = [for item in var.items : "${item}"]'
        self.assertEqual(escape_bare_interpolations(config), config)

    def test_leaves_octostache_unchanged(self):
        config = 'x = "#{Octopus.Environment.Name}" y = "#{TF_VAR_region}"'
        self.assertEqual(escape_bare_interpolations(config), config)

    def test_converts_octopus_variable_to_octostache(self):
        config = 'name = "www.${DNS.Zone}" other = "${Project.Db.Host}"'
        self.assertEqual(
            escape_bare_interpolations(config),
            'name = "www.#{DNS.Zone}" other = "#{Project.Db.Host}"',
        )

    def test_octopus_variable_conversion_leaves_terraform_references(self):
        config = 'a = "${var.zone}" b = "${local.name}" c = "${octopusdeploy_environment.e.id}" d = "$${DNS.Zone}"'
        self.assertEqual(escape_bare_interpolations(config), config)


class TestRemoveWorkerPoolFromTargetSteps(unittest.TestCase):
    TARGET_STEP = """resource "octopusdeploy_process_step" "s" {
  name                 = "Apply"
  worker_pool_variable = "Project.WorkerPool"
  properties = {
    "Octopus.Action.TargetRoles" = "terraform-runner"
  }
  execution_properties = {
    "Octopus.Action.RunOnServer" = "false"
  }
}"""

    def test_removes_worker_pool_from_a_target_step(self):
        result = remove_worker_pool_from_target_steps(self.TARGET_STEP)
        self.assertNotIn("worker_pool_variable", result)
        self.assertIn('"Octopus.Action.TargetRoles" = "terraform-runner"', result)
        self.assertEqual(result.count("{"), result.count("}"))

    def test_removes_worker_pool_id(self):
        config = self.TARGET_STEP.replace(
            'worker_pool_variable = "Project.WorkerPool"', 'worker_pool_id = "WorkerPools-1"'
        )
        self.assertNotIn("worker_pool_id", remove_worker_pool_from_target_steps(config))

    def test_keeps_worker_pool_on_a_server_step(self):
        config = self.TARGET_STEP.replace(
            '"Octopus.Action.RunOnServer" = "false"', '"Octopus.Action.RunOnServer" = "true"'
        )
        self.assertEqual(remove_worker_pool_from_target_steps(config), config)

    def test_only_changes_the_target_step_when_followed_by_others(self):
        server_step = self.TARGET_STEP.replace(
            '"Octopus.Action.RunOnServer" = "false"', '"Octopus.Action.RunOnServer" = "true"'
        ).replace('resource "octopusdeploy_process_step" "s"', 'resource "octopusdeploy_process_step" "t"')
        result = remove_worker_pool_from_target_steps(self.TARGET_STEP + "\n" + server_step)
        self.assertEqual(result.count("worker_pool_variable"), 1)

    def test_removes_the_worker_container_from_a_target_step(self):
        config = self.TARGET_STEP.replace(
            '  name                 = "Apply"',
            '  name                 = "Apply"\n  container = { dockerfile = null, feed_id = "${length(a.feeds) != 0 ? a.feeds[0].id : b[0].id}", git_url = null, image = "ghcr.io/x/terraform-workertools" }',
        )
        result = remove_worker_pool_from_target_steps(config)
        self.assertNotIn("container", result)
        self.assertNotIn("workertools", result)
        self.assertIn('"Octopus.Action.TargetRoles" = "terraform-runner"', result)
        self.assertEqual(result.count("{"), result.count("}"))

    def test_removes_a_multi_line_worker_container(self):
        config = self.TARGET_STEP.replace(
            '  name                 = "Apply"',
            '  name                 = "Apply"\n  container = {\n    image = "x"\n    feed_id = "y"\n  }',
        )
        result = remove_worker_pool_from_target_steps(config)
        self.assertNotIn("container", result)
        self.assertEqual(result.count("{"), result.count("}"))

    def test_keeps_the_container_on_a_server_step(self):
        config = self.TARGET_STEP.replace(
            '  name                 = "Apply"',
            '  name                 = "Apply"\n  container = { image = "x", feed_id = "y" }',
        ).replace(
            '"Octopus.Action.RunOnServer" = "false"', '"Octopus.Action.RunOnServer" = "true"'
        )
        self.assertEqual(remove_worker_pool_from_target_steps(config), config)

    def test_does_not_remove_attributes_that_only_end_with_container(self):
        config = self.TARGET_STEP.replace(
            '  name                 = "Apply"',
            '  name                 = "Apply"\n  execution_container = { image = "x" }',
        )
        self.assertIn("execution_container", remove_worker_pool_from_target_steps(config))

    def test_ignores_other_resource_types(self):
        config = self.TARGET_STEP.replace("octopusdeploy_process_step", "octopusdeploy_other")
        self.assertEqual(remove_worker_pool_from_target_steps(config), config)


class TestRemoveBalancedAttribute(unittest.TestCase):
    def test_removes_attribute_with_nested_objects(self):
        text = 'a = 1\ncontainer = { x = { y = "${z}" } }\nb = 2'
        result = remove_balanced_attribute(text, CONTAINER_START_REGEX)
        self.assertEqual(result, "a = 1\n\nb = 2")

    def test_removes_every_match(self):
        text = "container = { a = 1 } container = { b = { c = 2 } } end"
        result = remove_balanced_attribute(text, CONTAINER_START_REGEX)
        self.assertNotIn("container", result)
        self.assertIn("end", result)

    def test_returns_text_unchanged_when_there_is_no_match(self):
        text = "a = { b = 1 }"
        self.assertEqual(remove_balanced_attribute(text, CONTAINER_START_REGEX), text)

    def test_returns_text_unchanged_when_unbalanced(self):
        text = "container = { a = { b = 1 }"
        self.assertEqual(remove_balanced_attribute(text, CONTAINER_START_REGEX), text)

    def test_container_regex_ignores_prefixed_names(self):
        text = "execution_container = { a = 1 }"
        self.assertEqual(remove_balanced_attribute(text, CONTAINER_START_REGEX), text)

    def test_worker_pool_removal_handles_empty_config(self):
        self.assertEqual(remove_worker_pool_from_target_steps(""), "")
        self.assertIsNone(remove_worker_pool_from_target_steps(None))


class TestEscapeCloudFormationPseudoParameters(unittest.TestCase):
    def test_escapes_aws_pseudo_parameter(self):
        config = "BucketName: !Sub '$${BucketPrefix}-logs-${AWS::AccountId}'"
        result = escape_bare_interpolations(config)
        self.assertEqual(
            result, "BucketName: !Sub '$${BucketPrefix}-logs-$${AWS::AccountId}'"
        )

    def test_already_escaped_pseudo_parameter_unchanged(self):
        config = "Region: $${AWS::Region}"
        self.assertEqual(escape_bare_interpolations(config), config)


if __name__ == "__main__":
    unittest.main()
