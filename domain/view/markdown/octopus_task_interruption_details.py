def format_interruption_details(project_name, release_version, environment_name, tenant_name, space_name,
                                interruption_action):
    query_details = [f"\n* Project: **{project_name}**"
                     f"\n* Version: **{release_version}**"
                     f"\n* Environment: **{environment_name}**"]
    if tenant_name:
        query_details.append(f"\n* Tenant: **{tenant_name}**")

    query_details.append(f"\n* Space: **{space_name}**")
    query_details.append(f"\n* Action: **{interruption_action}**\n\n")

    return query_details
