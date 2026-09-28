---
title: Mercury Quickstart
description: Install Mercury and start a session with /using-mercury.
nav_order: 2
publish: true
---

# Quickstart

Use this page to understand Mercury, install it, and start the first session. Skills are invoked as slash commands; the canonical entry point is `/using-mercury`.

## What is Mercury?

Mercury is a market-intelligence layer for Claude. It connects live MCP servers so Claude can pull market, macro, liquidity, and news/research data while answering a user’s question.

Most market assistants fail in one of two ways: they either answer from stale prior knowledge, or they dump raw tool output without forming a view. Mercury is designed around a different pattern: fetch the right layer of live data, interpret it in market structure terms, and decide what additional layer is worth pulling.

### The four data domains

All four are served by one MCP server, `mercury`, at `https://mcp.mercuryintelligence.net/mcp`.

| Domain | What it covers |
|---|---|
| Market Data | Cross-asset futures snapshots, bundles, AMT, volatility, market texture, curve/STIR spreads, candles, futures options, correlations, and sandboxed cross-domain Python analysis. |
| Econ Data | Calendar events with actual/forecast/previous values, BLS/BEA history, economic-history catalog, and data-quality diagnostics. |
| Darth Feedor | Live squawks, rolling topic context, newsletter/media articles, article bullets, full article detail, article graph, progressive search, archive search, aggregation, and research docs. |
| PubFinance | Liquidity Composite Index, fiscal daily/weekly flows, Fed balance sheet/liquidity, reference rates, repo/RRP, Treasury operations, dealers, fails, TIC, debt, and freshness. |

### How Mercury analysis should feel

A strong Mercury answer is not a list of tool calls. It reads like a desk note:

1. **Headline** — what matters right now.
2. **Evidence** — the fresh tool outputs that support the claim.
3. **Structure** — whether price/auction/vol confirms or contradicts the headline.
4. **Liquidity and macro context** — whether the background impulse supports the move.
5. **Narrative** — whether live tape or newsletter research explains the catalyst.
6. **Next layer** — the one additional check that would improve confidence.

### Skill invocation

Skills are invoked as slash commands. Start a session with:

```text
/using-mercury
```

Then ask your market question, or include the intent in the same command:

```text
/using-mercury morning brief
/using-mercury deep dive ZN
/using-mercury what are newsletters saying about Treasury refunding?
```

### What Mercury is not

- It is not a substitute for your own trading judgment.
- It is not guaranteed to have every data source updated at the same cadence.
- It should not treat newsletter archive results as current news without checking dates.
- It should not expose or print credentials or sign-in tokens.

### Next

Continue below with the Claude Desktop or Claude Code install flow, then run the first-session examples.

## Install on Claude Desktop

Claude Desktop connects to Mercury as a custom connector. You add the address once, sign in with
your Mercury account, and Claude keeps the session. There is no API key.

### Before you begin

- Install the latest Claude Desktop.
- Have your Mercury account sign-in ready.

### Steps

1. Open **Settings → Connectors** and choose **Add custom connector**.
2. Name it **Mercury** and paste `https://mcp.mercuryintelligence.net/mcp`.
3. Click **Connect**. Your browser opens the Mercury sign-in; approve access.
4. Back in Claude Desktop, the Mercury connector shows as connected.

### Skills

Upload `using-mercury.skill` under **Settings → Capabilities → Skills**, then invoke it as:

```text
/using-mercury
```

Specialized workflow skills can remain useful for Claude Code users, but Desktop documentation should teach the single `/using-mercury` entry point.

### Verify

Start a new Claude Desktop chat and ask:

```text
/using-mercury what Mercury workflows are available?
```

A healthy setup should describe market data, econ data, news/research, and PubFinance capabilities.

### Related

- [[quickstart#Run your first session|Run your first session]]
- [[troubleshooting|Sign-in issues]]

## Install on Claude Code

Install the Mercury plugin. It adds the Mercury server and the Using Mercury skill in one step;
Claude Code then signs you in and keeps the session.

### Install

```text
/plugin marketplace add mercuryintelligence/mercury
/plugin install mercury@mercury
```

Then run `/mcp`, select the Mercury server, and choose **Authenticate** to sign in.

### Verify

```bash
claude mcp list
```

You should see the Mercury server at `https://mcp.mercuryintelligence.net/mcp` as connected. If it
shows as needing authentication, repeat the `/mcp` sign-in.

### Skills

The plugin installs the canonical skill as:

```text
/mercury:using-mercury
```

Specialized `mercury-*` skills are workflow shortcuts for Claude Code. They should not replace the public Desktop guidance; `/using-mercury` remains the universal entry point.

### Related

- [[quickstart#Run your first session|Run your first session]]
- [[troubleshooting|MCP connection issues]]
- [[troubleshooting|Sign-in issues]]


## Install on Codex

```bash
codex plugin marketplace add mercuryintelligence/mercury
codex plugin add mercury@mercury
codex mcp login mercury
```

Start a new Codex session so the Mercury server and the Using Mercury skill load.

## Skills and workflow shortcuts

For public/Desktop documentation, teach a single entry point:

```text
/using-mercury
```

`/using-mercury` routes the main workflows: Morning Brief, Market Scan, Instrument Deep Dive, Rates & STIR, PubFinance/Liquidity Plumbing, Live News, Newsletter Research, and cross-domain `run_analysis`.

Claude Code users may also keep specialized `mercury-*` shortcuts. They are useful for trigger routing and as source material for workflow pages, but they are not required for Desktop users:

| Shortcut | When it applies |
|---|---|
| `mercury-morning-brief` | Full morning setup across calendar, regime, markets, liquidity, and news. |
| `mercury-market-scan` | Broad live market scan and regime context. |
| `mercury-deep-dive` | Single instrument price/AMT/vol/news analysis. |
| `mercury-yield-curve` | Treasury curve, STIR, Fed pricing, and fixed-income futures. |
| `mercury-news-flow` | Squawks, newsletters, article graph, archive search, and research synthesis. |
| `mercury-econ-watch` | Economic calendar, release monitoring, and event reaction analysis. |
| `mercury-vol-regime` | Volatility regime and auction-market structure. |
| `mercury-risk-map` | Correlations, cross-asset relationships, and risk concentration. |
| `mercury-fx` | FX futures and dollar/currency analysis. |
| `mercury-commodities` | Energy, metals, and commodity complex analysis. |

## Run your first session

Start a Mercury session by invoking the skill as a slash command. The slash command matters: write `/using-mercury`, not a natural-language request to load the skill.

### Before you begin

- Mercury MCP servers are installed and visible in your Claude client.
- You have signed in to Mercury from your client.
- The `using-mercury` skill is installed.

### Start prompt

```text
/using-mercury
```

Claude should orient to the Mercury workflow router and ask what you want to do next.

You can also invoke the skill and task together:

```text
/using-mercury give me a morning brief
/using-mercury deep dive ZN
/using-mercury what are newsletters saying about Treasury refunding?
```

### Recommended first workflows

| Goal | Prompt |
|---|---|
| Daily setup | `/using-mercury morning brief` |
| Fast market read | `/using-mercury what is moving across equities, rates, FX, and commodities?` |
| Single instrument | `/using-mercury deep dive ZN` |
| Rates/Fed | `/using-mercury what is the curve and STIR market pricing?` |
| Liquidity | `/using-mercury what is liquidity doing today?` |
| Newsletters | `/using-mercury what are newsletters saying about Treasury refunding?` |

### What good output looks like

Good Mercury output is layered and selective. It should usually include:

- A one-paragraph desk summary.
- A short “evidence” section with fresh tool outputs.
- A “what changed” or “why it matters” section.
- A caveat if the result depends on stale, missing, or archive-ranked data.
- A suggested next layer only when it would materially improve the read.

It should not dump every returned field or open every article in full detail.

### If the first response is too generic

Ask it to pull the specific layer:

```text
Pull live market data first, then add liquidity context.
```

or:

```text
Use Darth Feedor article stubs first, then enrich only the top three IDs.
```

### Related

- [[workflows|Morning brief]]
- [[workflows|Instrument deep dive]]
- [[workflows|Newsletter and research workflow]]
