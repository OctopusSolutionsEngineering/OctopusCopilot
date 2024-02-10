from datetime import datetime
from langchain_experimental.llms.ollama_functions import OllamaFunctions

model = OllamaFunctions(model="llama2")

model = model.bind(
    functions=[
        {
            "name": "find_user",
            "description": "Return the details of a person",
            "parameters": {
                "type": "object",
                "properties": {
                    "name": {
                        "type": "string",
                        "description": "The name of the person, " "e.g. John or Jessica"
                    },
                    "city": {
                        "type": "string",
                        "description": "The location of the person, " "e.g. San Francisco, CA",
                    },
                },
                "required": ["name"],
            },
        },
{
            "name": "get_deployments",
            "description": "Return the details of a deployment",
            "parameters": {
                "type": "object",
                "properties": {
                    "release_version": {
                        "type": "string",
                        "description": "The release version associated with the deployment, " "e.g. 1.2.3 or 0.0.1"
                    },
                    "environment": {
                        "type": "string",
                        "description": "The name of the environment the release was deployed to, " "e.g. Development, Test, Production",
                    },
                },
                "required": ["release_version", "environment"],
            },
        },
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

    ],
    # function_call={"name": "get_current_weather"},
)

try:
    start = datetime.now()
    output = model.invoke("return the details of release 1.4.5 to the production environment")
    end = datetime.now()

    print(output)
    print(output.additional_kwargs['function_call']['name'])
    print(output.additional_kwargs['function_call']['arguments'])
    print(str(end - start))
except Exception as e:
    print("error: " + str(e))
