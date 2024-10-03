import unittest

from domain.query.query_inspector import (
    exclude_all_targets,
    exclude_all_runbooks,
    exclude_all_tenants,
    exclude_all_projects,
    exclude_all_library_variable_sets,
    exclude_all_environments,
    exclude_all_feeds,
    exclude_all_accounts,
    exclude_all_certificates,
    exclude_all_lifecycles,
    exclude_all_worker_pools,
    exclude_all_machine_policies,
    exclude_all_tagsets,
    exclude_all_project_groups,
    exclude_all_steps,
    exclude_all_variables,
    release_is_latest,
)


class QueryInspectorTest(unittest.TestCase):
    def test_exclude_all_targets(self):
        self.assertFalse(exclude_all_targets("show the kubernetes targets", []))
        self.assertFalse(exclude_all_targets("show the web app targets", []))
        self.assertFalse(exclude_all_targets("show the webapp targets", []))
        self.assertFalse(exclude_all_targets("show the polling targets", []))
        self.assertFalse(exclude_all_targets("show the listening targets", []))
        self.assertFalse(exclude_all_targets("show the ssh targets", []))
        self.assertFalse(exclude_all_targets("show the cloud region targets", []))
        self.assertFalse(exclude_all_targets("show the cloudregion targets", []))
        self.assertFalse(exclude_all_targets("show the service fabric targets", []))
        self.assertFalse(exclude_all_targets("show the servicefabric targets", []))
        self.assertFalse(exclude_all_targets("show the ecs targets", []))
        self.assertTrue(exclude_all_targets("show the dashboard", []))
        self.assertFalse(exclude_all_targets("show the dashboard", ["target1"]))

    def test_exclude_all_runbooks(self):
        self.assertFalse(exclude_all_runbooks("show the runbooks", []))
        self.assertFalse(exclude_all_runbooks("show the runbooks", ["runbook1"]))
        self.assertFalse(exclude_all_runbooks("show the runbook", []))
        self.assertTrue(exclude_all_runbooks("show the dashboard", []))

    def test_exclude_all_tenants(self):
        self.assertFalse(exclude_all_tenants("show the tenants", []))
        self.assertFalse(exclude_all_tenants("show the tenants", ["tenant1"]))
        self.assertFalse(exclude_all_tenants("show the tenant", []))
        self.assertTrue(exclude_all_tenants("show the dashboard", []))

    def test_exclude_all_projects(self):
        self.assertFalse(exclude_all_projects("show the projects", []))
        self.assertFalse(exclude_all_projects("show the projects", ["project1"]))
        self.assertFalse(exclude_all_projects("show the project", []))
        self.assertTrue(exclude_all_projects("show the dashboard", []))

    def test_exclude_all_library_variable_sets(self):
        self.assertFalse(
            exclude_all_library_variable_sets("show the library variable sets", [])
        )
        self.assertFalse(
            exclude_all_library_variable_sets(
                "show the library variable sets", ["set1"]
            )
        )
        self.assertFalse(
            exclude_all_library_variable_sets("show the library variable set", [])
        )
        self.assertTrue(exclude_all_library_variable_sets("show the dashboard", []))

    def test_exclude_all_environments(self):
        self.assertFalse(exclude_all_environments("show the environments", []))
        self.assertFalse(exclude_all_environments("show the environments", ["<all>"]))
        self.assertFalse(exclude_all_environments("show the environments", ["env1"]))
        self.assertFalse(exclude_all_environments("show the environment", []))
        self.assertTrue(exclude_all_environments("show the dashboard", []))

    def test_exclude_all_feeds(self):
        self.assertFalse(exclude_all_feeds("show the feeds", []))
        self.assertFalse(exclude_all_feeds("show the feeds", ["feed1"]))
        self.assertFalse(exclude_all_feeds("show the feed", []))
        self.assertTrue(exclude_all_feeds("show the dashboard", []))

    def test_exclude_all_accounts(self):
        self.assertFalse(exclude_all_accounts("show the accounts", []))
        self.assertFalse(exclude_all_accounts("show the accounts", ["account1"]))
        self.assertFalse(exclude_all_accounts("show the account", []))
        self.assertTrue(exclude_all_accounts("show the dashboard", []))

    def test_exclude_all_certificates(self):
        self.assertFalse(exclude_all_certificates("show the certificates", []))
        self.assertFalse(exclude_all_certificates("show the certificates", ["cert1"]))
        self.assertFalse(exclude_all_certificates("show the certificate", []))
        self.assertTrue(exclude_all_certificates("show the dashboard", []))

    def test_exclude_all_lifecycles(self):
        self.assertFalse(exclude_all_lifecycles("show the lifecycles", []))
        self.assertFalse(exclude_all_lifecycles("show the lifecycles", ["lifecycle1"]))
        self.assertFalse(exclude_all_lifecycles("show the lifecycle", []))
        self.assertTrue(exclude_all_lifecycles("show the dashboard", []))

    def test_exclude_all_worker_pools(self):
        self.assertFalse(exclude_all_worker_pools("show the worker pools", []))
        self.assertFalse(exclude_all_worker_pools("show the worker pools", ["pool1"]))
        self.assertFalse(exclude_all_worker_pools("show the worker pool", []))
        self.assertTrue(exclude_all_worker_pools("show the dashboard", []))

    def test_exclude_all_machine_policies(self):
        self.assertFalse(exclude_all_machine_policies("show the machine policies", []))
        self.assertFalse(
            exclude_all_machine_policies("show the machine policies", ["policy1"])
        )
        self.assertFalse(exclude_all_machine_policies("show the policy", []))
        self.assertTrue(exclude_all_machine_policies("show the dashboard", []))

    def test_exclude_all_tagsets(self):
        self.assertFalse(exclude_all_tagsets("show the tag sets", []))
        self.assertFalse(exclude_all_tagsets("show the tag sets", ["tagset1"]))
        self.assertFalse(exclude_all_tagsets("show the tag", []))
        self.assertTrue(exclude_all_tagsets("show the dashboard", []))

    def test_exclude_all_project_groups(self):
        self.assertFalse(exclude_all_project_groups("show the project groups", []))
        self.assertFalse(
            exclude_all_project_groups("show the project groups", ["group1"])
        )
        self.assertFalse(exclude_all_project_groups("show the group", []))
        self.assertTrue(exclude_all_project_groups("show the dashboard", []))

    def test_exclude_all_steps(self):
        self.assertFalse(exclude_all_steps("show the steps", []))
        self.assertFalse(exclude_all_steps("show the steps", ["<all>"]))
        self.assertFalse(exclude_all_steps("show the steps", ["step1"]))
        self.assertFalse(exclude_all_steps("show the step", []))
        self.assertTrue(exclude_all_steps("show the dashboard", []))

    def test_exclude_all_variables(self):
        self.assertFalse(exclude_all_variables("show the variables", []))
        self.assertFalse(exclude_all_variables("show the variables", ["<all>"]))
        self.assertFalse(exclude_all_variables("show the variables", ["variable1"]))
        self.assertFalse(exclude_all_variables("show the variable", []))
        self.assertTrue(exclude_all_variables("show the dashboard", []))

    def test_release_is_latest(self):
        self.assertTrue(release_is_latest("latest"))
        self.assertTrue(release_is_latest("most recent"))
        self.assertTrue(release_is_latest("current"))
        self.assertFalse(release_is_latest("1.0.0"))
