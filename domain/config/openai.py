# This is the number of items you can place in the context of a question before the LLM starts to
# generate incorrect responses.
# Lists of simple resources usually started to fail around the 40 item mark.
# Lists of complex resources, like deployments with release notes, started to fail around the 30 item mark.
# Complex lists worked around the 20 mark, but timed out when requested through the Copilot interface.
max_context = 10

# "Adversarial" queries can tie up a LLM for a long time. The Copilot interface times out after 60 seconds.
# Our timeout is set to 45 seconds to allow for some additional processing time.
# Another issue here is the Azure event driven scaling.
# As noted at https://learn.microsoft.com/en-us/azure/azure-functions/event-driven-scaling?tabs=azure-cli#understanding-scaling-behaviors,
# Azure functions add at most 1 function instance every 30 seconds.
llm_timeout = 45
