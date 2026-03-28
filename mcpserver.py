from mcp.server import FastMCP

# Create an MCP server
mcp = FastMCP("AI Assistant", json_response=True)

my_tool_function = lambda x: f"Hello, {x}!"

mcp.add_tool(my_tool_function)

if __name__ == "__main__":
    mcp.run(transport="stdio")