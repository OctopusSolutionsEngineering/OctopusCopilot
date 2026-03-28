from mcp.server import FastMCP

# Create an MCP server
mcp = FastMCP("AI Assistant", json_response=True)

if __name__ == "__main__":
    mcp.run(transport="stdio")