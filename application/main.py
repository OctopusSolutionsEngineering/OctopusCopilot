import argparse

from domain.app_logging import configure_logging
from domain.copilot_handler import handle_copilot_chat


def init_argparse():
    parser = argparse.ArgumentParser(
        usage='%(prog)s [OPTION] [FILE]...',
        description='Query the Octopus Copilot agent'
    )
    parser.add_argument('--query', action='store')
    return parser.parse_known_args()


parser, _ = init_argparse()

handle_copilot_chat(parser.query)