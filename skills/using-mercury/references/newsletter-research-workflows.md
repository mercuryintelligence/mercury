# Mercury Newsletter and Research Workflows

Darth Feedor is not just "latest headlines". It supports progressive retrieval over squawks, newsletters, articles, and research PDFs. Choose the retrieval mode by the user's time horizon and depth need — then ask the Feedor MCP server for the current tool contract before dispatching calls.

## Retrieval mode by intent

| User intent | Retrieval mode |
|---|---|
| "What just happened?" / breaking tape | Live squawk stream, then AI-processed rolling context if you need themes rather than raw items. |
| "What have the newsletters said this week?" | Recent-article listing → bullets on selected IDs. Never fetch full detail for many pieces in parallel. |
| "Expand from this one piece" | Related-article graph seeded on the article ID; pick 3–5 with the clearest shared mechanisms. |
| "Broad research on topic X" | Progressive multi-hop retrieval, then aggregate across the result set for consensus vs dissent. |
| "Search the archive for a concept" | Bullet-level lexical/relevance search — inspect `published_at` before presenting as current context. |
| "Panoramic street view" | Aggregate across many articles: dominant thesis, dissenting view, mechanisms, affected instruments, what to monitor next. |
| "Deep research doc / PDF" | Research documents endpoint, only when newsletter coverage is insufficient. |

## Two-phase discipline

For articles and newsletters, always stage retrieval:

1. **List first.** Show titles, IDs, and thesis lines. Cheap.
2. **Bullets on selected IDs.** Adds sentiment, mechanisms, relevance score. This is usually enough.
3. **Full detail only on demand.** One article at a time, and only when bullets are insufficient or the user asks to open the piece.

Pulling full detail for ten articles wastes context and buries the signal.

## Cross-check against Market Data

Feedor tells you what people are saying. Market Data tells you whether the market believes it. For any newsletter-driven thesis worth reporting, cross-check with `get_market_overview` or the relevant complex bundle before presenting it as actionable.

## Authoritative tool contract

For the current Feedor tool inventory, tool signatures, parameter shapes, freshness and evidence semantics, raw-squawk lexical search, and progressive retrieval sequences, invoke the `get_capability_guide` MCP tool on the Feedor MCP server. Do not rely on any tool-name or parameter list embedded in this skill — the live guide is the contract.

## Good newsletter prompts

- "Find recent newsletter coverage on Treasury refunding and connect it to ZN/ZB."
- "What are the recurring mechanisms people cite for gold strength?"
- "Trace articles related to this CPI piece and tell me what changed over time."
- "Aggregate the last two weeks of policy articles and separate consensus from outliers."
