import json
import unittest
from unittest.mock import Mock
from domain.requestparsing.extract_query import (
    extract_confirmation_state_and_id,
    extract_query,
)


class TestExtractQuery(unittest.TestCase):
    def test_extract_confirmation_state_and_id(self):
        req = Mock()
        req.get_body.return_value = json.dumps(
            {
                "messages": [
                    {
                        "copilot_confirmations": [
                            {"state": "accepted", "confirmation": {"id": "123"}}
                        ]
                    }
                ]
            }
        ).encode("utf-8")
        state, confirmation_id = extract_confirmation_state_and_id(req)
        self.assertEqual(state, "accepted")
        self.assertEqual(confirmation_id, "123")

        req.get_body.return_value = b""
        state, confirmation_id = extract_confirmation_state_and_id(req)
        self.assertIsNone(state)
        self.assertIsNone(confirmation_id)

    def test_extract_confirmation_invalid_json(self):
        req = Mock()
        req.get_body.return_value = "Invalid JSON".encode("utf-8")
        state, confirmation_id = extract_confirmation_state_and_id(req)
        self.assertIsNone(state)
        self.assertIsNone(confirmation_id)

    def test_extract_query(self):
        req = Mock()
        req.params = {"message": "test query"}
        req.get_body.return_value = b""
        query = extract_query(req)
        self.assertEqual(query, "test query")

        req.params = {}
        req.get_body.return_value = json.dumps(
            {"messages": [{"content": "test query"}]}
        ).encode("utf-8")
        query = extract_query(req)
        self.assertEqual(query, "test query")

        req.get_body.return_value = b""
        query = extract_query(req)
        self.assertEqual(query, "")

    def test_extract_invalid_json_query(self):
        req = Mock()
        req.params = {}
        req.get_body.return_value = "Invalid JSON".encode("utf-8")
        query = extract_query(req)
        self.assertEqual(query, "")


if __name__ == "__main__":
    unittest.main()
