from langchain.callbacks.manager import CallbackManager
from langchain.callbacks.streaming_stdout import StreamingStdOutCallbackHandler
from langchain_community.llms import LlamaCpp

from llm_functions import LlmFunctions


def multiply(a: int, b: int) -> int:
    """Multiply two integers together.

    Args:
        a: First integer
        b: Second integer
    """
    return a * b


callback_manager = CallbackManager([StreamingStdOutCallbackHandler()])
llm = LlamaCpp(
    model_path="/home/matthew/Downloads/mixtral-8x7b-instruct-v0.1.Q4_K_M.gguf",
    temperature=0,
    max_tokens=100,
    top_p=1,
    callback_manager=callback_manager,
    verbose=True,  # Verbose is required to pass to the callback manager
    grammar_path="json.gbnf"  # https://github.com/ggerganov/llama.cpp/blob/master/grammars/json.gbnf
)

model = LlmFunctions(llm=llm)
model = model.bind(functions=[
        {
            "name": "multiply",
            "description": "Multiply two integers together",
            "parameters": {
                "type": "object",
                "properties": {
                    "a": {
                        "type": "int",
                        "description": "First integer",
                    },
                    "b": {
                        "type": "int",
                        "description": "Second integer",
                    },
                },
                "required": ["a", "b"],
            },
        }
    ])

model.invoke("what's 5 times three")
