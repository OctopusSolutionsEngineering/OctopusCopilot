def octolint_deployment_queue_wrapper(callback, logging):
    def octolint_deployment_queue(space=None, project=None, **kwargs):
        """
        **ONLY use this function when the user explicitly asks to detect, check, or find deployments that have been queued.**

        Checks for deployments that were queued, indicating that the task cap was reached.
        Example prompts include:
        * Find deployments that were queued in the space "MySpace".
        * Create a report on queued deployments in project "MyProject".
        * List deployments that have been queued recently.

        **DO NOT use this function for:**
        * General questions around deployments.
        * Questions concerning the size of the task cap.
        * Listing deployment details.

        Args:
        space: The name of the space to run the check in.
        project: The name of the project to run the check in.
        """

        if logging:
            logging("Enter:", "octolint_deployment_queue")

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        return callback(space, project)

    return octolint_deployment_queue
