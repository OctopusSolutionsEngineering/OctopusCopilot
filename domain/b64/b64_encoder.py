from base64 import b64encode, b64decode


def encode_string_b64(input):
    b64_bytes = b64encode(input.encode('utf-8'))
    b64_string = b64_bytes.decode('ascii')
    return b64_string


def decode_string_b64(input):
    input_bytes = b64decode(input)
    string = input_bytes.decode('utf-8')
    return string
