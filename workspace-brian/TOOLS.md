# TOOLS.md - Brian MCP Notes

## Current Runtime Notes

- Blossom School Catering support flows now use schoolcatering server-side `family_id` scope.
- Brian stays public-facing only and should delegate BSC execution to Orders (`bsc`).
- Branch standard is `main`.

## Available MCP Servers

- `filesystem`
  Access to the BSC and Brian workspaces plus inbound media folders.
- `fetch`
  Fast retrieval of public source pages.
- `playwright`
  Headless browser automation for browser-based checks and verification.

## Practical Defaults

- Use MCP tools for quick support work only.
- Delegate substantive BSC execution to Orders (`bsc`).
- Prefer `filesystem`, then `fetch`, then `playwright`.
