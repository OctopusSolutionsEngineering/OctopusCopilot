from base64 import b64encode, b64decode


def encode_string_b64(input):
    """Encodes a string as base64. It assumes a utf-8 input string.

    input: The string to be encoded
    """
    b64_bytes = b64encode(input.encode('utf-8'))
    b64_string = b64_bytes.decode('ascii')
    return b64_string


def decode_string_b64(input):
    """Decodes a base64 string. It assumes a utf-8 output string.

    input: The base64 string to be decoded
    """
    input_bytes = b64decode(input)
    string = input_bytes.decode('utf-8')
    return string
