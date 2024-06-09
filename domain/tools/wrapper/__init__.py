"""
We have to accommodate several concerns when building functions used by Open AI function calling.

First is the way functions are serialized and presented to Open AI. The function signature needs to express the
entities that may be provided by the prompt. For example, the prompt:

Run the runbook "My Runbook" in project "My Project" in space "My Space"

exposes the entities "My Runbook", "My Project", and "My Space". The function signature should include these entities:

def run_runbook(space, project, runbook):
    pass

However, to respond to this function call, we need much more information. At a minimum we need details like the Octopus
server URL, API key. We may also have logging functions that need to be customized depending on whether the function
is called as part of a test or not. And there may be platform specific details, such as the GitHub user name.

In order to present Open AI with a function signature that includes only the entities, while also capturing additional
arguments that must be known by the system, we use a wrapper function. The wrapper function signature defines all the
arguments that the system should know, regardless of what external interface is calling the service. This means the
wrapper takes arguments for:

* Octopus URL
* Octopus API key
* logging functions

The wrapper also takes a callback function.

The wrapper returns a nested function with a docstring that can be passed to Open AI. The nested function then
passes all the platform arguments and prompt arguments to the callback.

The nested function may also perform some common logic, such as building LLM prompts specific to the kind of query
being responded to.

def run_runbook_wrapper(octopus_url, octopus_api_key, logging, callback):
    def run_runbook(space, project, runbook):
        "" "
            This function executes a runbook.

            Args
            space: The name of the space
            project: The name of the project
            runbook: The name of the runbook
        "" "
        return callback(octopus_url, octopus_api_key, logging, space, project, runbook)

    return run_runbook

This structure means that we can build a common set of tools that have platform specific responses.

For example, when this tool is called from GitHub copilot, the callback function can take advantage of the fact that
the caller has a GitHub account which can be used to interact with GitHub APIs or used as authentication. But when the
tool is called from the CLI, the user is not identified, and so there the response may be more generic. These tools may
be called from other platforms in the future, and so the callback may need to be customized to support Slack or Teams.

"""
