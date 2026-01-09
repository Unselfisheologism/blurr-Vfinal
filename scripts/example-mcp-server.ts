import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";

/**
 * Example MCP server implementation
 */
const server = new Server(
  {
    name: "example-mcp-server",
    version: "1.0.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

/**
 * List available tools
 */
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: "hello_world",
        description: "A simple hello world tool",
        inputSchema: {
          type: "object",
          properties: {
            name: {
              type: "string",
              description: "The name to say hello to",
            },
          },
          required: ["name"],
        },
      },
    ],
  };
});

/**
 * Handle tool calls
 */
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  if (request.params.name === "hello_world") {
    const name = request.params.arguments?.name;
    return {
      content: [
        {
          type: "text",
          text: `Hello, ${name}! This is from the integrated MCP server.`,
        },
      ],
    };
  }
  throw new Error("Tool not found");
});

/**
 * Main function to start the server
 */
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error("Example MCP Server running on stdio");
}

main().catch((error) => {
  console.error("Fatal error in main():", error);
  process.exit(1);
});
