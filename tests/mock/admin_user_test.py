import unittest

from domain.exceptions.not_authorized import NotAuthorized
from domain.security.security import is_admin_user


class AdminUser(unittest.TestCase):
    def test_is_admin_user(self):
        is_admin_user(lambda: 123, lambda: "[123]", lambda: print("success"))

    def test_is_admin_user_array_string(self):
        is_admin_user(lambda: 123, lambda: "[\"123\"]", lambda: print("success"))

    def test_is_admin_user_string(self):
        is_admin_user(lambda: '123', lambda: "[123]", lambda: print("success"))

    def test_is_admin_user_both_strings(self):
        is_admin_user(lambda: '123', lambda: "[\"123\"]", lambda: print("success"))

    def test_is_admin_user_not_found(self):
        try:
            is_admin_user(lambda: '1233', lambda: "[\"123\"]", lambda: print("success"))
            self.fail()
        except NotAuthorized as e:
            pass

    def test_is_admin_list_is_string(self):
        try:
            is_admin_user(lambda: '12', lambda: "\"123\"", lambda: print("success"))
            self.fail()
        except NotAuthorized as e:
            pass

    def test_is_admin_list_is_object(self):
        try:
            is_admin_user(lambda: '12', lambda: "{\"123\": true}", lambda: print("success"))
            self.fail()
        except NotAuthorized as e:
            pass
