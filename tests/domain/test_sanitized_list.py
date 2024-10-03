import unittest

from domain.sanitizers.sanitized_list import (
    sanitize_list,
    sanitize_environments,
    sanitize_projects,
    sanitize_tenants,
    sanitize_feeds,
    sanitize_accounts,
    sanitize_workerpools,
    sanitize_machinepolicies,
    sanitize_tenanttagsets,
    sanitize_projectgroups,
    sanitize_channels,
    sanitize_releases,
    sanitize_lifecycles,
    sanitize_certificates,
    sanitize_targets,
    sanitize_runbooks,
    sanitize_gitcredentials,
    sanitize_steps,
    sanitize_variables,
    sanitize_dates,
    force_to_list,
    get_item_or_default,
    get_key_or_none,
    flatten_list,
    yield_first,
    get_item_fuzzy_generator,
    none_if_falesy_or_all,
)


class SanitizeList(unittest.TestCase):
    def test_sanitize_projects(self):
        self.assertFalse(sanitize_projects(None))
        self.assertFalse(sanitize_projects(1))
        self.assertFalse(sanitize_projects(True))
        self.assertFalse(sanitize_projects("Project A"))
        self.assertFalse(sanitize_projects("ProjectA"))
        self.assertFalse(sanitize_projects("Project1"))
        self.assertFalse(sanitize_projects("MyProject"))
        self.assertFalse(sanitize_projects("My Project"))
        self.assertTrue(sanitize_projects("Valid project"))

    def test_sanitize_tenants(self):
        self.assertFalse(sanitize_tenants(None))
        self.assertFalse(sanitize_tenants(1))
        self.assertFalse(sanitize_tenants(True))
        self.assertFalse(sanitize_tenants("TenantA"))
        self.assertFalse(sanitize_tenants("Tenant A"))
        self.assertFalse(sanitize_tenants("Tenant 1"))
        self.assertFalse(sanitize_tenants("MyTenant"))
        self.assertFalse(sanitize_tenants("My Tenant"))
        self.assertTrue(sanitize_tenants("Valid tenant"))

    def test_sanitize_feeds(self):
        self.assertFalse(sanitize_feeds(None))
        self.assertFalse(sanitize_feeds(1))
        self.assertFalse(sanitize_feeds(True))
        self.assertFalse(sanitize_feeds("FeedA"))
        self.assertFalse(sanitize_feeds("Feed A"))
        self.assertFalse(sanitize_feeds("Feed 1"))
        self.assertFalse(sanitize_feeds("MyFeed"))
        self.assertFalse(sanitize_feeds("My Feed"))
        self.assertTrue(sanitize_feeds("Valid Feed"))

    def test_sanitize_accounts(self):
        self.assertFalse(sanitize_accounts(None))
        self.assertFalse(sanitize_accounts(1))
        self.assertFalse(sanitize_accounts(True))
        self.assertFalse(sanitize_accounts("AccountA"))
        self.assertFalse(sanitize_accounts("Account A"))
        self.assertFalse(sanitize_accounts("Account 1"))
        self.assertFalse(sanitize_accounts("MyAccount"))
        self.assertFalse(sanitize_accounts("My Account"))
        self.assertTrue(sanitize_accounts("Valid Account"))

    def test_sanitize_channels(self):
        self.assertFalse(sanitize_channels(None))
        self.assertFalse(sanitize_channels(1))
        self.assertFalse(sanitize_channels(True))
        self.assertFalse(sanitize_channels("ChannelA"))
        self.assertFalse(sanitize_channels("Channel A"))
        self.assertFalse(sanitize_channels("Channel 1"))
        self.assertFalse(sanitize_channels("MyChannel"))
        self.assertFalse(sanitize_channels("My Channel"))
        self.assertTrue(sanitize_channels("Valid Channel"))

    def test_sanitize_releases(self):
        self.assertFalse(sanitize_releases(None))
        self.assertFalse(sanitize_releases(1))
        self.assertFalse(sanitize_releases(True))
        self.assertFalse(sanitize_releases("ReleaseA"))
        self.assertFalse(sanitize_releases("Release A"))
        self.assertFalse(sanitize_releases("Release 1"))
        self.assertFalse(sanitize_releases("MyRelease"))
        self.assertFalse(sanitize_releases("My Release"))
        self.assertTrue(sanitize_releases("Valid Release"))

    def test_sanitize_lifecycles(self):
        self.assertFalse(sanitize_lifecycles(None))
        self.assertFalse(sanitize_lifecycles(1))
        self.assertFalse(sanitize_lifecycles(True))
        self.assertFalse(sanitize_lifecycles("LifecycleA"))
        self.assertFalse(sanitize_lifecycles("Lifecycle A"))
        self.assertFalse(sanitize_lifecycles("Lifecycle 1"))
        self.assertFalse(sanitize_lifecycles("MyLifecycle"))
        self.assertFalse(sanitize_lifecycles("My Lifecycle"))
        self.assertTrue(sanitize_lifecycles("Valid Lifecycle"))

    def test_sanitize_certificates(self):
        self.assertFalse(sanitize_certificates(None))
        self.assertFalse(sanitize_certificates(1))
        self.assertFalse(sanitize_certificates(True))
        self.assertFalse(sanitize_certificates("CertificateA"))
        self.assertFalse(sanitize_certificates("Certificate A"))
        self.assertFalse(sanitize_certificates("Certificate 1"))
        self.assertFalse(sanitize_certificates("MyCertificate"))
        self.assertFalse(sanitize_certificates("My Certificate"))
        self.assertTrue(sanitize_certificates("Valid Certificate"))

    def test_sanitize_runbooks(self):
        self.assertFalse(sanitize_runbooks(None))
        self.assertFalse(sanitize_runbooks(1))
        self.assertFalse(sanitize_runbooks(True))
        self.assertFalse(sanitize_runbooks("RunbookA"))
        self.assertFalse(sanitize_runbooks("Runbook A"))
        self.assertFalse(sanitize_runbooks("Runbook 1"))
        self.assertFalse(sanitize_runbooks("MyRunbook"))
        self.assertFalse(sanitize_runbooks("My Runbook"))
        self.assertTrue(sanitize_runbooks("Valid Runbook"))

    def test_sanitize_targets(self):
        self.assertFalse(sanitize_targets(None))
        self.assertFalse(sanitize_targets(1))
        self.assertFalse(sanitize_targets(True))
        self.assertFalse(sanitize_targets("TargetA"))
        self.assertFalse(sanitize_targets("Target A"))
        self.assertFalse(sanitize_targets("Target 1"))
        self.assertFalse(sanitize_targets("MyTarget"))
        self.assertFalse(sanitize_targets("My Target"))
        self.assertFalse(sanitize_targets("MachineA"))
        self.assertFalse(sanitize_targets("Machine A"))
        self.assertFalse(sanitize_targets("Machine 1"))
        self.assertFalse(sanitize_targets("MyMachine"))
        self.assertFalse(sanitize_targets("My Machine"))
        self.assertTrue(sanitize_targets("Valid Target"))

    def test_sanitize_workerpools(self):
        self.assertFalse(sanitize_workerpools(None))
        self.assertFalse(sanitize_workerpools(1))
        self.assertFalse(sanitize_workerpools(True))
        self.assertFalse(sanitize_workerpools("WorkerPoolA"))
        self.assertFalse(sanitize_workerpools("WorkerPool A"))
        self.assertFalse(sanitize_workerpools("Worker Pool A"))
        self.assertFalse(sanitize_workerpools("WorkerPool 1"))
        self.assertFalse(sanitize_workerpools("Worker Pool 1"))
        self.assertFalse(sanitize_workerpools("MyWorkerPool"))
        self.assertFalse(sanitize_workerpools("MyWorker Pool"))
        self.assertFalse(sanitize_workerpools("My Worker Pool"))
        self.assertTrue(sanitize_workerpools("Valid Worker Pool"))

    def test_sanitize_machinepolicies(self):
        self.assertFalse(sanitize_machinepolicies(None))
        self.assertFalse(sanitize_machinepolicies(1))
        self.assertFalse(sanitize_machinepolicies(True))
        self.assertFalse(sanitize_machinepolicies("MachinePolicyA"))
        self.assertFalse(sanitize_machinepolicies("MachinePolicy A"))
        self.assertFalse(sanitize_machinepolicies("Machine Policy A"))
        self.assertFalse(sanitize_machinepolicies("MachinePolicy 1"))
        self.assertFalse(sanitize_machinepolicies("Machine Policy 1"))
        self.assertFalse(sanitize_machinepolicies("MyMachinePolicy"))
        self.assertFalse(sanitize_machinepolicies("My MachinePolicy"))
        self.assertFalse(sanitize_machinepolicies("My Machine Policy"))
        self.assertTrue(sanitize_machinepolicies("Valid MachinePolicy"))

    def test_sanitize_tenanttagsets(self):
        self.assertFalse(sanitize_tenanttagsets(None))
        self.assertFalse(sanitize_tenanttagsets(1))
        self.assertFalse(sanitize_tenanttagsets(True))
        self.assertFalse(sanitize_tenanttagsets("TagSetA"))
        self.assertFalse(sanitize_tenanttagsets("TagSet A"))
        self.assertFalse(sanitize_tenanttagsets("Tag Set A"))
        self.assertFalse(sanitize_tenanttagsets("TagSet 1"))
        self.assertFalse(sanitize_tenanttagsets("Tag Set 1"))
        self.assertFalse(sanitize_tenanttagsets("MyTagSet"))
        self.assertFalse(sanitize_tenanttagsets("My TagSet"))
        self.assertFalse(sanitize_tenanttagsets("My Tag Set"))
        self.assertTrue(sanitize_tenanttagsets("Valid Tag Set"))

    def test_sanitize_projectgroups(self):
        self.assertFalse(sanitize_projectgroups(None))
        self.assertFalse(sanitize_projectgroups(1))
        self.assertFalse(sanitize_projectgroups(True))
        self.assertFalse(sanitize_projectgroups("ProjectGroupA"))
        self.assertFalse(sanitize_projectgroups("ProjectGroup A"))
        self.assertFalse(sanitize_projectgroups("Project Group A"))
        self.assertFalse(sanitize_projectgroups("ProjectGroup 1"))
        self.assertFalse(sanitize_projectgroups("Project Group 1"))
        self.assertFalse(sanitize_projectgroups("MyProjectGroup"))
        self.assertFalse(sanitize_projectgroups("My ProjectGroup"))
        self.assertFalse(sanitize_projectgroups("My Project Group"))
        self.assertTrue(sanitize_projectgroups("Valid Project Group"))

    def test_sanitize_list(self):
        self.assertFalse(sanitize_list("Machine A", "Machine\\s*[A-Za-z0-9]"))
        self.assertFalse(sanitize_list(["*"], "\\*"))
        self.assertFalse(sanitize_list([" ", "  ", "   "]))
        self.assertTrue(sanitize_list([" ", "  ", "  i "]))
        self.assertFalse(sanitize_list([]))
        self.assertFalse(sanitize_list(None))
        self.assertFalse(sanitize_list(5))
        self.assertFalse(sanitize_list([5]))
        self.assertFalse(sanitize_list(5.5))
        self.assertFalse(sanitize_list([5.5]))
        self.assertFalse(sanitize_list(True))
        self.assertFalse(sanitize_list([True]))
        self.assertFalse(sanitize_list([[True]]))
        self.assertEqual(0, len(sanitize_list(None)))
        self.assertFalse(sanitize_list(""))
        self.assertFalse(sanitize_list(" "))
        self.assertFalse(sanitize_list("Machine A", "Machine"))
        self.assertTrue(sanitize_list("Machine A", "^Machine$"))
        self.assertTrue(sanitize_list("hi"))
        self.assertTrue(sanitize_list(["hi"]))
        self.assertFalse(sanitize_list([["hi"]]))
        self.assertFalse(sanitize_environments("find releases in production", None))

    def test_sanitize_gitcredentials_with_ignored_entries(self):
        input_list = [
            "Any",
            "all",
            "*",
            "Git Credential 1",
            "My Git Credential",
            "cred123",
        ]
        result = sanitize_gitcredentials(input_list)
        self.assertEqual(result, [])

    def test_sanitize_gitcredentials_with_empty_list(self):
        input_list = []
        result = sanitize_gitcredentials(input_list)
        self.assertEqual(result, [])

    def test_sanitize_gitcredentials_with_non_string_entries(self):
        input_list = [None, 123, True, "GitHub Login"]
        result = sanitize_gitcredentials(input_list)
        self.assertEqual(result, ["GitHub Login"])

    def test_sanitize_steps_with_ignored_entries(self):
        input_list = ["Any", "all", "*", "Step 1", "Step 2"]
        result = sanitize_steps(input_list)
        self.assertEqual(result, [])

    def test_sanitize_steps_with_empty_list(self):
        input_list = []
        result = sanitize_steps(input_list)
        self.assertEqual(result, [])

    def test_sanitize_steps_with_non_string_entries(self):
        input_list = [None, 123, True, "Deploy to WebApp"]
        result = sanitize_steps(input_list)
        self.assertEqual(result, ["Deploy to WebApp"])

    def test_sanitize_variables_with_valid_entries(self):
        input_list = ["Database.ConnectionString", "Variable 2", "Variable 3"]
        result = sanitize_variables(input_list)
        self.assertEqual(result, ["Database.ConnectionString"])

    def test_sanitize_variables_with_ignored_entries(self):
        input_list = ["Any", "all", "*", "Variable 1", "Variable 2"]
        result = sanitize_variables(input_list)
        self.assertEqual(result, [])

    def test_sanitize_variables_with_empty_list(self):
        input_list = []
        result = sanitize_variables(input_list)
        self.assertEqual(result, [])

    def test_sanitize_variables_with_non_string_entries(self):
        input_list = [None, 123, True, "Database.ConnectionString"]
        result = sanitize_variables(input_list)
        self.assertEqual(result, ["Database.ConnectionString"])

    def test_sanitize_dates_with_valid_entries(self):
        input_list = ["2023-01-01", "2023-12-31"]
        result = sanitize_dates(input_list)
        self.assertEqual(
            result, ["2023-01-01T00:00:00+00:00", "2023-12-31T00:00:00+00:00"]
        )

    def test_sanitize_dates_with_valid_entries_with_offsets(self):
        input_list = ["2023-01-01T00:00:00+10:00"]
        result = sanitize_dates(input_list)
        self.assertEqual(result, ["2023-01-01T00:00:00+10:00"])

    def test_sanitize_dates_with_relative_dates(self):
        input_list = ["today", "yesterday", "tomorrow"]
        result = sanitize_dates(input_list)
        self.assertEqual(result, [])

    def test_sanitize_dates_with_empty_list(self):
        input_list = []
        result = sanitize_dates(input_list)
        self.assertEqual(result, [])

    def test_sanitize_dates_with_non_string_entries(self):
        input_list = [None, 123, True, "2023-01-01"]
        result = sanitize_dates(input_list)
        self.assertEqual(result, ["2023-01-01T00:00:00+00:00"])

    def test_sanitize_dates_with_invalid_dates(self):
        input_list = ["invalid date", "another invalid date"]
        result = sanitize_dates(input_list)
        self.assertEqual(result, [])

    def test_force_to_list_with_list(self):
        input_data = ["item1", "item2"]
        result = force_to_list(input_data)
        self.assertEqual(result, ["item1", "item2"])

    def test_force_to_list_with_string(self):
        input_data = "item"
        result = force_to_list(input_data)
        self.assertEqual(result, ["item"])

    def test_force_to_list_with_none(self):
        input_data = None
        result = force_to_list(input_data)
        self.assertEqual(result, [])

    def test_force_to_list_with_integer(self):
        input_data = 123
        result = force_to_list(input_data)
        self.assertEqual(result, ["123"])

    def test_force_to_list_with_boolean(self):
        input_data = True
        result = force_to_list(input_data)
        self.assertEqual(result, ["True"])

    def test_get_item_or_default_with_valid_index(self):
        array = [1, 2, 3]
        result = get_item_or_default(array, 1, 0)
        self.assertEqual(result, 2)

    def test_get_item_or_default_with_invalid_index(self):
        array = [1, 2, 3]
        result = get_item_or_default(array, 5, 0)
        self.assertEqual(result, 0)

    def test_get_item_or_default_with_empty_array(self):
        array = []
        result = get_item_or_default(array, 0, "default")
        self.assertEqual(result, "default")

    def test_get_item_or_default_with_none_array(self):
        array = None
        result = get_item_or_default(array, 0, "default")
        self.assertEqual(result, "default")

    def test_get_key_or_none_with_existing_key(self):
        source = {"key1": "value1", "key2": "value2"}
        result = get_key_or_none(source, "key1")
        self.assertEqual(result, "value1")

    def test_get_key_or_none_with_non_existing_key(self):
        source = {"key1": "value1", "key2": "value2"}
        result = get_key_or_none(source, "key3")
        self.assertIsNone(result)

    def test_get_key_or_none_with_none_source(self):
        source = None
        result = get_key_or_none(source, "key1")
        self.assertIsNone(result)

    def test_get_key_or_none_with_empty_source(self):
        source = {}
        result = get_key_or_none(source, "key1")
        self.assertIsNone(result)

    def test_flatten_list_with_nested_lists(self):
        input_data = [[1, 2], [3, 4], [5, 6]]
        result = flatten_list(input_data)
        self.assertEqual(result, [1, 2, 3, 4, 5, 6])

    def test_flatten_list_with_empty_lists(self):
        input_data = [[], [], []]
        result = flatten_list(input_data)
        self.assertEqual(result, [])

    def test_flatten_list_with_mixed_empty_and_non_empty_lists(self):
        input_data = [[1, 2], [], [3, 4]]
        result = flatten_list(input_data)
        self.assertEqual(result, [1, 2, 3, 4])

    def test_flatten_list_with_single_list(self):
        input_data = [[1, 2, 3, 4]]
        result = flatten_list(input_data)
        self.assertEqual(result, [1, 2, 3, 4])

    def test_flatten_list_with_no_nested_lists(self):
        input_data = []
        result = flatten_list(input_data)
        self.assertEqual(result, [])

    def test_yield_first_with_non_empty_list(self):
        input_data = [1, 2, 3]
        result = list(yield_first(input_data))
        self.assertEqual(result, [1])

    def test_yield_first_with_empty_list(self):
        input_data = []
        result = list(yield_first(input_data))
        self.assertEqual(result, [])

    def test_yield_first_with_none(self):
        input_data = None
        result = list(yield_first(input_data))
        self.assertEqual(result, [])

    def test_yield_first_with_single_element(self):
        input_data = [42]
        result = list(yield_first(input_data))
        self.assertEqual(result, [42])

    def test_get_item_fuzzy_generator_with_exact_match(self):
        def items_generator():
            return [{"Name": "item1"}, {"Name": "item2"}, {"Name": "item3"}]

        result = get_item_fuzzy_generator(items_generator, "item2")
        self.assertEqual(result, {"original": "item2", "matched": {"Name": "item2"}})

    def test_get_item_fuzzy_generator_with_case_insensitive_match(self):
        def items_generator():
            return [{"Name": "Item1"}, {"Name": "item2"}, {"Name": "item3"}]

        result = get_item_fuzzy_generator(items_generator, "item1")
        self.assertEqual(result, {"original": "item1", "matched": {"Name": "Item1"}})

    def test_get_item_fuzzy_generator_with_fuzzy_match(self):
        def items_generator():
            return [{"Name": "itm1"}, {"Name": "item2"}, {"Name": "item3"}]

        result = get_item_fuzzy_generator(items_generator, "item1")
        self.assertEqual(result["original"], "item1")
        self.assertEqual(result["matched"]["Name"], "itm1")

    def test_get_item_fuzzy_generator_with_empty_generator(self):
        def items_generator():
            return []

        result = get_item_fuzzy_generator(items_generator, "item1")
        self.assertIsNone(result)

    def test_none_if_falesy_or_all_with_empty_list(self):
        input_list = []
        result = none_if_falesy_or_all(input_list)
        self.assertIsNone(result)

    def test_none_if_falesy_or_all_with_none(self):
        input_list = None
        result = none_if_falesy_or_all(input_list)
        self.assertIsNone(result)

    def test_none_if_falesy_or_all_with_all_string(self):
        input_list = ["<all>"]
        result = none_if_falesy_or_all(input_list)
        self.assertIsNone(result)

    def test_none_if_falesy_or_all_with_non_empty_list(self):
        input_list = ["item1", "item2"]
        result = none_if_falesy_or_all(input_list)
        self.assertEqual(result, ["item1", "item2"])

    def test_none_if_falesy_or_all_with_mixed_list(self):
        input_list = ["<all>", "item1"]
        result = none_if_falesy_or_all(input_list)
        self.assertEqual(result, ["<all>", "item1"])
