import os


def get_functions_connection_string():
    return os.environ.get("AzureWebJobsStorage")
