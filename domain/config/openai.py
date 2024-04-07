# This is the number of items you can place in the context of a question before the LLM starts to
# generate incorrect responses.
# Lists of simple resources usually started to fail around the 40 item mark.
# Lists of complex resources, like deployments with release notes, started to fail around the 30 item mark.
# Complex lists worked around the 20 mark, but timed out when requested through the Copilot interface.
max_context = 10

# "Adversarial" queries can tie up a LLM for a long time. The Copilot interface times out after 60 seconds.
# Our timeout is set to 45 seconds to allow for some additional processing time.
llm_timeout = 45
