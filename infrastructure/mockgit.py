import http
import json
import os

from domain.logging.app_logging import configure_logging
from infrastructure.octopus import logging_wrapper

logger = configure_logging(__name__)


@logging_wrapper
def save_mockgit_user(username, password):
    """
    Adds a user to the mock git service
    :param username: The Mock git username
    :param password: The Mock git password
    """

    try:
        if username is None or password is None:
            return None

        api = os.getenv("MOCKGIT_API_URL") + "/api/credentials"

        body = {
            "data": {
                "type": "credentials",
                "id": username,
                "attributes": {"password": password},
            }
        }

        headers = {
            "X_MOCKGIT_SERVICE_API_KEY": os.getenv("MOCKGIT_API_KEY"),
            "Content-Type": "application/json",
        }

        resp = http.request(
            "PUT",
            api,
            headers=headers,
            body=json.dumps(body),
        )

        if resp.status != 200:
            # This is just a best effort and must not interfere with the main flow
            logger.warn(
                f"Failed to save user to mock git service. Status: {resp.status}"
            )
        else:
            logger.info(f"Successfully saved user {username} to mock git service.")

    except Exception as e:
        # This is just a best effort and so we swallow exceptions
        logger.warn(
            f"Exception occurred while saving user to mock git service: {str(e)}"
        )
