from base64 import b64encode, b64decode

from domain.validation.argument_validation import ensure_string_not_empty


def encode_string_b64(input_value):
    """Encodes a string as base64. It assumes a utf-8 input string.

    input_value: The string to be encoded
    """

    ensure_string_not_empty(input_value, 'input_value must be the value to encode (encode_string_b64).')

    b64_bytes = b64encode(input_value.encode('utf-8'))
    b64_string = b64_bytes.decode('ascii')
    return b64_string


def decode_string_b64(input_value):
    """Decodes a base64 string. It assumes a utf-8 output string.

    input: The base64 string to be decoded
    """

    ensure_string_not_empty(input_value, 'input_value must be the value to decode (decode_string_b64).')

    input_bytes = b64decode(input_value)
    string = input_bytes.decode('utf-8')
    return string
