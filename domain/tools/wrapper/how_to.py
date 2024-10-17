from domain.sanitizers.sanitized_list import sanitize_list


def how_to_wrapper(query, callback, logging):
    def how_do_i(keywords=None, **kwargs):
        """Answers a question about how to do something. Use this function when the query is asking a general question.
        Questions can look like those in the following list:
        * How do I integrate with jenkins?
        * How do I do deployments?
        * How can I enable config-as-code?
        * How do I add a runbook?
        * How do I remove a feed?
        * How do I configure subscriptions?
        * How do I find releases?
        * How do I use channels?
        * How do I create accounts?
        * How do I disable tenants?
        * How do I setup SIEM?
        * How do I setup a target?
        * How do I set up an agent?
        * How do I enable projects?
        * How do I enable something in something?
        * How do I enable something for something?

        Args:
        keywords: The keywords extracted from the query
        """

        return provide_help_and_instructions(keywords, **kwargs)

    def provide_help_and_instructions(keywords=None, **kwargs):
        """Answers questions like how or where to create, use, add, remove, setup, enable, disable, configure, or find
        Octopus Deploy features like: Projects, Environments, Lifecycles, Channels, Deployments, Releases,
        Deployment Processes, Variables, Lifecycle Events, Integrations, Retention Policies, Security,
        Audit Logs, Targets, Machines, Agents, Authentication, polling and listening Tentacles, SSH, Step Templates, Licenses,
        Metrics, DORA, DORA metrics, Config-as-Code (CaC), OCL, community step templates, using the CLI, code samples,
        REST API, explanations of high level concepts, integration with continuous integration (CI) servers, integration
        with ServiceNow (SNOW) and Jira service Manager (JSM), details on metrics like deployment frequency,
        lead time for changes, change failure rate, and recovery time, and how and where to measure, view, and generate
        these metrics.

        Args:
        keywords: The keywords extracted from the query
        """

        if logging:
            logging("Enter:", "provide_help_and_instructions")

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # This is just a passthrough to the original callback
        return callback(query, sanitize_list(keywords))

    return how_do_i, provide_help_and_instructions
