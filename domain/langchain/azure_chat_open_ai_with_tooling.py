from langchain.chat_models import AzureChatOpenAI


class AzureChatOpenAIWithTooling(AzureChatOpenAI):
    """AzureChatOpenAI with a patch to support functions.

    Function calling: https://learn.microsoft.com/en-us/azure/ai-services/openai/how-to/function-calling

    Currently only a single function call is supported.
    If multiple function calls are returned by the model, only the first one is used.

    Copied from https://github.com/langchain-ai/langchain/issues/14941
    """

    def _generate(self, messages, stop=None, run_manager=None, stream=None, **kwargs):
        if "functions" in kwargs:
            kwargs["tools"] = [
                {"type": "function", "function": f} for f in kwargs.pop("functions")
            ]
        return super()._generate(messages, stop, run_manager, stream, **kwargs)

    def _create_message_dicts(self, messages, stop):
        dicts, params = super()._create_message_dicts(messages, stop)
        latest_call_id = {}
        for d in dicts:
            if "function_call" in d:
                # Record the ID for future use
                latest_call_id[d["function_call"]["name"]] = d["function_call"]["id"]
                # Convert back to tool call
                d["tool_calls"] = [
                    {
                        "id": d["function_call"]["id"],
                        "function": {
                            k: v for k, v in d["function_call"].items() if k != "id"
                        },
                        "type": "function",
                    }
                ]
                d.pop("function_call")

            if d["role"] == "function":
                # Renaming as tool
                d["role"] = "tool"
                d["tool_call_id"] = latest_call_id[d["name"]]

        return dicts, params

    def _create_chat_result(self, response):
        result = super()._create_chat_result(response)
        for generation in result.generations:
            if generation.message.additional_kwargs.get("tool_calls"):
                function_calls = [
                    {**t["function"], "id": t["id"]}
                    for t in generation.message.additional_kwargs.pop("tool_calls")
                ]
                # Only consider the first one.
                generation.message.additional_kwargs["function_call"] = function_calls[
                    0
                ]
        return result
