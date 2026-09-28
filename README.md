# Mercury MCP Installer

Connects an MCP client to the [Mercury Platform](https://mercuryintelligence.net). Mercury is one MCP
server at `https://mcp.mercuryintelligence.net/mcp`. It serves market data, Darth Feedor news and
research, the economic calendar and public finance, and you sign in to it with your Mercury account
over OAuth. There is no API key to copy or store: your client runs the sign-in and keeps the session
itself.

Any MCP client that supports OAuth can connect to that address. The installer and the steps below
are shortcuts for Claude Code and Claude Desktop.

---

## Claude Code

```bash
npx @mercuryintelligence/mercury
```

**Requires:** [Node.js ≥ 18](https://nodejs.org) and the [Claude Code CLI](https://code.claude.com)

The installer asks for a scope: **user** for every Claude Code session, or **project** for this
directory's `.mcp.json`. It then adds one server named `mercury`. If you still have servers from the
old four-server setup (`mercury-market-data`, `mercury-darth-feedor`, `mercury-econ-data`,
`mercury-pubfinance`), it offers to remove them. Run it with `--dry-run` to print the command
without changing anything.

To finish, start `claude`, run `/mcp`, select **mercury** and choose **Authenticate**. Your browser
opens the Mercury sign-in, and Claude Code keeps the session from then on.

Any other way of adding the address also works. Add `https://mcp.mercuryintelligence.net/mcp` as an
HTTP server and sign in when the client asks.

---

## Claude Desktop

1. Open **Settings → Connectors** and choose **Add custom connector**.
2. Name it **Mercury** and paste `https://mcp.mercuryintelligence.net/mcp`.
3. Click **Connect** and sign in with your Mercury account.

Claude handles the sign-in and stores the session. Running `npx @mercuryintelligence/mercury` and
choosing Claude Desktop prints the same steps.

---

## What gets installed

| Server | Address | Sign-in |
|--------|---------|---------|
| `mercury` | `https://mcp.mercuryintelligence.net/mcp` | OAuth with your Mercury account |

`servers.json` holds this entry. Both the installer and CI read it.

---

## Pinning a version

```bash
npx @mercuryintelligence/mercury@1.0.0
```

The package's executable is `mercury-connect`, never `mercury`, so a global install never shadows an
existing `mercury` command.

---

## Agent Skills

### `using-mercury` — Session Onboarding + Workflow Hub *(load at session start)*

Maps the Mercury tools, explains when to use each, and includes an internal workflow router for Morning Brief, Market Scan, Instrument Deep Dive, Rates/STIR, PubFinance, News/Newsletter Research, and cross-domain `run_analysis` work. This is the canonical skill to ship in minimal environments such as Claude Desktop.

The packaged `using-mercury.skill` also includes reference files:

- `references/advanced-workflows.md`
- `references/newsletter-research-workflows.md`
- `references/tool-selection-cheatsheet.md`

**Tools:** all Mercury tools · **Trigger:** session start, "what can you do", "what tools do you have"

---

### Installing the skill

The packaged skill is `skills/using-mercury.skill`, and its source is `skills/using-mercury/`.

- **Claude Code:** copy the source into your skills directory: `cp -r skills/using-mercury ~/.claude/skills/`
- **Claude Desktop and claude.ai:** upload `using-mercury.skill` under **Settings → Capabilities → Skills**.
