import unittest

from domain.exceptions.not_authorized import NotAuthorized
from domain.security.security import call_admin_function, is_admin_user


class AdminUser(unittest.TestCase):
    def test_is_admin_user(self):
        self.assertTrue(is_admin_user("123", "[123]"))
        self.assertTrue(is_admin_user(123, "[123]"))
        self.assertTrue(is_admin_user(123, '["123"]'))
        self.assertFalse(is_admin_user("123", "[1234]"))
        self.assertFalse(is_admin_user("123", '["1234"]'))
        self.assertFalse(is_admin_user("123", "Invalid JSON"))

    def test_call_admin_function(self):
        call_admin_function("123", "[123]", lambda: print("success"))

    def test_no_callabck(self):
        call_admin_function("123", "[123]", None)

    def test_empty_is_not_admin_user(self):
        try:
            call_admin_function(None, "[123]", lambda: print("success"))
            self.fail()
        except NotAuthorized as e:
            pass

    def test_no_list_is_not_admin_user(self):
        try:
            call_admin_function(123, None, lambda: print("success"))
            self.fail()
        except NotAuthorized as e:
            pass

    def test_empty_list_is_not_admin_user(self):
        try:
            call_admin_function("123", " ", lambda: print("success"))
            self.fail()
        except NotAuthorized as e:
            pass

    def test_is_admin_user_array_string(self):
        try:
            call_admin_function(123, '["123"]', lambda: print("success"))
            self.fail()
        except NotAuthorized as e:
            pass

    def test_is_admin_user_string(self):
        call_admin_function("123", "[123]", lambda: print("success"))

    def test_is_admin_user_both_strings(self):
        call_admin_function("123", '["123"]', lambda: print("success"))

    def test_is_admin_user_not_found(self):
        try:
            call_admin_function("1233", '["123"]', lambda: print("success"))
            self.fail()
        except NotAuthorized as e:
            pass

    def test_is_admin_list_is_string(self):
        try:
            call_admin_function("12", '"123"', lambda: print("success"))
            self.fail()
        except NotAuthorized as e:
            pass

    def test_is_admin_list_is_object(self):
        try:
            call_admin_function("12", '{"123": true}', lambda: print("success"))
            self.fail()
        except NotAuthorized as e:
            pass

    def test_invalid_json(self):
        try:
            call_admin_function("123", "{", lambda: print("success"))
            self.fail()
        except NotAuthorized as e:
            pass
