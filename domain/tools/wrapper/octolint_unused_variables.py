import asyncio

from domain.lookup.octopus_multi_lookup import lookup_space_level_resources
from infrastructure.octolint import run_octolint_check_async


def octolint_unused_variables_wrapper(callback, logging):
    def octolint_unused_variables(space=None, **kwargs):
        """
        Checks for unused variables in projects the space. Example prompts include:
        * Check for unused variables in the space "MySpace".
        * Find unused project variables in the space "MySpace".

        Args:
        space: The name of the space to run the check in.
        """

        if logging:
            logging("Enter:", "octolint_unused_variables")

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        return callback(space)

    return octolint_unused_variables
