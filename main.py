from datetime import datetime
from langchain_experimental.llms.ollama_functions import OllamaFunctions


#model = OllamaFunctions(model="phi") #19.7s
#model = OllamaFunctions(model="mistral") #6.4s
#model = OllamaFunctions(model="llama2") #8.1s
model = OllamaFunctions(model="orca2") #6.5s
#model = OllamaFunctions(model="orca-mini") #fails

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

start = datetime.now()
output = model.invoke("what is the weather in Boston?")
end = datetime.now()

print(output)
print(end - start)