import sys
import unittest
from unittest.mock import MagicMock

try:
    import lxml.html.diff  # noqa: F401
except ImportError:
    for name in ("lxml", "lxml.html", "lxml.html.diff", "lxml.etree"):
        sys.modules[name] = MagicMock()

from domain.sanitizers.terraform import (  # noqa: E402
    add_missing_s3_package_options,
    move_release_notes_template_to_project,
    remove_duplicate_versioning_strategies,
    add_missing_target_role_to_package_steps,
    fix_bare_data_lookup_reference,
    fix_cloudformation_dotted_property_names,
    fix_arm_template_source,
    fix_empty_strings,
    fix_created_worker_pool_fallback,
    fix_for_expression_over_empty_lookup,
    fix_lifecycle_phase_without_environments,
    fix_manual_intervention_templated_step,
    fix_package_pre_deploy_script_property,
    fix_deployment_target_trigger_type,
    fix_trigger_event_categories,
    remove_worker_pool_from_package_steps_with_roles,
    fix_polling_tentacle_uri,
    fix_target_roles_list,
    fix_invalid_octopus_variable_type,
    fix_literal_variable_template_id,
    fix_lookup_worker_pool_default_fallback,
    fix_process_step_container_block,
    fix_project_description_heredoc,
    remove_unsupported_trigger_description,
    fix_trigger_primary_package_reference,
    fix_parenthesis_octopus_variable_syntax,
    fix_variable_condition_without_expression,
    fix_donor_package_attribute,
    escape_invalid_template_directives,
    add_run_on_server_to_worker_pool_steps,
    remove_steps_order_dependency_from_referenced_channels,
    remove_environments_when_excluded_environments_are_set,
    remove_unused_step_template_data,
    replace_json_key,
    replace_slash_in_project_name,
    replace_unverified_community_templated_step,
)

CREATED_POOL = """resource "octopusdeploy_static_worker_pool" "workerpool_dns_workers" {
  count = "${length(data.octopusdeploy_worker_pools.workerpool_dns_workers.worker_pools) != 0 ? 0 : 1}"
  name  = "DNS Workers"
}
"""

VARIABLE = """resource "octopusdeploy_variable" "project_worker_pool_1" {
  value = "${length(data.octopusdeploy_worker_pools.workerpool_dns_workers.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_dns_workers.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
}"""


class TestFixCreatedWorkerPoolFallback(unittest.TestCase):
    def test_falls_back_to_created_pool(self):
        result = fix_created_worker_pool_fallback(CREATED_POOL + VARIABLE)
        self.assertIn(
            ': octopusdeploy_static_worker_pool.workerpool_dns_workers[0].id}"', result
        )
        self.assertNotIn("workerpool_default_worker_pool", result)

    def test_leaves_lookup_only_pool_unchanged(self):
        config = VARIABLE.replace("workerpool_dns_workers", "workerpool_hosted_ubuntu")
        self.assertEqual(fix_created_worker_pool_fallback(config), config)

    def test_leaves_created_pool_without_default_fallback(self):
        config = (
            CREATED_POOL
            + 'value = "${octopusdeploy_static_worker_pool.workerpool_dns_workers[0].id}"'
        )
        self.assertEqual(fix_created_worker_pool_fallback(config), config)


class TestFixLookupWorkerPoolDefaultFallback(unittest.TestCase):
    LOOKUP = """resource "octopusdeploy_process_step" "s" {
  worker_pool_id = "${length(data.octopusdeploy_worker_pools.workerpool_gcp_workers.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_gcp_workers.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
}
"""

    def test_lookup_only_pool_falls_back_to_hosted_ubuntu(self):
        result = fix_lookup_worker_pool_default_fallback(self.LOOKUP)
        self.assertIn(
            ': data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id}"',
            result,
        )
        self.assertNotIn("workerpool_default_worker_pool", result)

    def test_adds_hosted_ubuntu_data_source_once(self):
        result = fix_lookup_worker_pool_default_fallback(self.LOOKUP)
        self.assertEqual(
            result.count(
                'data "octopusdeploy_worker_pools" "workerpool_hosted_ubuntu"'
            ),
            1,
        )
        self.assertIn('partial_name = "Hosted Ubuntu"', result)

    def test_keeps_existing_hosted_ubuntu_data_source(self):
        config = (
            'data "octopusdeploy_worker_pools" "workerpool_hosted_ubuntu" {\n}\n'
            + self.LOOKUP
        )
        result = fix_lookup_worker_pool_default_fallback(config)
        self.assertEqual(
            result.count(
                'data "octopusdeploy_worker_pools" "workerpool_hosted_ubuntu"'
            ),
            1,
        )

    def test_hosted_ubuntu_lookup_does_not_fall_back_to_itself(self):
        config = VARIABLE.replace("workerpool_dns_workers", "workerpool_hosted_ubuntu")
        self.assertEqual(fix_lookup_worker_pool_default_fallback(config), config)

    def test_created_pool_unchanged(self):
        config = CREATED_POOL + VARIABLE
        self.assertEqual(fix_lookup_worker_pool_default_fallback(config), config)

    def test_other_lookups_unchanged(self):
        config = 'value = "${data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"'
        self.assertEqual(fix_lookup_worker_pool_default_fallback(config), config)


class TestFixProcessStepContainerBlock(unittest.TestCase):
    STEP = """resource "octopusdeploy_process_step" "s" {
  name = "Deploy"
  container {
    feed_id = "${length(data.octopusdeploy_feeds.f.feeds) != 0 ? data.octopusdeploy_feeds.f.feeds[0].id : octopusdeploy_docker_container_registry.f[0].id}"
    image   = "ghcr.io/octopusdeploylabs/gcp-workertools"
  }
  properties = {}
}
"""

    def test_block_becomes_attribute(self):
        result = fix_process_step_container_block(self.STEP)
        self.assertIn(
            '  container = { dockerfile = null, feed_id = "${length(data.octopusdeploy_feeds.f.feeds) != 0 ? '
            'data.octopusdeploy_feeds.f.feeds[0].id : octopusdeploy_docker_container_registry.f[0].id}", '
            'git_url = null, image = "ghcr.io/octopusdeploylabs/gcp-workertools" }',
            result,
        )
        self.assertNotIn("container {", result)
        self.assertIn("properties = {}", result)

    def test_unindented_nested_blocks(self):
        config = (
            'resource "octopusdeploy_process_step" "s" {\nname = "A"\nexecution_properties = {\n"k" = "v"\n}\n'
            'container {\nfeed_id = "f"\nimage = "i"\n}\n}\n'
            'resource "octopusdeploy_process_step" "t" {\nname = "B"\ncontainer {\nfeed_id = "g"\nimage = "j"\n}\n}\n'
        )
        result = fix_process_step_container_block(config)
        self.assertIn(
            'container = { dockerfile = null, feed_id = "f", git_url = null, image = "i" }',
            result,
        )
        self.assertIn(
            'container = { dockerfile = null, feed_id = "g", git_url = null, image = "j" }',
            result,
        )
        self.assertNotIn("container {", result)
        self.assertIn('"k" = "v"', result)

    def test_attribute_form_unchanged(self):
        attribute = (
            'resource "octopusdeploy_process_step" "s" {\n'
            '  container = { dockerfile = null, feed_id = "f", git_url = null, image = "i" }\n}\n'
        )
        self.assertEqual(fix_process_step_container_block(attribute), attribute)

    def test_other_resources_unchanged(self):
        config = 'resource "octopusdeploy_project" "p" {\n  container {\n    image = "i"\n  }\n}\n'
        self.assertEqual(fix_process_step_container_block(config), config)


class TestFixProjectDescriptionHeredoc(unittest.TestCase):
    PROJECT = """resource "octopusdeploy_project" "p" {
  name        = "P"
  description = <<-EOT
    # Title
    A "quoted" line with ${var.x}
    ## Heading
    EOT
  lifecycle {
    prevent_destroy = true
  }
}
"""

    def test_heredoc_becomes_quoted_string(self):
        result = fix_project_description_heredoc(self.PROJECT)
        self.assertIn(
            '  description = "# Title\\nA \\"quoted\\" line with $${var.x}\\n## Heading"',
            result,
        )
        self.assertNotIn("<<", result)
        self.assertIn("prevent_destroy = true", result)

    def test_unindented_heredoc(self):
        config = 'resource "octopusdeploy_project" "p" {\n  description = <<EOT\nLine one\nLine two\nEOT\n}\n'
        self.assertIn(
            'description = "Line one\\nLine two"',
            fix_project_description_heredoc(config),
        )

    def test_unindented_nested_blocks(self):
        config = (
            'resource "octopusdeploy_project" "p" {\ncount = 1\nconnectivity_policy {\ntarget_roles = []\n}\n'
            "description = <<-EOT\n# Title\nBody\nEOT\nlifecycle {\nprevent_destroy = true\n}\n}\n"
            'resource "octopusdeploy_project_group" "g" {\ndescription = <<EOT\nKeep\nEOT\n}\n'
        )
        result = fix_project_description_heredoc(config)
        self.assertIn('description = "# Title\\nBody"', result)
        self.assertIn("description = <<EOT\nKeep\nEOT", result)

    def test_other_resources_unchanged(self):
        config = 'resource "octopusdeploy_project_group" "g" {\n  description = <<EOT\nText\nEOT\n}\n'
        self.assertEqual(fix_project_description_heredoc(config), config)

    def test_quoted_description_unchanged(self):
        config = 'resource "octopusdeploy_project" "p" {\n  description = "Plain"\n}\n'
        self.assertEqual(fix_project_description_heredoc(config), config)


class TestFixForExpressionOverEmptyLookup(unittest.TestCase):
    def test_wraps_indexed_lookup_in_try(self):
        config = (
            "locals {\n"
            '  tagset_market_tag_eu_matches = [for item in data.octopusdeploy_tag_sets.tagset_market_data.tag_sets[0].tags : item if item.name == "EU"]\n'
            "}\n"
        )
        self.assertIn(
            "[for item in try(data.octopusdeploy_tag_sets.tagset_market_data.tag_sets[0].tags, []) : item if item.name",
            fix_for_expression_over_empty_lookup(config),
        )

    def test_unindexed_for_unchanged(self):
        config = 'x = [for ts in data.octopusdeploy_tag_sets.t.tag_sets : ts if ts.name == "Market"]'
        self.assertEqual(fix_for_expression_over_empty_lookup(config), config)

    def test_already_wrapped_unchanged(self):
        config = (
            "x = [for i in try(data.octopusdeploy_tag_sets.t.tag_sets[0].tags, []) : i]"
        )
        self.assertEqual(fix_for_expression_over_empty_lookup(config), config)


class TestFixManualInterventionTemplatedStep(unittest.TestCase):
    STEP = """resource "octopusdeploy_process_templated_step" "process_step_x_promote_check" {
count = "${length(data.octopusdeploy_projects.p.projects) != 0 ? 0 : 1}"
name                  = "Promote Check"
process_id            = "${octopusdeploy_process.x[0].id}"
template_id            = "${data.octopusdeploy_step_template.steptemplate_manual_intervention.step_template != null ? data.octopusdeploy_step_template.steptemplate_manual_intervention.step_template.id : null}"
template_version       = "${data.octopusdeploy_step_template.steptemplate_manual_intervention.step_template != null ? data.octopusdeploy_step_template.steptemplate_manual_intervention.step_template.version : null}"
condition             = "Success"
execution_properties   = {
"Octopus.Action.Manual.Instructions" = "Check"
}
}
resource "octopusdeploy_process_steps_order" "o" {
steps = ["${octopusdeploy_process_templated_step.process_step_x_promote_check[0].id}"]
}
"""

    def test_becomes_manual_process_step(self):
        result = fix_manual_intervention_templated_step(self.STEP)
        self.assertIn(
            'resource "octopusdeploy_process_step" "process_step_x_promote_check"',
            result,
        )
        self.assertIn('type                  = "Octopus.Manual"', result)
        self.assertNotIn("template_id", result)
        self.assertNotIn("template_version", result)
        self.assertNotIn("step_template", result)
        self.assertIn("execution_properties   = {", result)

    def test_updates_references(self):
        result = fix_manual_intervention_templated_step(self.STEP)
        self.assertIn(
            "octopusdeploy_process_step.process_step_x_promote_check[0].id", result
        )
        self.assertNotIn("octopusdeploy_process_templated_step", result)

    def test_real_templated_step_unchanged(self):
        config = (
            'resource "octopusdeploy_process_templated_step" "s" {\n'
            '  template_id = "${octopusdeploy_step_template.t.id}"\n}\n'
        )
        self.assertEqual(fix_manual_intervention_templated_step(config), config)


class TestCloudFormationTemplatedStep(unittest.TestCase):
    CONFIG = """data "octopusdeploy_step_template" "steptemplate_aws_cloudformation_deploy" {
name = "Deploy an AWS CloudFormation template"
}
data "octopusdeploy_community_step_template" "communitysteptemplate_aws_cloudformation_deploy" {
website = "https://library.octopus.com/step-templates/a38bfff8"
}
resource "octopusdeploy_community_step_template" "communitysteptemplate_aws_cloudformation_deploy" {
community_action_template_id = "${length(data.octopusdeploy_community_step_template.communitysteptemplate_aws_cloudformation_deploy.steps) != 0 ? data.octopusdeploy_community_step_template.communitysteptemplate_aws_cloudformation_deploy.steps[0].id : null}"
count = "${data.octopusdeploy_step_template.steptemplate_aws_cloudformation_deploy.step_template != null ? 0 : 1}"
}
resource "octopusdeploy_process_templated_step" "process_step_x_create_bucket_stack" {
name = "Create Bucket Stack"
template_id = "${data.octopusdeploy_step_template.steptemplate_aws_cloudformation_deploy.step_template != null ? data.octopusdeploy_step_template.steptemplate_aws_cloudformation_deploy.step_template.id : octopusdeploy_community_step_template.communitysteptemplate_aws_cloudformation_deploy[0].id}"
template_version = "${data.octopusdeploy_step_template.steptemplate_aws_cloudformation_deploy.step_template != null ? data.octopusdeploy_step_template.steptemplate_aws_cloudformation_deploy.step_template.version : octopusdeploy_community_step_template.communitysteptemplate_aws_cloudformation_deploy[0].version}"
execution_properties = {
"Octopus.Action.Aws.Region" = "eu-west-2"
}
parameters = {
"Sbom.Package" = jsonencode({
"PackageId" = ""
})
}
}
"""

    def test_becomes_cloudformation_process_step(self):
        result = remove_unused_step_template_data(
            fix_manual_intervention_templated_step(self.CONFIG)
        )
        self.assertIn(
            'resource "octopusdeploy_process_step" "process_step_x_create_bucket_stack"',
            result,
        )
        self.assertIn('type                  = "Octopus.AwsRunCloudFormation"', result)
        self.assertIn('"Octopus.Action.Aws.Region" = "eu-west-2"', result)
        self.assertNotIn("template_id", result)
        self.assertNotIn("Sbom.Package", result)
        self.assertNotIn("parameters =", result)

    def test_removes_the_template_lookups(self):
        result = remove_unused_step_template_data(
            fix_manual_intervention_templated_step(self.CONFIG)
        )
        self.assertNotIn("octopusdeploy_step_template", result)
        self.assertNotIn("octopusdeploy_community_step_template", result)

    def test_referenced_community_template_kept(self):
        config = (
            'data "octopusdeploy_community_step_template" "t" {\nwebsite = "w"\n}\n'
            'resource "octopusdeploy_community_step_template" "t" {\ncommunity_action_template_id = "x"\n}\n'
            'resource "octopusdeploy_process_templated_step" "s" {\n'
            'template_id = "${octopusdeploy_community_step_template.t.id}"\n}\n'
        )
        self.assertEqual(remove_unused_step_template_data(config), config)


class TestRemoveUnsupportedTriggerDescription(unittest.TestCase):
    TRIGGER = """resource "octopusdeploy_external_feed_create_release_trigger" "t" {
count       = "${length(data.octopusdeploy_projects.p.projects) != 0 ? 0 : 1}"
name        = "Package Push Trigger"
description = "Creates a release automatically."
channel_id  = "${octopusdeploy_channel.c.id}"
package {
deployment_action_slug = "deploy"
package_reference      = "pkg"
}
}
resource "octopusdeploy_project" "p" {
description = "Keep me"
}
"""

    def test_removes_description_argument(self):
        result = remove_unsupported_trigger_description(self.TRIGGER)
        self.assertNotIn("Creates a release automatically", result)
        self.assertIn('name        = "Package Push Trigger"', result)
        self.assertIn('package_reference      = "pkg"', result)

    def test_leaves_other_resources(self):
        result = remove_unsupported_trigger_description(self.TRIGGER)
        self.assertIn('description = "Keep me"', result)

    def test_no_trigger_unchanged(self):
        config = 'resource "octopusdeploy_project" "p" {\ndescription = "x"\n}\n'
        self.assertEqual(remove_unsupported_trigger_description(config), config)


class TestRemoveUnusedStepTemplateData(unittest.TestCase):
    DATA = """data "octopusdeploy_step_template" "steptemplate_manual_intervention" {
name = "Manual Intervention"
}
"""

    def test_removes_unreferenced_data_source(self):
        result = remove_unused_step_template_data(
            self.DATA + 'resource "octopusdeploy_project" "p" {\n}\n'
        )
        self.assertNotIn("octopusdeploy_step_template", result)
        self.assertIn('resource "octopusdeploy_project" "p"', result)

    def test_keeps_referenced_data_source(self):
        config = self.DATA + (
            'x = "${data.octopusdeploy_step_template.steptemplate_manual_intervention.step_template.id}"\n'
        )
        self.assertEqual(remove_unused_step_template_data(config), config)


class TestReplaceSlashInProjectName(unittest.TestCase):
    def test_variable_default_slash_becomes_dash(self):
        config = 'variable "project_unicode_shop_name" {\n  type = string\n  default = "Shop (EU/US) v3"\n}\n'
        self.assertIn(
            'default = "Shop (EU-US) v3"', replace_slash_in_project_name(config)
        )

    def test_literal_resource_name_slash_becomes_dash(self):
        config = 'resource "octopusdeploy_project" "p" {\n  count = 1\n  name = "A/B Project"\n  description = "x/y"\n}\n'
        result = replace_slash_in_project_name(config)
        self.assertIn('name = "A-B Project"', result)
        self.assertIn('description = "x/y"', result)

    def test_project_group_name_unchanged(self):
        config = (
            'variable "project_group_rd_labs_name" {\n  default = "R&D / Labs"\n}\n'
        )
        self.assertEqual(replace_slash_in_project_name(config), config)

    def test_reference_name_unchanged(self):
        config = 'resource "octopusdeploy_project" "p" {\n  name = "${var.project_p_name}"\n}\n'
        self.assertEqual(replace_slash_in_project_name(config), config)

    def test_name_without_slash_unchanged(self):
        config = 'variable "project_p_name" {\n  default = "Plain Project"\n}\n'
        self.assertEqual(replace_slash_in_project_name(config), config)


class TestFixLifecyclePhaseWithoutEnvironments(unittest.TestCase):
    ENVIRONMENTS = """locals {
environment_sandbox_matches = [for env in data.octopusdeploy_environments.environment_sandbox.environments : env if env.name == "Sandbox"]
}
resource "octopusdeploy_environment" "environment_sandbox" {
count = "${length(local.environment_sandbox_matches) != 0 ? 0 : 1}"
name  = "Sandbox"
lifecycle {
prevent_destroy = true
}
}
resource "octopusdeploy_environment" "environment_corp" {
name  = "Corp"
description = ""
}
"""
    LIFECYCLE = """resource "octopusdeploy_lifecycle" "lifecycle_landing_lifecycle" {
name = "Landing Lifecycle"
phase {
name                                    = "Sandbox"
automatic_deployment_targets            = []
optional_deployment_targets             = []
is_optional_phase                       = false
}
phase {
name                                    = "Corp"
automatic_deployment_targets            = []
optional_deployment_targets             = []
is_optional_phase                       = false
}
}
"""

    def test_empty_phases_get_their_environments(self):
        result = fix_lifecycle_phase_without_environments(
            self.ENVIRONMENTS + self.LIFECYCLE
        )
        self.assertIn(
            'optional_deployment_targets = ["${length(local.environment_sandbox_matches) != 0 ? '
            'local.environment_sandbox_matches[0].id : octopusdeploy_environment.environment_sandbox[0].id}"]',
            result,
        )
        self.assertIn(
            'optional_deployment_targets = ["${octopusdeploy_environment.environment_corp.id}"]',
            result,
        )
        self.assertNotIn("optional_deployment_targets             = []", result)

    def test_phase_with_environment_unchanged(self):
        lifecycle = self.LIFECYCLE.replace(
            'automatic_deployment_targets            = []\noptional_deployment_targets             = []\nis_optional_phase                       = false\n}\nphase {\nname                                    = "Corp"',
            'automatic_deployment_targets            = ["${octopusdeploy_environment.environment_sandbox[0].id}"]\noptional_deployment_targets             = []\nis_optional_phase                       = false\n}\nphase {\nname                                    = "Corp"',
        )
        result = fix_lifecycle_phase_without_environments(self.ENVIRONMENTS + lifecycle)
        self.assertIn(
            'automatic_deployment_targets            = ["${octopusdeploy_environment.environment_sandbox[0].id}"]',
            result,
        )
        self.assertEqual(result.count("environment_sandbox_matches) != 0 ? local"), 0)

    def test_phase_without_matching_environment_unchanged(self):
        config = self.LIFECYCLE
        self.assertEqual(fix_lifecycle_phase_without_environments(config), config)

    def test_no_lifecycle_unchanged(self):
        self.assertEqual(
            fix_lifecycle_phase_without_environments(self.ENVIRONMENTS),
            self.ENVIRONMENTS,
        )


class TestFixArmTemplateSource(unittest.TestCase):
    STEP = """resource "octopusdeploy_process_step" "s" {
name = "Deploy Network"
type = "Octopus.AzureResourceGroup"
execution_properties = {
"Octopus.Action.Azure.ResourceGroupName" = "rg"
"Octopus.Action.Azure.ResourceGroupTemplate" = jsonencode({
"contentVersion" = "1.0.0.0"
})
}
}
"""

    def test_adds_inline_template_source(self):
        result = fix_arm_template_source(self.STEP)
        self.assertIn(
            'execution_properties = {\n  "Octopus.Action.Azure.TemplateSource" = "Inline"\n',
            result,
        )
        self.assertEqual(result.count("TemplateSource"), 1)

    def test_existing_template_source_unchanged(self):
        config = self.STEP.replace(
            "execution_properties = {\n",
            'execution_properties = {\n"Octopus.Action.Azure.TemplateSource" = "Inline"\n',
        )
        self.assertEqual(fix_arm_template_source(config), config)

    def test_other_step_types_unchanged(self):
        config = self.STEP.replace("Octopus.AzureResourceGroup", "Octopus.Script")
        self.assertEqual(fix_arm_template_source(config), config)

    def test_step_without_template_unchanged(self):
        config = self.STEP.replace(
            '"Octopus.Action.Azure.ResourceGroupTemplate"',
            '"Octopus.Action.Azure.Other"',
        )
        self.assertEqual(fix_arm_template_source(config), config)


class TestFixPackagePreDeployScriptProperty(unittest.TestCase):
    def test_renames_vanishing_property(self):
        config = '"Octopus.Action.Script.PreDeployPackageOnWorker" = "echo pre"\n"Octopus.Action.Script.PostDeployPackageOnWorker" = "echo post"'
        result = fix_package_pre_deploy_script_property(config)
        self.assertIn('"Octopus.Action.Script.PrePackageOnWorker" = "echo pre"', result)
        self.assertIn(
            '"Octopus.Action.Script.PostDeployPackageOnWorker" = "echo post"', result
        )
        self.assertNotIn("PreDeployPackageOnWorker", result)

    def test_unrelated_config_unchanged(self):
        config = '"Octopus.Action.Script.ScriptBody" = "echo"'
        self.assertEqual(fix_package_pre_deploy_script_property(config), config)


class TestReplaceJsonKey(unittest.TestCase):
    def test_replaces_escaped_json_key(self):
        config = 'json_key = "{\\"type\\":\\"service_account\\"}"\n  lifecycle {}'
        self.assertEqual(
            replace_json_key(config), 'json_key = "Change Me!"\n  lifecycle {}'
        )

    def test_leaves_ignore_changes_reference(self):
        config = "ignore_changes = [json_key]"
        self.assertEqual(replace_json_key(config), config)


class TestFixInvalidOctopusVariableType(unittest.TestCase):
    TOKEN_VARIABLE = """resource "octopusdeploy_variable" "k8s" {
  name  = "Project.Kubernetes.Account"
  type  = "Token"
  value = "${octopusdeploy_token_account.a.id}"
}
"""

    def test_token_becomes_string(self):
        result = fix_invalid_octopus_variable_type(self.TOKEN_VARIABLE)
        self.assertIn('type  = "String"', result)
        self.assertNotIn("Token", result.replace("token_account", ""))

    def test_valid_types_unchanged(self):
        config = self.TOKEN_VARIABLE.replace('"Token"', '"AmazonWebServicesAccount"')
        self.assertEqual(fix_invalid_octopus_variable_type(config), config.rstrip("\n"))

    def test_other_resources_unchanged(self):
        config = 'resource "octopusdeploy_token_account" "a" {\n  type = "Token"\n}\n'
        self.assertEqual(fix_invalid_octopus_variable_type(config), config.rstrip("\n"))


class TestFixLiteralVariableTemplateId(unittest.TestCase):
    COMMON = """resource "octopusdeploy_tenant_common_variable" "t" {
  library_variable_set_id = "${octopusdeploy_library_variable_set.doctor_shared[0].id}"
  template_id             = "92734dee-9480-4f4f-8c58-f2c8f9c221ef"
  tenant_id               = "${octopusdeploy_tenant.a[0].id}"
  value                   = "30"
}
"""

    def test_common_variable_uses_library_set_template(self):
        result = fix_literal_variable_template_id(self.COMMON)
        self.assertIn(
            '"${octopusdeploy_library_variable_set.doctor_shared[0].template[0].id}"',
            result,
        )
        self.assertNotIn("92734dee", result)

    def test_project_variable_uses_project_template(self):
        config = (
            'resource "octopusdeploy_tenant_project_variable" "t" {\n'
            '  project_id  = "${octopusdeploy_project.p[0].id}"\n'
            '  template_id = "abc-123"\n}\n'
        )
        self.assertIn(
            '"${octopusdeploy_project.p[0].template[0].id}"',
            fix_literal_variable_template_id(config),
        )

    def test_reference_template_id_unchanged(self):
        config = self.COMMON.replace(
            '"92734dee-9480-4f4f-8c58-f2c8f9c221ef"',
            '"${octopusdeploy_library_variable_set.doctor_shared[0].template[1].id}"',
        )
        self.assertEqual(fix_literal_variable_template_id(config), config.rstrip("\n"))


class TestFixBareDataLookupReference(unittest.TestCase):
    FEED = """resource "octopusdeploy_maven_feed" "feed_octopus_maven_feed" {
  count = "${length(data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds) != 0 ? 0 : 1}"
  name  = "Octopus Maven Feed"
}
"""

    def test_bare_reference_becomes_lookup_or_create(self):
        config = (
            self.FEED
            + 'feed_id = "${data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds[0].id}"'
        )
        result = fix_bare_data_lookup_reference(config)
        self.assertIn(
            'feed_id = "${length(data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds) != 0 ? '
            "data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds[0].id : "
            'octopusdeploy_maven_feed.feed_octopus_maven_feed[0].id}"',
            result,
        )

    def test_lookup_without_creating_resource_unchanged(self):
        config = 'feed_id = "${data.octopusdeploy_feeds.feed_builtin.feeds[0].id}"'
        self.assertEqual(fix_bare_data_lookup_reference(config), config)

    def test_existing_ternary_unchanged(self):
        config = self.FEED + (
            'feed_id = "${length(data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds) != 0 ? '
            "data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds[0].id : "
            'octopusdeploy_maven_feed.feed_octopus_maven_feed[0].id}"'
        )
        self.assertEqual(fix_bare_data_lookup_reference(config), config)


class TestFixEmptyUsername(unittest.TestCase):
    def test_removes_empty_feed_username(self):
        config = 'resource "octopusdeploy_nuget_feed" "f" {\n  name = "F"\n  username = ""\n  password = "x"\n}'
        result = fix_empty_strings(config)
        self.assertNotIn("username", result)
        self.assertIn('password = "x"', result)

    def test_keeps_populated_and_prefixed_usernames(self):
        config = 'username = "feeduser"\nregistry_username = ""'
        self.assertEqual(fix_empty_strings(config), config)


ARGO_CONFIG = """resource "octopusdeploy_process_templated_step" "process_step_wait_for_argo" {
  name = "Wait For Argo"
  template_id = "${data.octopusdeploy_step_template.steptemplate_verify_argo.step_template != null ? data.octopusdeploy_step_template.steptemplate_verify_argo.step_template.id : octopusdeploy_community_step_template.communitysteptemplate_verify_argo[0].id}"
  template_version = "1"
  notes = "Waits"
  parameters = {
    "ArgoCD.ApplicationName" = "gateway"
  }
  execution_properties = {
    "Octopus.Action.RunOnServer" = "true"
  }
}
data "octopusdeploy_step_template" "steptemplate_verify_argo" {
  name = "Verify Argo CD Application Healthy"
}
data "octopusdeploy_community_step_template" "communitysteptemplate_verify_argo" {
  website = "https://library.octopus.com/step-templates/WEBSITE_GUID"
}
resource "octopusdeploy_community_step_template" "communitysteptemplate_verify_argo" {
  count = "${data.octopusdeploy_step_template.steptemplate_verify_argo.step_template != null ? 0 : 1}"
  community_action_template_id = "${data.octopusdeploy_community_step_template.communitysteptemplate_verify_argo.steps[0].id}"
}
"""


class TestReplaceUnverifiedCommunityTemplatedStep(unittest.TestCase):
    def test_fabricated_guid_becomes_script_step(self):
        config = ARGO_CONFIG.replace(
            "WEBSITE_GUID", "8f3e3e3e-3e3e-3e3e-3e3e-3e3e3e3e3e3e"
        )
        result = remove_unused_step_template_data(
            replace_unverified_community_templated_step(config)
        )
        self.assertIn(
            'resource "octopusdeploy_process_step" "process_step_wait_for_argo"', result
        )
        self.assertIn('type                  = "Octopus.Script"', result)
        self.assertIn('notes = "Waits"', result)
        self.assertNotIn("process_templated_step", result)
        self.assertNotIn("template_id", result)
        self.assertNotIn("ArgoCD.ApplicationName", result)
        self.assertNotIn("community_step_template", result)
        self.assertNotIn("octopusdeploy_step_template", result)
        self.assertEqual(result.count("{"), result.count("}"))

    def test_real_guid_is_left_alone(self):
        config = ARGO_CONFIG.replace(
            "WEBSITE_GUID", "78a182b3-5369-4e13-9292-b7f991295ad1"
        )
        self.assertEqual(replace_unverified_community_templated_step(config), config)

    def test_other_templated_steps_are_left_alone(self):
        config = ARGO_CONFIG.replace(
            "WEBSITE_GUID", "8f3e3e3e-3e3e-3e3e-3e3e-3e3e3e3e3e3e"
        )
        other = config + config.split("data ")[0].replace(
            "verify_argo", "slack"
        ).replace("wait_for_argo", "slack")
        result = replace_unverified_community_templated_step(other)
        self.assertIn(
            'resource "octopusdeploy_process_templated_step" "process_step_slack"',
            result,
        )
        self.assertIn(
            'resource "octopusdeploy_process_step" "process_step_wait_for_argo"', result
        )

    def test_empty_config(self):
        self.assertEqual(replace_unverified_community_templated_step(""), "")


class TestFixCloudformationDottedPropertyNames(unittest.TestCase):
    def test_renames_dotted_stack_name_and_template(self):
        config = (
            '"Octopus.Action.Aws.CloudFormation.StackName" = "web-stack"\n'
            '"Octopus.Action.Aws.CloudFormation.Template" = "Resources: {}"\n'
            '"Octopus.Action.Aws.CloudFormation.TemplateParameters" = "[]"\n'
        )
        result = fix_cloudformation_dotted_property_names(config)
        self.assertIn('"Octopus.Action.Aws.CloudFormationStackName" = "web-stack"', result)
        self.assertIn('"Octopus.Action.Aws.CloudFormationTemplate" = "Resources: {}"', result)
        self.assertIn('"Octopus.Action.Aws.CloudFormationTemplateParameters" = "[]"', result)
        self.assertNotIn("CloudFormation.", result)

    def test_leaves_valid_properties_alone(self):
        config = (
            '"Octopus.Action.Aws.CloudFormationStackName" = "a"\n'
            '"Octopus.Action.Aws.CloudFormation.ChangeSet.Arn" = "change"\n'
        )
        self.assertEqual(fix_cloudformation_dotted_property_names(config), config)


class TestFixTargetRolesList(unittest.TestCase):
    def test_empty_list_is_removed(self):
        config = '  properties = {\n      "Octopus.Action.TargetRoles" = []\n    }\n'
        result = fix_target_roles_list(config)
        self.assertNotIn("TargetRoles", result)
        self.assertEqual(result.count("{"), result.count("}"))

    def test_list_becomes_comma_separated_string(self):
        config = '      "Octopus.Action.TargetRoles" = ["web", "api"]\n'
        self.assertEqual(fix_target_roles_list(config), '      "Octopus.Action.TargetRoles" = "web,api"\n')

    def test_string_value_is_left_alone(self):
        config = '      "Octopus.Action.TargetRoles" = "web"\n'
        self.assertEqual(fix_target_roles_list(config), config)


PACKAGE_STEP = """resource "octopusdeploy_process_step" "process_step_deploy_pkg" {
  name                  = "Deploy Pkg"
  type                  = "Octopus.TentaclePackage"
  worker_pool_id        = "${data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id}"
  properties            = {
  }
  execution_properties  = {
    "Octopus.Action.RunOnServer" = "true"
  }
}
"""


class TestAddMissingTargetRoleToPackageSteps(unittest.TestCase):
    def test_adds_role_and_drops_worker_pool(self):
        result = add_missing_target_role_to_package_steps(PACKAGE_STEP)
        self.assertIn('"Octopus.Action.TargetRoles" = "deploy-target"', result)
        self.assertNotIn("worker_pool_id", result)
        self.assertIn('"Octopus.Action.RunOnServer" = "false"', result)
        self.assertEqual(result.count("{"), result.count("}"))

    def test_handles_single_line_empty_properties(self):
        config = PACKAGE_STEP.replace("properties            = {\n  }", "properties            = {}")
        result = add_missing_target_role_to_package_steps(config)
        self.assertIn('"Octopus.Action.TargetRoles" = "deploy-target"', result)
        self.assertEqual(result.count("{"), result.count("}"))

    def test_adds_properties_when_missing(self):
        config = PACKAGE_STEP.replace("  properties            = {\n  }\n", "")
        result = add_missing_target_role_to_package_steps(config)
        self.assertIn('"Octopus.Action.TargetRoles" = "deploy-target"', result)
        self.assertLess(result.index("TargetRoles"), result.index("execution_properties"))

    def test_leaves_step_with_role_alone(self):
        config = PACKAGE_STEP.replace("properties            = {\n  }", 'properties = { "Octopus.Action.TargetRoles" = "web" }')
        self.assertEqual(add_missing_target_role_to_package_steps(config), config)

    def test_leaves_script_step_alone(self):
        config = PACKAGE_STEP.replace("Octopus.TentaclePackage", "Octopus.Script")
        self.assertEqual(add_missing_target_role_to_package_steps(config), config)


S3_STEP = """resource "octopusdeploy_process_step" "process_step_upload_site" {
  name = "Upload Site"
  type = "Octopus.AwsUploadS3"
  primary_package = {
    package_id = "Site.Web"
  }
  execution_properties = {
    "Octopus.Action.Aws.Region" = "us-west-2"
    "Octopus.Action.Aws.S3.PublicAccess" = "True"
    "Octopus.Action.Aws.S3.ObjectWriterOwnership" = "False"
    "Octopus.Action.Aws.S3.TargetMode" = "EntirePackage"
  }
}
"""


class TestAddMissingS3PackageOptions(unittest.TestCase):
    def test_adds_package_options_and_removes_invented_properties(self):
        result = add_missing_s3_package_options(S3_STEP)
        self.assertIn('"Octopus.Action.Aws.S3.PackageOptions" = jsonencode({', result)
        self.assertIn('"cannedAcl" = "public-read"', result)
        self.assertIn('"bucketKey" = "Site.Web"', result)
        self.assertNotIn("PublicAccess", result)
        self.assertNotIn("ObjectWriterOwnership", result)
        self.assertIn('"Octopus.Action.Aws.S3.TargetMode" = "EntirePackage"', result)
        self.assertEqual(result.count("{"), result.count("}"))

    def test_private_acl_without_public_access(self):
        config = S3_STEP.replace('"Octopus.Action.Aws.S3.PublicAccess" = "True"', '"Octopus.Action.Aws.S3.PublicAccess" = "False"')
        self.assertIn('"cannedAcl" = "private"', add_missing_s3_package_options(config))

    def test_existing_options_are_left_alone(self):
        config = S3_STEP.replace(
            '"Octopus.Action.Aws.Region" = "us-west-2"',
            '"Octopus.Action.Aws.Region" = "us-west-2"\n    "Octopus.Action.Aws.S3.PackageOptions" = jsonencode({})',
        )
        self.assertEqual(add_missing_s3_package_options(config), config)

    def test_other_step_types_are_left_alone(self):
        config = S3_STEP.replace("Octopus.AwsUploadS3", "Octopus.Script")
        self.assertEqual(add_missing_s3_package_options(config), config)


RELEASE_NOTES_CONFIG = """resource "octopusdeploy_project" "project_settings_heavy" {
  count = 1
  name  = "Settings Heavy"
}
resource "octopusdeploy_project_release_notes_template" "project_settings_heavy" {
  count      = 1
  project_id = "${octopusdeploy_project.project_settings_heavy[0].id}"
  template   = "Release #{Octopus.Release.Number} by \\"me\\""
}
resource "octopusdeploy_project_group" "group" {
  name = "g"
}
"""


class TestMoveReleaseNotesTemplateToProject(unittest.TestCase):
    def test_moves_template_to_project(self):
        result = move_release_notes_template_to_project(RELEASE_NOTES_CONFIG)
        self.assertNotIn("octopusdeploy_project_release_notes_template", result)
        self.assertIn('release_notes_template = "Release #{Octopus.Release.Number} by \\"me\\""', result)
        self.assertIn('resource "octopusdeploy_project_group" "group"', result)
        self.assertEqual(result.count("{"), result.count("}"))

    def test_existing_project_template_is_kept(self):
        config = RELEASE_NOTES_CONFIG.replace('  name  = "Settings Heavy"', '  name  = "Settings Heavy"\n  release_notes_template = "kept"')
        result = move_release_notes_template_to_project(config)
        self.assertNotIn("octopusdeploy_project_release_notes_template", result)
        self.assertEqual(result.count("release_notes_template"), 1)
        self.assertIn('release_notes_template = "kept"', result)

    def test_config_without_resource_is_unchanged(self):
        self.assertEqual(move_release_notes_template_to_project("resource \"a\" \"b\" {\n}\n"), "resource \"a\" \"b\" {\n}\n")


class TestRemoveDuplicateVersioningStrategies(unittest.TestCase):
    STRATEGIES = """resource "octopusdeploy_project_versioning_strategy" "one" {
  project_id = "${octopusdeploy_project.p[0].id}"
  template   = "1"
}
resource "octopusdeploy_project_versioning_strategy" "two" {
  project_id = "${octopusdeploy_project.p[0].id}"
  template   = "2"
}
resource "octopusdeploy_project_versioning_strategy" "other" {
  project_id = "${octopusdeploy_project.q[0].id}"
  template   = "3"
}
"""

    def test_keeps_first_strategy_per_project(self):
        result = remove_duplicate_versioning_strategies(self.STRATEGIES)
        self.assertIn('"one"', result)
        self.assertNotIn('"two"', result)
        self.assertIn('"other"', result)
        self.assertEqual(result.count("{"), result.count("}"))

    def test_single_strategy_is_unchanged(self):
        single = self.STRATEGIES.split('resource "octopusdeploy_project_versioning_strategy" "two"')[0]
        self.assertEqual(remove_duplicate_versioning_strategies(single), single)


POLLING_TARGET = """resource "octopusdeploy_polling_tentacle_deployment_target" "target_poll_01" {
  name         = "poll-01"
  tentacle_url = "URL"
  thumbprint   = "0123456789ABCDEF0123456789ABCDEF01234567"
}
resource "octopusdeploy_listening_tentacle_deployment_target" "target_win_01" {
  tentacle_url = "https://win01.example.com:10933"
}
"""


class TestFixPollingTentacleUri(unittest.TestCase):
    def test_invalid_subscription_is_replaced_with_a_valid_one(self):
        result = fix_polling_tentacle_uri(POLLING_TARGET.replace("URL", "poll://abc123/"))
        self.assertRegex(result, r'tentacle_url = "poll://[a-z0-9]{20}/"')

    def test_https_address_is_replaced_in_a_polling_target(self):
        result = fix_polling_tentacle_uri(POLLING_TARGET.replace("URL", "https://poll01.example.com:10934"))
        self.assertRegex(result, r'tentacle_url = "poll://[a-z0-9]{20}/"')
        self.assertIn('tentacle_url = "https://win01.example.com:10933"', result)

    def test_replacement_is_stable(self):
        config = POLLING_TARGET.replace("URL", "poll://my-subscription/")
        self.assertEqual(fix_polling_tentacle_uri(config), fix_polling_tentacle_uri(config))

    def test_valid_subscription_is_left_alone(self):
        config = POLLING_TARGET.replace("URL", "poll://nvpv4doqf2f3id45t1xn/")
        self.assertEqual(fix_polling_tentacle_uri(config), config)

    def test_config_without_a_polling_target_is_unchanged(self):
        config = 'resource "a" "b" {\n  tentacle_url = "https://x"\n}\n'
        self.assertEqual(fix_polling_tentacle_uri(config), config)


class TestFixDeploymentTargetTriggerType(unittest.TestCase):
    def test_renames_resource_and_references(self):
        config = (
            'resource "octopusdeploy_deployment_target_trigger" "t" {\n  name = "x"\n}\n'
            "depends_on = [octopusdeploy_deployment_target_trigger.t]\n"
        )
        result = fix_deployment_target_trigger_type(config)
        self.assertIn('resource "octopusdeploy_project_deployment_target_trigger" "t"', result)
        self.assertIn("octopusdeploy_project_deployment_target_trigger.t]", result)
        self.assertNotIn("octopusdeploy_deployment_target_trigger", result)

    def test_correct_type_is_left_alone(self):
        config = 'resource "octopusdeploy_project_deployment_target_trigger" "t" {\n}\n'
        self.assertEqual(fix_deployment_target_trigger_type(config), config)

    def test_deployment_targets_data_source_is_left_alone(self):
        config = 'data "octopusdeploy_deployment_targets" "t" {\n}\n'
        self.assertEqual(fix_deployment_target_trigger_type(config), config)


class TestFixTriggerEventCategories(unittest.TestCase):
    def test_group_names_become_categories(self):
        config = 'event_categories = ["MachineAvailableForDeployment", "MachineHealthChanged"]'
        self.assertEqual(fix_trigger_event_categories(config), 'event_categories = ["MachineHealthy"]')

    def test_valid_categories_are_kept_and_unknown_dropped(self):
        config = 'event_categories = ["MachineAdded", "Bogus", "MachineUnhealthy"]'
        self.assertEqual(fix_trigger_event_categories(config), 'event_categories = ["MachineAdded", "MachineUnhealthy"]')

    def test_empty_result_defaults_to_machine_added(self):
        self.assertEqual(fix_trigger_event_categories('event_categories = ["Bogus"]'), 'event_categories = ["MachineAdded"]')

    def test_event_groups_are_left_alone(self):
        config = 'event_groups = ["Machine", "MachineHealthChanged"]'
        self.assertEqual(fix_trigger_event_categories(config), config)


ROLE_STEP = """resource "octopusdeploy_process_step" "process_step_deploy_app" {
  name = "Deploy App"
  type = "Octopus.TentaclePackage"
  worker_pool_id = "${data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id}"
  properties = {
    "Octopus.Action.TargetRoles" = "app-server"
  }
  execution_properties = {
    "Octopus.Action.Package.AutomaticallyRunConfigurationTransformationFiles" = "True"
  }
}
"""


class TestRemoveWorkerPoolFromPackageStepsWithRoles(unittest.TestCase):
    def test_removes_worker_pool_and_sets_run_on_server_false(self):
        result = remove_worker_pool_from_package_steps_with_roles(ROLE_STEP)
        self.assertNotIn("worker_pool_id", result)
        self.assertIn('"Octopus.Action.RunOnServer" = "false"', result)
        self.assertEqual(result.count("{"), result.count("}"))

    def test_existing_run_on_server_false_is_kept(self):
        config = ROLE_STEP.replace(
            '"Octopus.Action.Package.AutomaticallyRunConfigurationTransformationFiles" = "True"',
            '"Octopus.Action.RunOnServer" = "false"',
        )
        result = remove_worker_pool_from_package_steps_with_roles(config)
        self.assertNotIn("worker_pool_id", result)
        self.assertEqual(result.count("RunOnServer"), 1)

    def test_step_that_runs_on_the_server_is_left_alone(self):
        config = ROLE_STEP.replace(
            '"Octopus.Action.Package.AutomaticallyRunConfigurationTransformationFiles" = "True"',
            '"Octopus.Action.RunOnServer" = "true"',
        )
        self.assertEqual(remove_worker_pool_from_package_steps_with_roles(config), config)

    def test_step_without_roles_is_left_alone(self):
        config = ROLE_STEP.replace('"Octopus.Action.TargetRoles" = "app-server"', '"Other" = "x"')
        self.assertEqual(remove_worker_pool_from_package_steps_with_roles(config), config)


if __name__ == "__main__":
    unittest.main()


class TestFixTriggerPrimaryPackageReference(unittest.TestCase):
    STEP = """
resource "octopusdeploy_process_step" "deploy" {
  primary_package = {
    package_id = "Trigger.App"
    feed_id    = "Feeds-1"
  }
}
"""
    TRIGGER = """
resource "octopusdeploy_external_feed_create_release_trigger" "t" {
  name = "New Package Release"
  package {
    deployment_action_slug = "deploy-app"
    package_reference      = "Trigger.App"
  }
}
"""

    def test_replaces_primary_package_id_with_empty_reference(self):
        result = fix_trigger_primary_package_reference(self.STEP + self.TRIGGER)
        self.assertIn('package_reference      = ""', result)
        self.assertNotIn('package_reference      = "Trigger.App"', result)
        self.assertIn('package_id = "Trigger.App"', result)

    def test_handles_interpolation_inside_primary_package(self):
        step = self.STEP.replace('"Feeds-1"', '"${length(x.feeds) != 0 ? x.feeds[0].id : y.id}"')
        result = fix_trigger_primary_package_reference(step + self.TRIGGER)
        self.assertIn('package_reference      = ""', result)

    def test_keeps_reference_matching_packages_map_key(self):
        config = self.STEP + self.TRIGGER + 'packages = {\n  "Trigger.App" = {\n  }\n}\n'
        self.assertEqual(fix_trigger_primary_package_reference(config), config)

    def test_keeps_reference_without_primary_package(self):
        self.assertEqual(fix_trigger_primary_package_reference(self.TRIGGER), self.TRIGGER)

    def test_keeps_other_references(self):
        config = self.STEP + self.TRIGGER.replace('"Trigger.App"', '"webapp"')
        self.assertEqual(fix_trigger_primary_package_reference(config), config)


class TestFixParenthesisOctopusVariableSyntax(unittest.TestCase):
    def test_replaces_system_variable(self):
        result = fix_parenthesis_octopus_variable_syntax('$rg = "rg-$(Octopus.Environment.Name)-$(Octopus.Release.Number)"')
        self.assertEqual(result, '$rg = "rg-#{Octopus.Environment.Name}-#{Octopus.Release.Number}"')

    def test_keeps_powershell_subexpressions(self):
        config = '$x = $(Get-Date) ; $y = "$(Other.Name)" ; $z = $($env:HOME)'
        self.assertEqual(fix_parenthesis_octopus_variable_syntax(config), config)

    def test_keeps_correct_syntax(self):
        config = 'name = "#{Octopus.Environment.Name}"'
        self.assertEqual(fix_parenthesis_octopus_variable_syntax(config), config)


class TestFixVariableConditionWithoutExpression(unittest.TestCase):
    def step(self, properties):
        return (
            'resource "octopusdeploy_process_step" "s" {\n'
            '  name      = "Show"\n'
            '  condition = "Variable"\n'
            f"  properties = {{\n{properties}\n  }}\n"
            "}\n"
        )

    def test_missing_expression_falls_back_to_success(self):
        result = fix_variable_condition_without_expression(self.step('    "Octopus.Action.TargetRoles" = "web"'))
        self.assertIn('condition = "Success"', result)
        self.assertNotIn('"Variable"', result)

    def test_empty_expression_falls_back_to_success(self):
        result = fix_variable_condition_without_expression(self.step('    "Octopus.Step.ConditionVariableExpression" = ""'))
        self.assertIn('condition = "Success"', result)

    def test_keeps_condition_with_expression(self):
        config = self.step('    "Octopus.Step.ConditionVariableExpression" = "#{Release.Mode}"')
        self.assertEqual(fix_variable_condition_without_expression(config), config)

    def test_only_changes_the_step_missing_the_expression(self):
        good = self.step('    "Octopus.Step.ConditionVariableExpression" = "#{Release.Mode}"')
        bad = self.step("").replace('"s"', '"t"')
        result = fix_variable_condition_without_expression(good + bad)
        self.assertEqual(result.count('condition = "Variable"'), 1)
        self.assertEqual(result.count('condition = "Success"'), 1)


class TestFixDonorPackageAttribute(unittest.TestCase):
    BLOCK = """
resource "octopusdeploy_project_versioning_strategy" "p" {
  project_id = "Projects-1"

  donor_package {
    deployment_action = "Run Tuner"
    package_reference = ""
  }
  depends_on = [octopusdeploy_process_step.s]
}
"""

    def test_converts_block_to_attribute(self):
        result = fix_donor_package_attribute(self.BLOCK)
        self.assertIn("  donor_package = {\n", result)
        self.assertNotIn("donor_package {", result)
        self.assertIn('deployment_action = "Run Tuner"', result)

    def test_keeps_attribute_form(self):
        config = self.BLOCK.replace("donor_package {", "donor_package = {")
        self.assertEqual(fix_donor_package_attribute(config), config)

    def test_ignores_other_resources(self):
        config = 'resource "octopusdeploy_project" "p" {\n  donor_package {\n  }\n}\n'
        self.assertEqual(fix_donor_package_attribute(config), config)


class TestEscapeInvalidTemplateDirectives(unittest.TestCase):
    def test_escapes_literal_percent_brace(self):
        result = escape_invalid_template_directives('value = "100%% done $${not.terraform} %{not.either}"')
        self.assertEqual(result, 'value = "100%% done $${not.terraform} %%{not.either}"')

    def test_keeps_real_directives(self):
        config = 'value = "%{ if var.x }a%{ else }b%{ endif }%{~ for i in var.l ~}${i}%{~ endfor ~}"'
        self.assertEqual(escape_invalid_template_directives(config), config)

    def test_keeps_already_escaped(self):
        config = 'value = "%%{literal}"'
        self.assertEqual(escape_invalid_template_directives(config), config)

    def test_escapes_keyword_prefixed_text(self):
        result = escape_invalid_template_directives('value = "%{iffy}"')
        self.assertEqual(result, 'value = "%%{iffy}"')


class TestAddRunOnServerToWorkerPoolSteps(unittest.TestCase):
    STEP = """resource "octopusdeploy_process_step" "s" {
  name           = "Do Work"
  type           = "Octopus.Script"
  worker_pool_id = "${data.octopusdeploy_worker_pools.w.worker_pools[0].id}"
  execution_properties = {
    "Octopus.Action.Script.ScriptBody" = "echo work"
  }
}
"""

    def test_adds_property_when_missing(self):
        result = add_run_on_server_to_worker_pool_steps(self.STEP)
        self.assertIn('"Octopus.Action.RunOnServer" = "true"', result)
        self.assertIn('"Octopus.Action.Script.ScriptBody" = "echo work"', result)

    def test_keeps_existing_property(self):
        config = self.STEP.replace('"echo work"\n', '"echo work"\n    "Octopus.Action.RunOnServer" = "false"\n')
        self.assertEqual(add_run_on_server_to_worker_pool_steps(config), config)

    def test_ignores_step_without_worker_pool(self):
        config = self.STEP.replace("  worker_pool_id", "  # none")
        self.assertEqual(add_run_on_server_to_worker_pool_steps(config), config)

    def test_handles_worker_pool_variable_and_multiple_steps(self):
        second = self.STEP.replace('"s"', '"t"').replace("worker_pool_id ", "worker_pool_variable ")
        result = add_run_on_server_to_worker_pool_steps(self.STEP + second)
        self.assertEqual(result.count('"Octopus.Action.RunOnServer" = "true"'), 2)


class TestRemoveStepsOrderDependencyFromReferencedChannels(unittest.TestCase):
    CONFIG = """
resource "octopusdeploy_process_step" "s" {
  name     = "Build Docs"
  channels = ["${octopusdeploy_channel.channel_p_hotfix[0].id}"]
}
resource "octopusdeploy_channel" "channel_p_hotfix" {
  name       = "Hotfix"
  depends_on = [octopusdeploy_process_steps_order.order, octopusdeploy_project.p]
}
resource "octopusdeploy_channel" "channel_p_other" {
  name       = "Other"
  depends_on = [octopusdeploy_process_steps_order.order]
}
"""

    def test_removes_steps_order_from_referenced_channel(self):
        result = remove_steps_order_dependency_from_referenced_channels(self.CONFIG)
        self.assertIn("depends_on = [ octopusdeploy_project.p]", result)

    def test_keeps_unreferenced_channel_dependency(self):
        result = remove_steps_order_dependency_from_referenced_channels(self.CONFIG)
        self.assertIn('name       = "Other"\n  depends_on = [octopusdeploy_process_steps_order.order]', result)

    def test_leaves_empty_list_when_only_steps_order(self):
        config = self.CONFIG.replace(", octopusdeploy_project.p", "")
        result = remove_steps_order_dependency_from_referenced_channels(config)
        self.assertIn("depends_on = []", result)

    def test_no_change_without_channel_reference(self):
        config = self.CONFIG.replace("octopusdeploy_channel.channel_p_hotfix[0].id", "x")
        self.assertEqual(remove_steps_order_dependency_from_referenced_channels(config), config)


class TestRemoveEnvironmentsWhenExcludedEnvironmentsAreSet(unittest.TestCase):
    def step(self, environments, excluded):
        return (
            'resource "octopusdeploy_process_step" "s" {\n'
            '  name                  = "Prod Only"\n'
            f"  environments          = {environments}\n"
            f"  excluded_environments = {excluded}\n"
            '  condition             = "Success"\n'
            "}\n"
        )

    def test_drops_included_environments_when_both_set(self):
        result = remove_environments_when_excluded_environments_are_set(
            self.step('["${octopusdeploy_environment.p.id}"]', '["${octopusdeploy_environment.d.id}"]')
        )
        self.assertIn("  environments          = null\n", result)
        self.assertIn('excluded_environments = ["${octopusdeploy_environment.d.id}"]', result)

    def test_keeps_included_when_excluded_is_null(self):
        config = self.step('["${octopusdeploy_environment.p.id}"]', "null")
        self.assertEqual(remove_environments_when_excluded_environments_are_set(config), config)

    def test_keeps_excluded_when_included_is_null_or_empty(self):
        for included in ("null", "[]"):
            config = self.step(included, '["${octopusdeploy_environment.d.id}"]')
            self.assertEqual(remove_environments_when_excluded_environments_are_set(config), config)

    def test_empty_excluded_list_changes_nothing(self):
        config = self.step('["${octopusdeploy_environment.p.id}"]', "[]")
        self.assertEqual(remove_environments_when_excluded_environments_are_set(config), config)


class TestRemoveEnvironmentsWithMultilineLists(unittest.TestCase):
    def test_multiline_excluded_list_and_ternary_included_list(self):
        config = """resource "octopusdeploy_process_step" "s" {
  name                  = "Prod Only"
  environments         = ["${length(local.p) != 0 ? local.p[0].id : octopusdeploy_environment.p[0].id}"]
  excluded_environments = [
    "${octopusdeploy_environment.d.id}",
    "${octopusdeploy_environment.t.id}"
  ]
  condition             = "Failure"
}
"""
        result = remove_environments_when_excluded_environments_are_set(config)
        self.assertIn("environments         = null\n  excluded_environments = [\n", result)
        self.assertIn('"${octopusdeploy_environment.t.id}"\n  ]', result)
        self.assertIn('condition             = "Failure"', result)

    def test_multiline_included_list_is_replaced_completely(self):
        config = """resource "octopusdeploy_process_step" "s" {
  environments = [
    "a",
    "b"
  ]
  excluded_environments = ["c"]
}
"""
        result = remove_environments_when_excluded_environments_are_set(config)
        self.assertIn("environments = null\n  excluded_environments", result)
        self.assertNotIn('"a"', result)
