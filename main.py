from datetime import datetime
from langchain_experimental.llms.ollama_functions import OllamaFunctions


model = OllamaFunctions(model="phi")

model = model.bind(
    functions=[
        {
            "name": "get_current_weather",
            "description": "Get the current weather in a given location",
            "parameters": {
                "type": "object",
                "properties": {
                    "location": {
                        "type": "string",
                        "description": "The city and state, " "e.g. San Francisco, CA",
                    },
                    "unit": {
                        "type": "string",
                        "enum": ["celsius", "fahrenheit"],
                    },
                },
                "required": ["location"],
            },
        },
{
            "name": "find_user",
            "description": "Rerturn the details of a user",
            "parameters": {
                "type": "object",
                "properties": {
                    "name": {
                        "type": "string",
                        "description": "The city and state, " "e.g. San Francisco, CA",
                    },
                    "city": {
                        "type": "string",
                        "description": "The location of the user"
                    },
                },
                "required": ["name"],
            },
        }
    ],
    #function_call={"name": "get_current_weather"},
)

try:
    start = datetime.now()
    output = model.invoke("what is the weather in Boston?")
    end = datetime.now()

    print(output)
    print(output.additional_kwargs['function_call']['name'])
    print(output.additional_kwargs['function_call']['arguments'])
    print(str(end - start))
except Exception as e:
    print(e)
