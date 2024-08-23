def cancel_task_wrapper(query, callback, logging):
    def cancel_task(space_name=None, task_id=None, project_name=None, **kwargs):
        """Answers queries about canceling a task. Use this function when the query is asking to cancel a task.
    Questions can look like those in the following list:
    * Cancel the task id "ServerTasks-32495"
    * Cancel the task "ServerTasks-112747"

            Args:
            space_name: The name of the space
            task_id: The server task
            project_name: The name of the project
            """

        if logging:
            logging("Enter:", "cancel_task")

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # This is just a passthrough to the original callback
        return callback(query,
                        space_name,
                        project_name,
                        task_id)

    return cancel_task
