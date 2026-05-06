import json
import os

from domain.sanitizers.sanitize_strings import empty_if_none


def get_enhanced_logging_instances():
    instances = empty_if_none(os.getenv("ENHANCED_LOGGING_INSTANCES"))
    try:
        return json.loads(instances) if instances else []
    except json.JSONDecodeError:
        return []
