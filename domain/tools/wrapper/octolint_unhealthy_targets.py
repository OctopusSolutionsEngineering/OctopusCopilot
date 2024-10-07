import asyncio

from domain.lookup.octopus_multi_lookup import lookup_space_level_resources
from infrastructure.octolint import run_octolint_check_async


def octolint_unhealthy_targets_wrapper(callback, logging):
    def octolint_unhealthy_targets(space=None, **kwargs):
        """
        Checks for unhealthy targets or machines in the space. Example prompts include:
        * Check for unhealthy targets in the space "MySpace".
        * Locate machines that have not passed a health check in the space "MySpace".
        * Find unhealthy machines in the space "MySpace".

        Args:
        space: The name of the space to run the check in.
        """

        if logging:
            logging("Enter:", "octolint_unhealthy_targets")

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        return callback(space)

    return octolint_unhealthy_targets
