from enum import Enum


class DataSource(Enum):
    HCL_CONFIGURATION = 1
    PROJECT_PROGRESSION = 2
    DASHBOARD_PROGRESSION = 4


def get_data_source(query, project_names):
    """
    Make a decision about where to source the context for the query.
    :param query: The query from the user
    :param project_names: The datasource location that will answer the query
    :return:
    """
    if "deployment" in query.lower() or "release" in query.lower():
        if project_names:
            return DataSource.PROJECT_PROGRESSION
        else:
            return DataSource.DASHBOARD_PROGRESSION

    return DataSource.HCL_CONFIGURATION
