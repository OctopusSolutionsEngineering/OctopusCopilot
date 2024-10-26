from domain.defaults.defaults import get_default_argument
from domain.errors.error_handling import handle_error
from domain.ghu.is_ghu import is_ghu_server
from domain.response.copilot_response import CopilotResponse
from domain.sanitizers.sanitize_strings import strip_leading_whitespace
from infrastructure.octopus import (
    get_spaces_generator,
    get_space_first_project_runbook_and_environment,
    get_space_id_and_name_from_name,
)


def provide_help_wrapper(github_user, octopus_details, log_query):
    def say_hello():
        """Responds to greetings like "hello" or "hi" """
        return provide_help()

    def what_do_you_do():
        """Responds to questions like "What do you do?" """
        return provide_help()

    def what_can_i_ask():
        """Responds to questions like "What questions can I ask?" """
        return provide_help()

    def provide_help():
        """Provide help and example queries, answers questions about what the agent does,
        responds to greetings, responds to a prompt like "hello" or "hi",
        answers questions like "What do you do?" or "How do I get started?" or "how can I use this?" or "What questions can I ask?",
        provides details on how to get started, provides details on how to use the agent, and provides documentation and support.
        """

        api_key, url = octopus_details()

        # This is a hard coded
        if is_ghu_server(url):
            return ghu_help(github_user, api_key, url, log_query)
        else:
            return default_help(github_user, api_key, url, log_query)

    return provide_help, say_hello, what_do_you_do, what_can_i_ask


def ghu_help(github_user, api_key, url, log_query):
    space_name = "DevEx"

    return CopilotResponse(
        strip_leading_whitespace(
            f"""Welcome to GitHub Universe 2024! Use the prompts below to participate in the sandbox session.

            # 1. Set Default Space
            This prompt sets the default Octopus Deploy space for subsequent prompts:
            * `@octopus-ai-app Set default value for Space to "{space_name}"`

            # 2. Dashboard Query
            This prompt shows the Octopus Deploy dashboard, showing project deployments to environments:
            * `@octopus-ai-app Show me the dashboard"`

            # 3. Create a Project
            This prompt creates a new pipeline from the template.
            IMPORTANT: Make sure you specify your unique `Project Name` at the end of this prompt:
            * `@octopus-ai-app Run the runbook "Create Pipeline" in the project "Microservice Template" in the "Administration" environment with variables: Project Name=`

            # 4. Explain the Project
            These prompts describe the steps for your pipeline as well as for the supporting runbook.
            IMPORTANT: Make sure you replace `MyNewProject` with the name of your project:
            * `@octopus-ai-app What do the steps in the project "MyNewProject" do? Provide a high level summary.`
            * `@octopus-ai-app What do the steps in the runbook "Verify App Status" in the project "MyNewProject" do?`

            # 5. Deploy the Project
            This prompt creates a new release and deploys your project to the "Development" environment.
            IMPORTANT: Make sure you replace `MyNewProject` with the name of your project:
            * `@octopus-ai-app Create a release in the project "MyNewProject" and deploy to the "Development" environment`

            # 6. Observe Deployments
            These prompts allow you to observe deployments.
            IMPORTANT: Make sure you replace `MyNewProject` with the name of your project:
            * `@octopus-ai-app Show me the project dashboard for "MyNewProject"`
            * `@octopus-ai-app Show me the task summary for the latest release of the project "MyNewProject" in the "Development" environment`
            * `@octopus-ai-app Summarize the deployment logs for the latest deployment for the project "MyNewProject" in the "Development" environment`

            # 7. Promote Deployments
            These prompts allow you to promote deployments to the higher environments.
            IMPORTANT: Make sure you replace `MyNewProject` with the name of your project:
            * `@octopus-ai-app Deploy the latest release of project "MyNewProject" to the "Staging" environment`
            * `@octopus-ai-app Deploy the latest release of project "MyNewProject" to the "Production" environment`

            # 8. Troubleshoot deployments
            These prompts allow you to troubleshoot deployments using runbooks.
            IMPORTANT: Make sure you replace `MyNewProject` with the name of your project:
            * `@octopus-ai-app Run runbook "Verify App Status" in the "Development" environment for the project "MyNewProject"`
            * `@octopus-ai-app Summarize the execution logs of the runbook "Verify App Status" in the project "MyNewProject" in the "Development" environment`
            """
        )
    )


def default_help(github_user, api_key, url, log_query):
    space_name = get_default_argument(github_user, None, "Space")
    first_project = get_default_argument(github_user, None, "Project")
    first_runbook = get_default_argument(github_user, None, "Runbook")
    first_environment = get_default_argument(github_user, None, "Environment")

    # If we have a default space to look in, attempt to fill in any missing values from that space
    if space_name:
        try:
            default_space_id, resolved_default_space_name = (
                get_space_id_and_name_from_name(space_name, api_key, url)
            )
            (
                default_first_project,
                default_first_runbook,
                default_first_environment,
            ) = get_space_first_project_runbook_and_environment(
                default_space_id, api_key, url
            )

            if not first_project and default_first_project:
                first_project = default_first_project["Name"]

            if not first_environment and default_first_environment:
                first_environment = default_first_environment["Name"]

            if not first_runbook and default_first_runbook:
                first_runbook = default_first_runbook["Name"]
        except Exception as e:
            handle_error(e)

    # Otherwise find the first space with a project and environment
    if not space_name:
        try:
            for space in get_spaces_generator(api_key, url):
                (
                    space_first_project,
                    space_first_runbook,
                    space_first_environment,
                ) = get_space_first_project_runbook_and_environment(
                    space["Id"], api_key, url
                )

                # The first space we find with projects and environments is used as the example
                if space_first_project and space_first_environment:
                    space_name = space["Name"]
                    first_project = space_first_project["Name"]
                    first_environment = space_first_environment["Name"]

                    if space_first_runbook:
                        first_runbook = space_first_runbook["Name"]
                    break
        except Exception as e:
            handle_error(e)

    log_query(
        "provide_help",
        f"""
                    Space: {space_name}
                    Project Names: {first_project}
                    Environment Names: {first_environment}""",
    )

    # If we have a space, project, and environment, use these for the examples
    if space_name and first_project and first_environment:

        # Pick a default runbook name if we couldn't find any
        if not first_runbook:
            first_runbook = "My Runbook"

        return CopilotResponse(
            strip_leading_whitespace(
                f"""I am an AI assistant that can help you with your Octopus Deploy queries. I can answer questions about your Octopus Deploy spaces, projects, environments, deployments, and more.

                    ## Example Queries
                    Here are some sample queries you can ask:
                    * @octopus-ai-app Show me the dashboard for the space "{space_name}"
                    * @octopus-ai-app Show me the project dashboard for "{first_project}" in the space "{space_name}"
                    * @octopus-ai-app Show me the runbook dashboard for "{first_runbook}" in the project "{first_project}" in the space "{space_name}"
                    * @octopus-ai-app Show me the task summary for release "1.4.3" of the project "{first_project}" in the "{first_environment}" environment in the space "{space_name}"
                    * @octopus-ai-app List the projects in the space "{space_name}"
                    * @octopus-ai-app What do the deployment steps in the "{first_project}" project in the "{space_name}" space do?
                    * @octopus-ai-app Show me the status of the latest deployment for the project "{first_project}" in the "{first_environment}" environment in the "{space_name}" space
                    * @octopus-ai-app Show me any non-successful deployments for the "{first_project}" project in the space "{space_name}" for the "{first_environment}" environment in a markdown table. If all deployments are successful, say so.
                    * @octopus-ai-app Summarize the deployment logs for the latest deployment for the project "{first_project}" in the "{first_environment}" environment in the space called "{space_name}"
                    * @octopus-ai-app List any URLs printed in the deployment logs for the latest deployment for the project "{first_project}" in the "{first_environment}" environment in the space called "{space_name}"
                    * @octopus-ai-app How do I enable server side apply?

                    ## Runbooks
                    You can execute and monitor runbooks with prompts like these:
                    * @octopus-ai-app Run the runbook "{first_runbook}" in the project "{first_project}" in the space "{space_name}" in the "{first_environment}" environment
                    * @octopus-ai-app Summarize the execution logs of the runbook "{first_runbook}" in the project "{first_project}" in the space "{space_name}" in the "{first_environment}" environment

                    ## Releases and deployments
                    You can create and deploy a release with prompts like these:
                    * @octopus-ai-app Create a release in the project "{first_project}" with version "1.0.12-hf" and channel "Hotfix in the space "{space_name}"
                    * @octopus-ai-app Create a release in the project "{first_project}" in the space "{space_name}" and deploy to the "{first_environment}" environment
                    * @octopus-ai-app Deploy release version "1.0.1" of project "{first_project}" in the space "{space_name}" to the "{first_environment}" environment
                    * @octopus-ai-app Deploy release version "2.0.8" of project "{first_project}" in the space "{space_name}" to the environment "{first_environment}" for tenant "Contoso"

                    ## Cancelling tasks
                    You can cancel a deployment, runbook or other task with prompts like these:
                    * @octopus-ai-app Cancel the latest deployment for the project "{first_project}" to the "{first_environment}" environment
                    * @octopus-ai-app Cancel the runbook run "{first_runbook}" in the project "{first_project}" in the space "{space_name}" in the "{first_environment}" environment
                    * @octopus-ai-app Cancel task "ServerTasks-58479"

                    ## Manual interventions
                    You can approve or reject manual interventions in a deployment with prompts like these:
                    * @octopus-ai-app Approve release "0.81.5" in "{first_environment}" for the project "{first_project}"
                    * @octopus-ai-app Reject release "1.6.19" in the "{first_environment}" environment for the project "{first_project}

                    ## Deployment history
                    You can describe deployments with prompts like these:
                    * @octopus-ai-app Describe release "1.4.3" of the "{first_project}" project to the "{first_environment}" environment.
                    * @octopus-ai-app Describe release "1.4.3" of the "{first_project}" project to the "{first_environment}" environment. Generate release notes that highlight customer facing changes.
                    * @octopus-ai-app Describe release "1.4.3" of the "{first_project}" project to the "{first_environment}" environment. List any file changes that do not have matching tests.
                    * @octopus-ai-app Describe release "1.4.3" of the "{first_project}" project to the "{first_environment}" environment. List any new dependencies or changes to dependency versions in the commits. If no dependencies were added or changed, say so.

                    ## Default values
                    By setting default values for the space, project, environment, and other entities, you can omit them from your queries.
                    This way, you can write prompts without specifying the space, project, environment, runbook, or tenant each time.
                    You can also set defaults for GitHub options like owner, repository and workflow.
                    * @octopus-ai-app Set the default space to "{space_name}"
                    * @octopus-ai-app Set the default project to "{first_project}"
                    * @octopus-ai-app Set the default environment to "{first_environment}"
                    * @octopus-ai-app Set the default tenant to "Contoso"
                    * @octopus-ai-app Set the default runbook to "{first_runbook}"
                    * @octopus-ai-app Set the default owner to "my_organisation"
                    * @octopus-ai-app Set the default repository to "my_repository"
                    * @octopus-ai-app Set the default workflow to "build.yaml"
                    * @octopus-ai-app Remove default values
                    * @octopus-ai-app Show all the default values
                    * @octopus-ai-app Show the default space
                    * @octopus-ai-app Show the default project
                    * @octopus-ai-app Show the default environment
                    * @octopus-ai-app Show the default tenant
                    * @octopus-ai-app Show the default runbook
                    * @octopus-ai-app Show the default owner
                    * @octopus-ai-app Show the default repository
                    * @octopus-ai-app Show the default workflow

                    ## Profiles
                    Default values can be loaded and saved as profiles. This allows you to switch between sets of default values.
                    Saving a profile saves the current default values. Loading a profile replaces the current default values.
                    * @octopus-ai-app Save the profile "MyValues"
                    * @octopus-ai-app Load the profile "MyValues"
                    * @octopus-ai-app List the profiles

                    ## Terraform
                    Generate sample Terraform modules for Octopus Deploy with prompts like these:
                    * @octopus-ai-app create a sample terraform module with: three environments called "Development", "Test", and "Production"; a docker feed pointing to dockerhub; three tenants called "US", "Europe", and "Asia"; a project group called "Web App"; a project called "Audits" with a single powershell script step that echoes "Hello World"; and all tenants linked to the project and all environments

                    ## Configuration Checks
                    These prompts check your Octopus Deploy space for common issues:
                    * @octopus-ai-app Check my space for unused projects
                    * @octopus-ai-app Check my space for empty projects
                    * @octopus-ai-app Check my space for unused variables
                    * @octopus-ai-app Check my space for unused targets
                    * @octopus-ai-app Check my space for unhealthy targets
                    * @octopus-ai-app Check my space for duplicate variables

                    ## Logout
                    Logout of your session with:
                    * @octopus-ai-app logout

                    ## Documentation
                    See the [documentation](https://octopus.com/docs/administration/copilot) for more information.
                    """
            )
        )

    return CopilotResponse(
        "See the [documentation](https://octopus.com/docs/administration/copilot) for more information."
    )
