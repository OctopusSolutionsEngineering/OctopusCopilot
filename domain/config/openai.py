# This is the number of items you can place in the context of a question before the LLM starts to
# generate incorrect responses.
# Lists of simple resources usually started to fail around the 40 item mark.
# Lists of complex resources, like deployments with release notes, started to fail around the 30 item mark.
max_context = 20

# Deployments contain a lot of information, and retrieving it all can be slow. We limit the deployment history to 10
# to reduce the likelihood of a timeout.
max_deployments = 10

# "Adversarial" queries can tie up a LLM for a long time. The Copilot interface times out after 60 seconds.
# Our timeout is set to 45 seconds to allow for some additional processing time.
# Another issue here is the Azure event driven scaling.
# As noted at https://learn.microsoft.com/en-us/azure/azure-functions/event-driven-scaling?tabs=azure-cli#understanding-scaling-behaviors
# HTTP triggers will scale out once per second. We may be in a position of having HTTP requests queued behind a
# long-running query.
llm_timeout = 60

# Testing revealed that the GPT 3.5 LLM struggles to extract meaningful values from large blobs of log outputs. For example,
# this query fails:
# find any CVEs in the deployment logs for the latest deployment of the project "Octopus Copilot Function" to the "Production" environment in the "Octopus Copilot" space in the last 400 lines
# But this query succeeds:
# find any CVEs in the deployment logs for the latest deployment of the project "Octopus Copilot Function" to the "Production" environment in the "Octopus Copilot" space in the last 300 lines
# A max_log_lines limit of 250 is appropriate for GPT 3.5.
# The GPT-4o was better though. We set a much higher limit before displaying a warning.
max_log_lines = 1000

# This is the small model used for generating responses to queries
mini_model = "gpt-4o-mini"

# This is the full model used for generating responses to queries
full_model = "gpt-4o"
