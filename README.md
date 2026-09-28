# Mercury

Connects your AI client to the [Mercury Platform](https://mercuryintelligence.net). Mercury is one MCP
server at `https://mcp.mercuryintelligence.net/mcp`. It serves market data, Darth Feedor news and
research, the economic calendar and public finance, and you sign in to it with your Mercury account
over OAuth. There is no API key to copy or store: your client runs the sign-in and keeps the session
itself.

Any MCP client that supports OAuth can connect to that address. This repository is also a plugin
marketplace: the `mercury` plugin bundles the Mercury server with the Using Mercury skill, so one
install sets up both.

---

## Claude Code

In Claude Code, add the marketplace and install the plugin:

```text
/plugin marketplace add mercuryintelligence/mercury
/plugin install mercury@mercury
```

Then run `/mcp`, select the Mercury server and choose **Authenticate**. Your browser opens the
Mercury sign-in, and Claude Code keeps the session from then on. The Using Mercury skill is available
as `/mercury:using-mercury`.

From a terminal, the same install is `claude plugin marketplace add mercuryintelligence/mercury`
followed by `claude plugin install mercury@mercury`. To update, run
`claude plugin marketplace update mercury` and `claude plugin update mercury@mercury`; to remove it,
run `claude plugin uninstall mercury@mercury`.

If you used the old four-server setup, remove those entries once the plugin is installed:
`claude mcp remove mercury-market-data`, and the same for `mercury-darth-feedor`,
`mercury-econ-data` and `mercury-pubfinance`.

---

## Codex

Add the marketplace and install the plugin from a terminal:

```bash
codex plugin marketplace add mercuryintelligence/mercury
codex plugin add mercury@mercury
```

You can also run `/plugins` inside Codex and install **mercury** from the Mercury marketplace. Sign
in with `codex mcp login mercury`, then start a new Codex session so the server and the Using
Mercury skill load.

---

## Claude Desktop and claude.ai

1. Open **Settings → Connectors** and choose **Add custom connector**.
2. Name it **Mercury** and paste `https://mcp.mercuryintelligence.net/mcp`.
3. Click **Connect** and sign in with your Mercury account.
4. Add the skill: download [using-mercury.skill](https://docs.mercuryintelligence.net/api/docs/downloads/using-mercury.skill) and upload it under
   **Settings → Capabilities → Skills**.

Claude handles the sign-in and stores the session.

---

## Other MCP clients

Add `https://mcp.mercuryintelligence.net/mcp` as a remote (streamable HTTP) server and sign in when
the client asks.

---

## Using Mercury skill

### `using-mercury` — Session Onboarding + Workflow Hub *(load at session start)*

Maps the Mercury tools, explains when to use each, and includes an internal workflow router for Morning Brief, Market Scan, Instrument Deep Dive, Rates/STIR, PubFinance, News/Newsletter Research, and cross-domain `run_analysis` work. The plugins install it for Claude Code and Codex; Claude Desktop and claude.ai use the packaged [using-mercury.skill](https://docs.mercuryintelligence.net/api/docs/downloads/using-mercury.skill), built from `skills/using-mercury.skill` here.

It also includes reference files:

- `references/advanced-workflows.md`
- `references/newsletter-research-workflows.md`
- `references/tool-selection-cheatsheet.md`

**Tools:** all Mercury tools · **Trigger:** session start, "what can you do", "what tools do you have"

---

## Repository layout

```
.claude-plugin/marketplace.json     # Claude Code marketplace
.agents/plugins/marketplace.json    # Codex marketplace
plugins/mercury/
├── .claude-plugin/plugin.json      # Claude Code plugin manifest
├── .mcp.json                       # Claude Code: the Mercury server
├── plugin.json                     # Codex (Agent Plugins) manifest
├── mcp.json                        # Codex: the Mercury server
└── skills/using-mercury/           # Using Mercury skill, shared by both plugins
skills/using-mercury.skill          # Packaged skill for Claude Desktop and claude.ai
scripts/build-skill.sh              # Rebuilds the packaged skill from plugins/mercury/skills/
```
