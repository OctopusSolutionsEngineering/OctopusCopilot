import os

from langchain.agents import OpenAIFunctionsAgent

from domain.langchain.azure_chat_open_ai_with_tooling import AzureChatOpenAIWithTooling
from domain.logging.app_logging import configure_logging
from domain.tools.build_tools import build_tools
from domain.tools.function_call import FunctionCall

my_log = configure_logging()


def handle_copilot_chat(query, llm_tools=build_tools):
    functions = llm_tools()
    tools = functions.get_tools()

    # Version comes from https://github.com/openai/openai-python/issues/926#issuecomment-1839426482
    # Note that for function calling you need 3.5-turbo-16k
    # https://github.com/openai/openai-python/issues/926#issuecomment-1920037903
    agent = OpenAIFunctionsAgent.from_llm_and_tools(
        llm=AzureChatOpenAIWithTooling(temperature=0,
                                       azure_deployment="OctopusCopilotFunctionCalling2",
                                       openai_api_key=os.environ["OPENAI_API_KEY"],
                                       azure_endpoint=os.environ["OPENAI_ENDPOINT"],
                                       api_version="2023-12-01-preview"),
        tools=tools,
    )

    action = agent.plan([], input=query)
    my_log.debug(action)

    return FunctionCall(functions.get_function(action.tool), action.tool_input)
