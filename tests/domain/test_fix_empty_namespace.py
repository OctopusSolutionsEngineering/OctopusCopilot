import unittest

from domain.sanitizers.terraform import fix_empty_namespace


class FixEmptyNamespaceTests(unittest.TestCase):
    def test_removes_empty_namespace(self):
        config = '"Octopus.Action.KubernetesContainers.Namespace" = ""'
        self.assertEqual("", fix_empty_namespace(config))

    def test_removes_empty_namespace_with_extra_whitespace_around_equals(self):
        config = '"Octopus.Action.KubernetesContainers.Namespace"   =   ""'
        self.assertEqual("", fix_empty_namespace(config))

    def test_does_not_remove_non_empty_namespace(self):
        config = '"Octopus.Action.KubernetesContainers.Namespace" = "my-namespace"'
        self.assertEqual(config, fix_empty_namespace(config))

    def test_removes_empty_namespace_inline(self):
        config = (
            'execution_properties = {\n'
            '  "Octopus.Action.KubernetesContainers.Namespace" = ""\n'
            '  "Octopus.Action.Script.ScriptSource" = "Inline"\n'
            '}'
        )
        result = fix_empty_namespace(config)
        self.assertNotIn('"Octopus.Action.KubernetesContainers.Namespace"', result)
        self.assertIn('"Octopus.Action.Script.ScriptSource" = "Inline"', result)

    def test_returns_empty_string_unchanged(self):
        self.assertEqual("", fix_empty_namespace(""))

    def test_raises_on_none_input(self):
        with self.assertRaises(TypeError):
            fix_empty_namespace(None)

    def test_does_not_affect_unrelated_properties(self):
        config = '"Octopus.Action.Script.ScriptSource" = "Inline"'
        self.assertEqual(config, fix_empty_namespace(config))

    def test_removes_multiple_empty_namespaces(self):
        config = (
            '"Octopus.Action.KubernetesContainers.Namespace" = ""\n'
            '"Octopus.Action.KubernetesContainers.Namespace" = ""\n'
        )
        result = fix_empty_namespace(config)
        self.assertNotIn('"Octopus.Action.KubernetesContainers.Namespace"', result)


if __name__ == "__main__":
    unittest.main()
