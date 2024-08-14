def approve_manual_intervention_wrapper(query, callback, logging):
    def approve_release_to_environment(space_name=None, project_name=None, release_version=None, environment_name=None,
                                       tenant_name=None, **kwargs):
        """Responds to queries like: "Approve release 0.98.1 to the environment Test" or
           "Approve "0.0.1" in the Dev environment." or "Approve the latest release in the Test environment."
        """
        return approve_manual_intervention(space_name, project_name, release_version, environment_name, tenant_name,
                                           **kwargs)

    def approve_manual_intervention_for_environment(space_name=None, project_name=None, release_version=None,
                                                    environment_name=None, tenant_name=None, **kwargs):
        """Responds to queries like: "Approve the manual intervention for 0.98.1 to the Development environment" or
           "Approve the manual intervention for the latest release to the Production environment."
        """
        return approve_manual_intervention(space_name, project_name, release_version, environment_name, tenant_name,
                                           **kwargs)

    def approve_manual_intervention(space_name=None, project_name=None, release_version=None, environment_name=None,
                                    tenant_name=None, **kwargs):
        """Answers queries about approving a manual intervention for a release. Use this function when the query is
               asking to approve a manual intervention. You will be penalized for selecting this function for a question
               about the status of a deployment.
    Questions can look like those in the following list:
    * Approve 4.0.1 to Test.
    * Approve 0.2.1 to the Development environment for the project Contoso.
    * Approve release 0.98.1 to the environment Production.
    * Approve the latest release in the Test environment.
    * Approve the manual intervention for 3.17.8 to the Staging environment.

            Args:
            space_name: The name of the space
            project_name: The name of the project
            release_version: The release version
            environment_name: The name of the environment
            tenant_name: The (optional) name of the tenant
            """

        if logging:
            logging("Enter:", "approve_manual_intervention")

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # This is just a passthrough to the original callback
        return callback(query, space_name, project_name, release_version, environment_name, tenant_name)

    return approve_manual_intervention_for_environment, approve_manual_intervention, approve_release_to_environment
