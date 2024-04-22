import json
import unittest

from domain.transformers.sse_transformers import convert_to_sse_response, convert_from_sse_response


class ConvertToSseResponse(unittest.TestCase):
    def test_convert_to_sse_response(self):
        self.assertEqual(
            json.loads(convert_to_sse_response("hi").split("\n")[0].replace("data:", "")).get('choices')[0].get(
                'delta').get(
                'content'), "hi\n")

    def test_convert_to_and_from_sse_response(self):
        self.assertEqual(convert_from_sse_response(convert_to_sse_response("hi")), "hi")
        self.assertEqual(convert_from_sse_response(convert_to_sse_response("hi\nthere")), "hi\nthere")

    def test_convert_to_sse_response_stop(self):
        self.assertEqual(
            json.loads(
                list(filter(lambda line: line, convert_to_sse_response("hi").split("\n")))[-1].replace("data:",
                                                                                                       "")).get(
                'choices')[0].get(
                'finish_reason'), "stop")

    def test_convert_to_sse_empty_response_stop(self):
        self.assertEqual(
            json.loads(
                list(filter(lambda line: line, convert_to_sse_response("").split("\n")))[0].replace("data:", "")).get(
                'choices')[0].get(
                'finish_reason'), "stop")
