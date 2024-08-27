def show_github_job_summary_wrapper(original_query, callback, log_query):
    def show_github_job_summary(owner=None, repo=None, workflow=None, run=None, **kwargs):
        """Displays the summary of a github workflow run. The owner and repo may be supplied in the format owner/repo.

        Example prompts include:
        * Show the Github Workflow summary
        * Show the Github Workflow summary for the project "MyProject"
        * Show the Github Workflow summary for the project "MyProject" in space "Default"

        Args:
            owner: The github repo owner
            repo: The github repo name
            workflow: The github actions workflow name
            run: The github actions workflow run
        """

        for key, value in kwargs.items():
            if log_query:
                log_query(f"Unexpected Key: {key}", "Value: {value}")

        return callback(original_query, owner, repo, workflow, run)

    return show_github_job_summary
