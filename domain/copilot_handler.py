import os

from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_openai import AzureChatOpenAI


def handle_copilot_chat(query):
    prompt = ChatPromptTemplate.from_template(query)
    output_parser = StrOutputParser()
    model = AzureChatOpenAI(temperature=0,
                            azure_deployment="OctopusCopilotFunctionCalling",
                            openai_api_key=os.environ["OPENAI_API_KEY"],
                            azure_endpoint=os.environ["OPENAI_ENDPOINT"],
                            api_version="2023-05-15")

    chain = prompt | model | output_parser
    output = chain.invoke({})
    print(output)
