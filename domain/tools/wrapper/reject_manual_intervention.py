def reject_manual_intervention_wrapper(query, callback, logging):
    def reject_release_to_environment(space_name=None, project_name=None, release_version=None, environment_name=None,
                                      tenant_name=None, **kwargs):
        """Responds to queries like: "Reject release 0.98.1 to the environment Test" or
           "Reject "0.0.1" in the Dev environment." or "Reject the latest release in the Test environment."
        """
        return reject_manual_intervention(reject_release_to_environment.__name__, space_name, project_name,
                                          release_version, environment_name, tenant_name, **kwargs)

    def reject_manual_intervention_for_environment(space_name=None, project_name=None, release_version=None,
                                                   environment_name=None, tenant_name=None, **kwargs):
        """Responds to queries like: "Reject the manual intervention for 0.98.1 to the Development environment" or
           "Reject the manual intervention for the latest release to the Production environment."
        """
        return reject_manual_intervention(reject_manual_intervention_for_environment.__name__, space_name,
                                          project_name, release_version, environment_name, tenant_name, **kwargs)

    def reject_manual_intervention(confirm_callback_function_name=None, space_name=None, project_name=None, release_version=None, environment_name=None,
                                   tenant_name=None, **kwargs):
        """Answers queries about rejecting or aborting a manual intervention for a release. Use this function when the query is
           asking to reject or abort a manual intervention. You will be penalized for selecting this function for a question
           about the status of a deployment or about approving a manual intervention.
    Questions can look like those in the following list:
    * Reject 4.0.1 to Test.
    * Reject 0.2.1 to the Development environment for the project Contoso.
    * Reject release 0.98.1 to the environment Production.
    * Reject the latest release in the Test environment.
    * Reject the manual intervention for 3.17.8 to the Staging environment.

            Args:
            space_name: The name of the space
            project_name: The name of the project
            release_version: The release version
            environment_name: The name of the environment
            tenant_name: The (optional) name of the tenant
            """

        if logging:
            logging("Enter:", "reject_manual_intervention")

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # Fallback incase this is the function chosen by the LLM.
        if confirm_callback_function_name is None:
            confirm_callback_function_name = reject_manual_intervention.__name__

        # This is just a passthrough to the original callback
        return callback(confirm_callback_function_name, query, space_name, project_name, release_version, environment_name, tenant_name)

    return reject_manual_intervention_for_environment, reject_manual_intervention, reject_release_to_environment
