#!/bin/bash

# Helper script to invoke an MCP server via npx
# Usage: ./scripts/mcp-invoke.sh <package-name> [args...]

if [ -z "$1" ]; then
  echo "Usage: $0 <package-name> [args...]"
  exit 1
fi

PACKAGE_NAME=$1
shift

echo "Invoking MCP server: $PACKAGE_NAME with args: $@"
npx "$PACKAGE_NAME" "$@"
