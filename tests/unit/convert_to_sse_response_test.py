import json
import unittest

from domain.transformers.sse_transformers import convert_to_sse_response


class ConvertToSseResponse(unittest.TestCase):
    def test_convert_to_sse_response(self):
        self.assertEqual(json.loads(convert_to_sse_response("hi").replace("data:", "")).get('choices')[0].get('delta').get('content'), "hi")
