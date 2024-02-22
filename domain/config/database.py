import os


def get_functions_connection_string():
    """
    returns the database connection string for the live application
    :return: The database connection string
    """
    return os.environ.get("AzureWebJobsStorage")
