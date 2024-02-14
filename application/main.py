import argparse

from domain.handlers.copilot_handler import handle_copilot_chat, handle_copilot_chat_live
from domain.tools.build_tools import build_tools


def init_argparse():
    parser = argparse.ArgumentParser(
        usage='%(prog)s [OPTION] [FILE]...',
        description='Query the Octopus Copilot agent'
    )
    parser.add_argument('--query', action='store')
    return parser.parse_known_args()


parser, _ = init_argparse()

result = handle_copilot_chat_live(parser.query)
print(result)