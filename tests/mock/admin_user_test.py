import unittest

from domain.security.security import is_admin_user


class AdminUser(unittest.TestCase):
    def test_is_admin_user(self):
        is_admin_user(lambda: 123, lambda: "[123]", lambda: print("success"))
