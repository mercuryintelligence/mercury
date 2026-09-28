---
title: Mercury Troubleshooting
description: Fix MCP connection, sign-in, Desktop connector, and stale-data issues.
nav_order: 6
publish: true
---

# Mercury Troubleshooting

Use this page when Mercury tools are missing, sign-in fails, the Claude Desktop connector does not connect, or data appears stale.

## MCP connection issues

Use this page when Claude cannot see Mercury tools or the server does not respond.

### Checks

1. Confirm one Mercury server points at `https://mcp.mercuryintelligence.net/mcp` (`claude mcp list` in Claude Code, `codex mcp list` in Codex, **Settings → Connectors** in Claude Desktop).
2. Restart the client after changing MCP config.
3. Confirm you are signed in: in Claude Code run `/mcp` and check the Mercury server; in Claude Desktop the connector shows as connected.
4. Run the relevant health check tool.

### Common causes

- Client was not restarted after install.
- Sign-in not completed, or the session expired.
- Project/user scope mismatch in Claude Code.
- Servers from the old four-server setup (`mercury-market-data`, `mercury-darth-feedor`, `mercury-econ-data`, `mercury-pubfinance`) are still configured. Remove them with `claude mcp remove <name>`.

### Related

[[troubleshooting|Sign-in issues]]

## Sign-in issues

Mercury uses OAuth. Your client opens the Mercury sign-in in the browser and stores the session itself; there is no API key to enter.

### Symptoms

- Tools are visible but calls fail with an authorization error.
- The client asks you to authenticate again.
- The browser sign-in completes but the client does not connect.

### Fixes

- Claude Code: run `/mcp`, select the Mercury server, and choose **Authenticate** (or **Re-authenticate**).
- Codex: run `codex mcp login mercury`.
- Claude Code: if sign-in never returns to the terminal, close other apps that might hold local ports (for example a second sign-in in progress), then retry.
- Claude Code: if you added the server by hand and sign-in keeps failing, remove it and install the Mercury plugin instead (`/plugin install mercury@mercury`).
- Claude Desktop: open **Settings → Connectors**, disconnect Mercury, and connect again.
- Confirm your Mercury account has access to Mercury data.

> **Warning:** Never paste sign-in tokens into chat, docs, screenshots, or logs.

## Claude Desktop connector troubleshooting

Claude Desktop connects to Mercury as a custom connector at `https://mcp.mercuryintelligence.net/mcp`.

### Connector does not connect

- Confirm Claude Desktop is up to date.
- Check the address is exactly `https://mcp.mercuryintelligence.net/mcp`.
- Remove the connector and add it again, then complete the browser sign-in.

### Tools do not appear

- Restart Claude Desktop.
- Confirm the connector is enabled for the chat (the tools menu in the message box).

### Best practice

Ship only `using-mercury` as the Desktop skill. It contains workflow routing for the specialized Mercury workflows.

## Stale or missing data

Mercury analysis should always be based on fresh tool calls. If data looks stale or unavailable, check freshness before interpreting the result.

### Checks

- Market data: run `health_check` and compare timestamps in tool output.
- PubFinance: run `get_data_freshness()`.
- Econ data: run `get_data_quality()`.
- Newsletters/articles: inspect `published_at`; archive search is relevance-ranked, not recency-ranked.

### Common pitfalls

- Treating earlier conversation data as live.
- Using newsletter archive hits as if they are current headlines.
- Ignoring holidays/weekends or source update schedules.

### Related

[[workflows|Newsletter and research workflow]]
