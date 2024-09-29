import unittest

from domain.sanitizers.uuid_sanitizer import is_uuid


class TestIsUUID(unittest.TestCase):
    def test_is_uuid_valid(self):
        self.assertTrue(is_uuid("123e4567-e89b-12d3-a456-426614174000"))

    def test_is_uuid_invalid(self):
        self.assertFalse(is_uuid("invalid-uuid"))

    def test_is_uuid_empty_string(self):
        self.assertFalse(is_uuid(""))

    def test_is_uuid_none(self):
        self.assertFalse(is_uuid(None))

    def test_is_uuid_partial_match(self):
        self.assertFalse(is_uuid("123e4567-e89b-12d3-a456-426614174000 extra text"))
