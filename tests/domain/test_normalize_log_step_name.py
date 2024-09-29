import unittest

from domain.sanitizers.sanitized_list import normalize_log_step_name


class NormalizeStepName(unittest.TestCase):
    def test_parsing(self):
        self.assertEqual(normalize_log_step_name('Step 1: blah'), 'blah')
        self.assertEqual(normalize_log_step_name('Step 2: blah'), 'blah')
        self.assertEqual(normalize_log_step_name('Step x: blah'), 'step x: blah')
        self.assertEqual(normalize_log_step_name(None), '')
        self.assertEqual(normalize_log_step_name(''), '')
        self.assertEqual(normalize_log_step_name(' '), '')
        self.assertEqual(normalize_log_step_name('blah'), 'blah')
