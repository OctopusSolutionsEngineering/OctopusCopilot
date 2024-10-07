import asyncio

from domain.lookup.octopus_multi_lookup import lookup_space_level_resources
from infrastructure.octolint import run_octolint_check_async


def octolint_duplicate_variables_wrapper(callback, logging):
    def octolint_duplicate_variables(space=None, **kwargs):
        """
        Checks for duplicate or copied variables in projects. Example prompts include:
        * Check for duplicate variables in the space "MySpace".
        * Find copied variables in the space "MySpace".

        Args:
        space: The name of the space to run the check in.
        """

        if logging:
            logging("Enter:", "octolint_duplicate_variables")

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        return callback(space)

    return octolint_duplicate_variables
