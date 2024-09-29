import unittest

from domain.query.query_inspector import exclude_all_targets


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
