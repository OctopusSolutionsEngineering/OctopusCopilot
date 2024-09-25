import unittest

from domain.config.codefresh import get_codefresh_url
from domain.exceptions.user_not_loggedin import CodefreshTokenInvalid
from infrastructure.codefresh import get_codefresh_user, get_query, execute_graph_query


class CodefreshAPIRequests(unittest.TestCase):

    def test_execute_graph_query_invalid_token(self):
        with self.assertRaises(CodefreshTokenInvalid):
            user_query = get_query('user', 'infrastructure/queries')
            execute_graph_query(get_codefresh_url(), "000000000000000000000000.00000000000000000000000000000000",
                                user_query)
