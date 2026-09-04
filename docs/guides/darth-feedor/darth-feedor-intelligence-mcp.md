# Darth Feedor — User & MCP API Guide

**Version:** v0.3.2

Darth Feedor is Mercury’s read-only market-intelligence MCP server. It gives agents and users four complementary evidence surfaces: processed rolling market context, recent squawk evidence, article intelligence, and institutional research.

Use it progressively: start with the smallest useful view, check freshness, inspect source-facing evidence, and deepen only when the question requires it.

- **Version:** `0.3.2`
- **MCP endpoint:** `/feeder/mcp`
- **Authentication:** supply your Mercury `X-API-Key`
- **Transport:** Streamable HTTP
- **Machine schema authority:** MCP `tools/list`
- **Runtime usage guide:** `get_capability_guide()`
- **Default inspection format:** TOON where supported
- **Structured output:** `format="json"` where supported

Internal routing, deployment topology, containers, host paths, internal principal hops, and operator-only infrastructure are intentionally outside this document.

---

## 1. What Darth Feedor does

| Capability | Start here | What it gives you | Freshness clock |
|---|---|---|---|
| **What matters now?** | `get_squawk_context` | Processed rolling market orientation: overview, key data, themes, topics and theme briefs | synthesis/update time, `age_hours`, `stale` |
| **What was actually reported?** | `get_squawks` | Recent raw squawk evidence with bounded lexical filtering, exact windows and stable pagination | `received_at` |
| **What does the article flow say?** | `list_articles` | Progressive article discovery, search, selected enrichment, related-article expansion and deep reads | `published_at` |
| **What does institutional research add?** | `get_research` | Metadata-first discovery of formal research, followed by selected document detail | document date |

Two supporting tools help you operate the surface:

- `get_capability_guide()` gives an agent a compact, goal-first operating guide.
- `tool_health_check()` verifies MCP/database availability and reports the running server version.

The v0.3.2 public surface contains **14 MCP tools**. You should not need to memorize that count; the running server identifies itself through `serverInfo.version` and `tool_health_check().version`.

---

## 2. Start here

### Connect

```text
endpoint: /feeder/mcp
authentication: X-API-Key: <your Mercury API key>
```

Do not log or commit API keys.

### Verify the connection

```text
tool_health_check()
```

This checks service/database availability and reports the running server version. It does **not** prove that market intelligence is fresh.

### Ask what is happening now

```text
get_squawk_context(
  mode="latest",
  view="dashboard",
  format="toon"
)
```

Inspect the freshness markers before treating the result as current.

### Validate an important claim against raw evidence

```text
get_squawks(
  hours_back=2,
  query="Fed OR yields",
  limit=20,
  format="toon"
)
```

Squawk search is lexical. A miss should first trigger synonyms or alternate wording in the same narrow window, not a maximum-size request.

---

## 3. Mental model: progressive evidence, not bulk retrieval

> **choose a goal → use the smallest useful retrieval → check freshness → inspect evidence → deepen deliberately**

- Processed context is orientation, not raw evidence.
- Relevance is not recency. Search-ranked results may be old.
- Generated summaries, bullets and briefs are analysis of sources, not verbatim source text.
- Hard maxima are safety ceilings, not recommended request sizes.
- TOON is normally the better inspection format; use JSON for typed/programmatic processing.
- Article research is intentionally progressive: discover → enrich selected candidates → deep-read.
- Research is metadata-first: select a document before opening rich detail.
- Partial pages are explicit rather than silently presented as complete.

Darth Feedor is an intelligence/evidence surface, not a bulk-feed export through MCP.

---

## 4. Recommended workflows

### 4.1 What is happening now?

```text
get_squawk_context(mode="latest", view="dashboard", format="toon")
→ inspect age/freshness
→ open a narrower view only if needed
→ validate time-sensitive claims with get_squawks
```

### 4.2 Was a topic present in recent market flow?

```text
get_squawks(hours_back=2, query="CPI OR inflation", limit=20, format="toon")
```

If there is no match:

```text
same window + synonyms
→ widen the time window if justified
→ paginate when the matching result set is larger
```

For a known historical interval, prefer exact timestamps:

```text
get_squawks(
  received_from="2026-08-24T09:15:00-04:00",
  received_to="2026-08-24T10:30:00-04:00",
  query="yields OR CPI OR Fed",
  limit=20
)
```

### 4.3 Research an article theme

```text
list_articles(query="Treasury curve", limit=10)
→ get_article_bullets(ids=[...])
→ get_article_detail(article_id=<best-id>)
```

Expand a strong seed:

```text
article_graph(article_id=<seed-id>, limit=10)
```

Or use bounded multi-hop exploration:

```text
progressive_article_search(
  seed_query="Treasury curve",
  max_depth=2,
  max_articles=10
)
```

### 4.4 Search the article archive directly

```text
search_article_bullets(query="Powell Jackson Hole", limit=10)
```

Results rank by text relevance rather than recency. Always inspect `published_at`.

### 4.5 Build a cross-article brief

Use aggregation after you have bounded the corpus with date/source/category/tag filters:

```text
aggregate_articles(
  since_days=3,
  category="Macro",
  limit=30
)
```

This is deterministic aggregation over stored generated article analysis; it is not a new model synthesis step.

### 4.6 Add institutional research

```text
get_research(
  query="Treasury term premium",
  limit=10,
  view="metadata"
)
→ inspect publisher/date/tags
→ get_research_detail(document_id=<selected-id>)
```

---

## 5. Freshness and evidence

| Surface | Clock | Interpretation |
|---|---|---|
| Processed market context | synthesis/update timestamp, `age_hours`, `stale` | processed-intelligence freshness |
| Squawks | `received_at` | raw evidence arrival time |
| Articles | `published_at` | source publication time |
| Research | document date | source-document time |

Rules:

- stale does not mean wrong; it means older than the freshness window;
- missing freshness is unknown, not fresh;
- relevance-ranked search may return old material;
- generated summaries/briefs/bullets are derived intelligence;
- preserve article IDs/URLs, squawk IDs/timestamps/links, and research document IDs when conclusions matter;
- an empty lexical result is not proof that a topic was absent.

---

## 6. Capability map

| Goal | First call | Deepen with | Avoid first |
|---|---|---|---|
| Current market picture | `get_squawk_context(view="dashboard")` | narrower context, then raw squawks | `view="full"` |
| Recent raw evidence | `get_squawks(limit=10–25)` | synonyms, window, pagination | broad max-limit dumps |
| Article discovery | `list_articles(limit=10)` | bullets, graph, progressive search | many full details |
| Article archive search | `search_article_bullets(limit=10)` | selected bullets/detail | assuming relevance order = recency |
| Institutional research | `get_research(limit=10)` | `get_research_detail` | rich detail for the whole corpus |
| Runtime guidance | `get_capability_guide()` | selected section | loading this full human guide into an agent context |

---

## 7. Complete MCP API reference

`tools/list` is the exact executable schema authority. This section reproduces that contract in full: every tool, every public parameter with its type, default and accepted values, and the tool description exactly as clients receive it. Parameters hidden from the published schema are not listed here either.

### `tool_health_check`

```text
tool_health_check() -> dict[str, str]
```

Takes no parameters.

**Exact tool description as published to clients**

```text
Check availability of the Feedor MCP server and its database connection.

Diagnostic probe only — returns no market intelligence. Use when calls
fail or to verify server availability before a long workflow. A healthy
result is a point-in-time availability status, not a freshness signal for
any data surface. If healthy, proceed to the smallest relevant retrieval
tool or get_capability_guide for workflow guidance; if unhealthy, no
intelligence tool will succeed.
```

### `get_capability_guide`

```text
get_capability_guide(
    section: str | None = None
) -> dict[str, Any]
```

| Parameter | Type | Default | Accepted values and behaviour |
|---|---|---|---|
| `section` | `str \| None` | `None` | Optional section name to scope the response to one topic (for example "quick_start" or "fallbacks"). When None, the full guide is returned. Legacy v1 section names remain accepted as aliases. |

**Exact tool description as published to clients**

```text
Return the Feedor capability guide - an operational usage guide.

The guide teaches goal-first usage of this server: choose workflows by
goal, distinguish processed context from raw evidence, apply freshness
rules, use progressive retrieval to bound context cost, and fall back
safely when a surface is stale, empty, or unavailable.

Args:
    section: Optional section name to scope the response to one topic
             (for example "quick_start" or "fallbacks"). When None, the
             full guide is returned. Legacy v1 section names remain
             accepted as aliases.

Returns:
    The full guide, requested section, or a structured rejection for an
    unknown section. For exact callable parameter schemas use tools/list.
```

### `get_articles` — deprecated compatibility surface

```text
get_articles(
    source: str | None = None,
    has_summary: bool | None = None,
    date_from: str | None = None,
    date_to: str | None = None,
    limit: int = 20,
    fields: list[str] | None = None,
    format: str = 'toon',
    timezone: str | None = None
) -> str | list[dict[str, Any]] | dict[str, Any]
```

| Parameter | Type | Default | Accepted values and behaviour |
|---|---|---|---|
| `source` | `str \| None` | `None` | Filter by source tag. Values: 'gmail-substack', 'financial-media', 'official-documents'. If omitted, returns all sources. |
| `has_summary` | `bool \| None` | `None` | True=only articles with LLM summary, False=unsummarized only. |
| `date_from` | `str \| None` | `None` | ISO date lower bound (YYYY-MM-DD) on published_at. |
| `date_to` | `str \| None` | `None` | ISO date upper bound (YYYY-MM-DD) on published_at. |
| `limit` | `int` | `20` | Max rows to return (default 20, max 50). Higher values are rejected with a structured error naming the cap. |
| `fields` | `list[str] \| None` | `None` | Subset of fields to include. Valid: id, title, source, url, published_at, created_at, relevance_score, sender_name, is_content_blocked. 'summary' is not available on this surface. |
| `format` | `str` | `'toon'` | 'toon' (default, compact) or 'json'. |
| `timezone` | `str \| None` | `None` | IANA timezone for timestamp conversion (e.g. 'Europe/Warsaw'). Defaults to UTC if omitted or invalid. |

**Exact tool description as published to clients**

```text
DEPRECATED — legacy compatibility surface returning bounded article
METADATA for a source and date window. Retained for one compatibility
period only; use list_articles (view='compact' for discovery,
view='analytical' for a bounded thesis/bullets) for new integrations.

Retained for backward compatibility — legacy status, but not the
preferred first tool for article research. Prefer the progressive ladder:
list_articles for lightweight discovery, get_article_bullets for selected
enrichment, get_article_detail for a single deep read. Full summaries
are NOT returned: summary content is excluded from every response and
requesting it via fields is rejected with a structured error. URLs are
deterministically redacted of sensitive/tracking query parameters. The
row/byte bounds — including the total-payload ceiling — form a hard
safety ceiling; requests above them are rejected structurally.
A concrete narrow example: get_articles(source="financial-media",
date_from="2026-08-20", date_to="2026-08-22", limit=25).

Args:
    source: Filter by source tag. Values: 'gmail-substack', 'financial-media',
            'official-documents'. If omitted, returns all sources.
    has_summary: True=only articles with LLM summary, False=unsummarized only.
    date_from: ISO date lower bound (YYYY-MM-DD) on published_at.
    date_to: ISO date upper bound (YYYY-MM-DD) on published_at.
    limit: Max rows to return (default 20, max 50). Higher values are
           rejected with a structured error naming the cap.
    fields: Subset of fields to include. Valid: id, title, source, url,
            published_at, created_at, relevance_score, sender_name,
            is_content_blocked. 'summary' is not available on this surface.
    format: 'toon' (default, compact) or 'json'.
    timezone: IANA timezone for timestamp conversion (e.g. 'Europe/Warsaw').
              Defaults to UTC if omitted or invalid.
```

### `list_articles`

```text
list_articles(
    since_days: int = 2,
    date_from: str | None = None,
    date_to: str | None = None,
    category: str | None = None,
    source: str | None = None,
    limit: int = 10,
    format: str = 'toon',
    timezone: str | None = None,
    query: str | None = None,
    tags: list[str] | None = None,
    tag_match: str = 'any',
    view: str = 'compact'
) -> str | list[dict[str, Any]] | dict[str, Any]
```

| Parameter | Type | Default | Accepted values and behaviour |
|---|---|---|---|
| `since_days` | `int` | `2` | Days back from now (default 2). Ignored if date_from is set. |
| `date_from` | `str \| None` | `None` | ISO date lower bound (YYYY-MM-DD) on published_at. |
| `date_to` | `str \| None` | `None` | ISO date upper bound (YYYY-MM-DD) on published_at. |
| `category` | `str \| None` | `None` | Filter by LLM category. Values: Macro, Policy, Equities, Geopolitics, Noise. |
| `source` | `str \| None` | `None` | Filter by source tag. Values: 'gmail-substack', 'financial-media', 'official-documents'. |
| `limit` | `int` | `10` | Max rows to return (default 10; max 50 for view='compact', 20 for view='analytical'). The maxima are safety ceilings, not recommended values — start with the default and widen only if the discovery pass is not enough. |
| `format` | `str` | `'toon'` | 'toon' (default, compact) or 'json'. |
| `timezone` | `str \| None` | `None` | IANA timezone for timestamp conversion (e.g. 'Europe/Warsaw'). Defaults to UTC if omitted or invalid. |
| `query` | `str \| None` | `None` | Optional free-text search — fuzzy title match or full-text search over bullet points. Results are ranked by relevance when set. |
| `tags` | `list[str] \| None` | `None` | Optional list of tags to filter by (e.g. ["fed", "macro"]). |
| `tag_match` | `str` | `'any'` | How to match tags — 'any' (default, OR) or 'all' (AND). |
| `view` | `str` | `'compact'` | 'compact' (default, discovery) or 'analytical' (adds bounded scalar fields, bullets, tags, and omission markers). Unsupported values are rejected structurally. |

**Exact tool description as published to clients**

```text
Discover articles via lightweight stubs (phase 1 of two-phase retrieval).
This is the default, preferred first tool for article discovery.

view='compact' (default): id, title, source, url, published_at, category,
tags, has_summary — never thesis, bullets, or the full summary text. Max
50 rows.
view='analytical': title, thesis, and string bullets truncate with a visible
suffix at 1,024 JSON-serialized bytes (UTF-8). Oversized source, sanitized url,
published_at, and category values are omitted whole at 1,024 bytes;
oversized individual tags are omitted at 128 bytes. Non-string collection
members are dropped. The view keeps at most 3 bullets and 24 tags. Every
row reports content_completeness and paired marker arrays:
truncated_fields with truncated_omitted_serialized_bytes, omitted_fields
with original omitted_serialized_bytes, and count_truncated_fields with
omitted_item_counts. Omission markers are capped at 24 aligned pairs;
marker_overflow and omitted_marker_pairs report any marker loss. Max 20
rows — use get_article_bullets or
get_article_detail on selected IDs for deeper reads instead of raising
this limit.

When N >= 20 a warning is prepended suggesting aggregate_articles instead.
A concrete narrow example: list_articles(since_days=3, category="Macro", limit=5).

⚠ When query= is used, results are ordered by SIMILARITY not recency.
Old articles may surface. A staleness warning is prepended automatically
if any result is older than 7 days — do not ignore it.

Args:
    since_days: Days back from now (default 2). Ignored if date_from is set.
    date_from: ISO date lower bound (YYYY-MM-DD) on published_at.
    date_to: ISO date upper bound (YYYY-MM-DD) on published_at.
    category: Filter by LLM category. Values: Macro, Policy, Equities,
              Geopolitics, Noise.
    source: Filter by source tag. Values: 'gmail-substack',
            'financial-media', 'official-documents'.
    limit: Max rows to return (default 10; max 50 for view='compact',
           20 for view='analytical'). The maxima are safety ceilings, not
           recommended values — start with the default and widen only if
           the discovery pass is not enough.
    format: 'toon' (default, compact) or 'json'.
    timezone: IANA timezone for timestamp conversion (e.g. 'Europe/Warsaw').
              Defaults to UTC if omitted or invalid.
    query: Optional free-text search — fuzzy title match or full-text
           search over bullet points. Results are ranked by relevance
           when set.
    tags: Optional list of tags to filter by (e.g. ["fed", "macro"]).
    tag_match: How to match tags — 'any' (default, OR) or 'all' (AND).
    view: 'compact' (default, discovery) or 'analytical' (adds bounded
          scalar fields, bullets, tags, and omission markers). Unsupported
          values are rejected structurally.
```

### `search_article_bullets`

```text
search_article_bullets(
    query: str,
    limit: int = 10,
    format: str = 'toon',
    timezone: str | None = None
) -> str | list[dict[str, Any]] | dict[str, Any]
```

| Parameter | Type | Default | Accepted values and behaviour |
|---|---|---|---|
| `query` | `str` | `required` | Plain words, no special syntax needed. |
| `limit` | `int` | `10` | Max rows to return (default 10, max 20). Higher values are rejected with a structured error naming the cap. |
| `format` | `str` | `'toon'` | 'toon' (default) or 'json'. |
| `timezone` | `str \| None` | `None` | IANA timezone for timestamp conversion. |

**Exact tool description as published to clients**

```text
Full-text search inside generated article bullet-points (phase 1 alternative).

⚠ NOT FOR CURRENT CONTEXT — results are ranked by text-match relevance,
not recency. Old articles will surface if they match the query. Always
check published_at. Use list_articles (no query=) for recent-first results.

Matching is English-stemmed full-text search over LLM-generated bullets,
not verbatim source text — non-English or heavily paraphrased queries may
under-match. Use for concept research across the archive, not live market
monitoring.

Returns the declared article_stubs shape. Every row includes
content_completeness and the paired marker arrays truncated_fields with
truncated_omitted_serialized_bytes, omitted_fields with omitted_serialized_bytes,
and count_truncated_fields with omitted_item_counts. marker_overflow and
omitted_marker_pairs report marker loss; this non-field-bounding search path
emits full/empty/false/zero markers. Use get_article_bullets for cross-article fetching
by ID. A concrete narrow example: search_article_bullets(query="rate cut",
limit=10).

Args:
    query: Plain words, no special syntax needed.
    limit: Max rows to return (default 10, max 20). Higher values are
           rejected with a structured error naming the cap.
    format: 'toon' (default) or 'json'.
    timezone: IANA timezone for timestamp conversion.
```

### `get_article_bullets`

```text
get_article_bullets(
    ids: list[int],
    format: str = 'toon'
) -> str | list[dict[str, Any]] | dict[str, Any]
```

| Parameter | Type | Default | Accepted values and behaviour |
|---|---|---|---|
| `ids` | `list[int]` | `required` | List of article IDs (from list_articles results), at most 20 deduplicated IDs. Duplicates are collapsed before the bound check; an empty or over-limit list is rejected structurally. |
| `format` | `str` | `'toon'` | 'toon' (default, compact) or 'json'. |

**Exact tool description as published to clients**

```text
Get enriched phase-2 snapshots for selected article IDs.

Unlike list_articles stubs, this returns additional analytical fields
(`sentiment`, `mechanisms`, `relevance_score`) while still avoiding the
full summary blob. Use this after selecting candidate IDs from list_articles.

Args:
    ids: List of article IDs (from list_articles results), at most 20
         deduplicated IDs. Duplicates are collapsed before the bound
         check; an empty or over-limit list is rejected structurally.
    format: 'toon' (default, compact) or 'json'.
```

### `get_article_detail`

```text
get_article_detail(
    article_id: int,
    format: str = 'toon',
    timezone: str | None = None
) -> str | dict[str, Any]
```

| Parameter | Type | Default | Accepted values and behaviour |
|---|---|---|---|
| `article_id` | `int` | `required` | ID of the article to retrieve. |
| `format` | `str` | `'toon'` | 'toon' (default) or 'json'. |
| `timezone` | `str \| None` | `None` | IANA timezone for timestamp conversion (e.g. 'Europe/Warsaw'). Defaults to UTC if omitted or invalid. |

**Exact tool description as published to clients**

```text
Get the full analytical summary for one article (deep-dive, phase 3).

Returns the complete analytical summary: thesis, bullets, category,
sentiment, mechanisms, tags, relevance_score. Use only for one selected
article whose bullet points are insufficient and a full analytical read
is needed — for several candidates prefer get_article_bullets. The
summary is generated analysis, not verbatim source text, and a retrieved
article is not automatically current: check its publication date.

Outcomes: a summarized article returns the analytical record with its own
field bounds applied before the total ceiling. Title truncates with a visible
suffix at 1,024 JSON-serialized bytes. An oversized sanitized url is omitted
whole, with its original serialized byte size. The result reports
content_completeness and paired markers: truncated_fields with
truncated_omitted_serialized_bytes, omitted_fields with
omitted_serialized_bytes, and count_truncated_fields with
omitted_item_counts. marker_overflow and omitted_marker_pairs are always
false and zero because detail omission markers are structurally bounded. A
summary that remains oversized after these field bounds is rejected with
its largest remaining leaf path and serialized byte size. An allowed
article whose summary has not
been produced yet returns {status: no_summary}; an unknown or withheld
(content-blocked) article returns {status: not_found} with no further
information either way.

Args:
    article_id: ID of the article to retrieve.
    format: 'toon' (default) or 'json'.
    timezone: IANA timezone for timestamp conversion (e.g. 'Europe/Warsaw').
              Defaults to UTC if omitted or invalid.
```

### `aggregate_articles`

```text
aggregate_articles(
    since_days: int = 2,
    date_from: str | None = None,
    date_to: str | None = None,
    category: str | None = None,
    source: str | None = None,
    tags: list[str] | None = None,
    tag_match: str = 'any',
    limit: int = 50
) -> dict[str, Any]
```

| Parameter | Type | Default | Accepted values and behaviour |
|---|---|---|---|
| `since_days` | `int` | `2` | Days back from now (default 2). Ignored if date_from is set. |
| `date_from` | `str \| None` | `None` | ISO date lower bound (YYYY-MM-DD) on published_at. |
| `date_to` | `str \| None` | `None` | ISO date upper bound (YYYY-MM-DD) on published_at. |
| `category` | `str \| None` | `None` | Filter by LLM category (Macro, Policy, Equities, Geopolitics, Noise). |
| `source` | `str \| None` | `None` | Filter by source tag. |
| `tags` | `list[str] \| None` | `None` | Optional list of tags to filter by (e.g. ["fed", "fomc"]). |
| `tag_match` | `str` | `'any'` | How to match tags — 'any' (default, OR) or 'all' (AND). |
| `limit` | `int` | `50` | Max articles to aggregate (default 50, max 100; higher values are rejected). |

**Exact tool description as published to clients**

```text
Aggregate many articles into a deterministic bounded briefing.

Use when the candidate set is too large to read article by article —
returns per-article stubs (id, title, source, published_at, thesis,
top bullets, tags), cross-article tag themes, and an as-of timestamp.
Fully deterministic: no LLM synthesis in this tool, so nothing here is
newly generated analysis. Note: article fields are read from stored
LLM-generated summaries (see derives_from_generated_summaries). limit=100
is a safety ceiling, not a recommended value. A concrete narrow example:
aggregate_articles(since_days=3, category="Macro", limit=30).

Args:
    since_days: Days back from now (default 2). Ignored if date_from is set.
    date_from: ISO date lower bound (YYYY-MM-DD) on published_at.
    date_to: ISO date upper bound (YYYY-MM-DD) on published_at.
    category: Filter by LLM category (Macro, Policy, Equities, Geopolitics, Noise).
    source: Filter by source tag.
    tags: Optional list of tags to filter by (e.g. ["fed", "fomc"]).
    tag_match: How to match tags — 'any' (default, OR) or 'all' (AND).
    limit: Max articles to aggregate (default 50, max 100; higher values are rejected).
```

### `article_graph`

```text
article_graph(
    article_id: int,
    limit: int = 10,
    min_shared_tags: int = 1,
    mmr_lambda: float = 0.7,
    format: str = 'toon',
    timezone: str | None = None
) -> str | list[dict[str, Any]] | dict[str, Any]
```

| Parameter | Type | Default | Accepted values and behaviour |
|---|---|---|---|
| `article_id` | `int` | `required` | Seed article ID (from list_articles results). |
| `limit` | `int` | `10` | Max related articles to return (default 10, max 20). |
| `min_shared_tags` | `int` | `1` | Minimum tag overlap to include a result (default 1, max 20). |
| `mmr_lambda` | `float` | `0.7` | MMR balance (0-1 inclusive, default 0.7). 0=max diversity, 1=max relevance. Out-of-range values are rejected. |
| `format` | `str` | `'toon'` | 'toon' (default, compact) or 'json'. |
| `timezone` | `str \| None` | `None` | IANA timezone for timestamp conversion. |

**Exact tool description as published to clients**

```text
Find articles related to a given article by shared tags.

Use after list_articles to expand context: pick a relevant seed article
ID, then call article_graph to discover thematically connected articles
without an additional search query. Relatedness is tag-based, not
semantic similarity, so this is targeted expansion from a known good
seed rather than broad discovery — a seed without tags yields little.

Results balance relevance against diversity (MMR) to reduce
near-duplicates from the same newsletter edition. Lower mmr_lambda =
more diversity, higher = more relevance. A concrete narrow example:
article_graph(article_id=12345, limit=10, min_shared_tags=2).

Args:
    article_id: Seed article ID (from list_articles results).
    limit: Max related articles to return (default 10, max 20).
    min_shared_tags: Minimum tag overlap to include a result (default 1,
                     max 20).
    mmr_lambda: MMR balance (0-1 inclusive, default 0.7). 0=max diversity,
                1=max relevance. Out-of-range values are rejected.
    format: 'toon' (default, compact) or 'json'.
    timezone: IANA timezone for timestamp conversion.
```

### `progressive_article_search`

```text
progressive_article_search(
    seed_query: str,
    max_depth: int = 2,
    max_articles: int = 10,
    token_budget: int = 8000,
    since_days: int = 7,
    format: str = 'toon',
    timezone: str | None = None
) -> str | list[dict[str, Any]] | dict[str, Any]
```

| Parameter | Type | Default | Accepted values and behaviour |
|---|---|---|---|
| `seed_query` | `str` | `required` | Initial search query (fuzzy title match). |
| `max_depth` | `int` | `2` | Maximum expansion iterations (default 2, max 3). |
| `max_articles` | `int` | `10` | Maximum articles to return (default 10, max 25). |
| `token_budget` | `int` | `8000` | Maximum total tokens for results (default 8000, max 20000). |
| `since_days` | `int` | `7` | How many days back to search (default 7, max 90). |
| `format` | `str` | `'toon'` | 'toon' (default) or 'json'. |
| `timezone` | `str \| None` | `None` | IANA timezone for timestamps. |

**Exact tool description as published to clients**

```text
Progressive multi-hop article retrieval.

Starts with a seed query, then expands through tag-related articles
published within the same recency window as the seed. Simulates expert
research: start with obvious matches, then follow the threads. Expansion
is deliberately bounded by depth, article count, token budget, and
recency window (hard ceilings: depth 3, 25 articles, 20000 tokens, 90
days); results are ranked deterministically and deduplicated. The stop
reason and effective controls are returned as response metadata.

Use this when you need comprehensive context on a topic, not just recent
articles. Results can include older material within the window — inspect
publication dates and heed the prepended staleness warning. Deep-read the
best candidates with get_article_detail, or run the ladder manually
(list_articles -> article_graph -> get_article_bullets) for finer control.
A concrete narrow example: progressive_article_search(seed_query="oil
supply", max_depth=2, max_articles=10, since_days=7).

Args:
    seed_query: Initial search query (fuzzy title match).
    max_depth: Maximum expansion iterations (default 2, max 3).
    max_articles: Maximum articles to return (default 10, max 25).
    token_budget: Maximum total tokens for results (default 8000, max 20000).
    since_days: How many days back to search (default 7, max 90).
    format: 'toon' (default) or 'json'.
    timezone: IANA timezone for timestamps.
```

### `get_squawks`

```text
get_squawks(
    hours_back: int | None = None,
    received_from: str | None = None,
    received_to: str | None = None,
    before_received_at: str | None = None,
    before_id: int | None = None,
    limit: int = 25,
    fields: list[str] | None = None,
    format: str = 'toon',
    timezone: str | None = None,
    query: str | None = None
) -> str | dict[str, Any]
```

| Parameter | Type | Default | Accepted values and behaviour |
|---|---|---|---|
| `hours_back` | `int \| None` | `None` | Lookback window ending at now; mutually exclusive with received_from/received_to. Unqueried lookbacks above 6h are rejected; with a query up to 168h (= 7 days) is allowed. |
| `received_from` | `str \| None` | `None` | Exact inclusive window start (ISO-8601 with UTC offset, e.g. '2026-08-25T09:00:00Z'). Requires received_to. |
| `received_to` | `str \| None` | `None` | Exact inclusive window end (ISO-8601 with UTC offset). Requires received_from. |
| `before_received_at` | `str \| None` | `None` | Keyset cursor timestamp from the previous page's next_cursor. Requires before_id AND the previous page's exact applied_window as received_from/ received_to AND the previous page's query repeated via query ('' if none). |
| `before_id` | `int \| None` | `None` | Keyset cursor id from the previous page's next_cursor. Requires before_received_at AND the previous page's exact applied_window as received_from/received_to AND the previous page's query repeated via query ('' if none). |
| `limit` | `int` | `25` | Max rows per page (default 25, max 100). |
| `fields` | `list[str] \| None` | `None` | Subset of fields to include. Valid: id, content, received_at, link. |
| `format` | `str` | `'toon'` | 'toon' (default, compact) or 'json'. |
| `timezone` | `str \| None` | `None` | IANA timezone for item timestamp conversion (e.g. 'Europe/Warsaw'). Defaults to UTC if omitted or invalid; never changes the canonical cursor/window. |
| `query` | `str \| None` | `None` | Optional lexical keyword search over content (no stemming, multilingual-safe). Accepts quoted phrases, OR, and exclusion (-). Blank or whitespace-only strings are treated as no query. |

**Exact tool description as published to clients**

```text
Raw, source-facing market evidence from Telegram/Discord within a bounded
window, optionally filtered by a keyword query.

Matching is lexical, not semantic: no stemming, no fuzzy, no vector
matching. Quoted phrases, OR, and exclusion (-) are accepted; a blank
query applies no filter. An empty lexical result is NOT proof that a
topic is absent — try synonyms or a wider window.

Returns one page as an envelope: items, returned, has_more, next_cursor,
and the exact applied_window. To fetch the next page, send back
next_cursor's two fields AND repeat the applied_window exactly as
received_from/received_to AND repeat the previous page's query verbatim
via query (pass "" when the first page had none) — a cursor-only,
relative-hours_back, or query-dropping continuation is rejected with a
structured error because it re-anchors the window to now, silently drops
rows near the original lower bound, or silently changes the result set
mid-stream. Omitting all window arguments means the last 2 hours.
Unqueried spans are capped at 6h and queried spans at 168h; the 100-row
and window maxima are safety ceilings, not recommended values — start
narrow. Pages are ordered received_at DESC then id DESC, so pagination is
stable even when timestamps tie. A concrete narrow example:
get_squawks(hours_back=2, query="fomc", limit=25).

Use this tool when exact recent source-facing evidence matters (catalyst
checks, raw quotes). For orientation or the processed market picture use
get_squawk_context instead. Every row carries a received timestamp —
check recency before quoting anything.

Args:
    hours_back: Lookback window ending at now; mutually exclusive with
                received_from/received_to. Unqueried lookbacks above 6h
                are rejected; with a query up to 168h (= 7 days) is
                allowed.
    received_from: Exact inclusive window start (ISO-8601 with UTC
                   offset, e.g. '2026-08-25T09:00:00Z'). Requires
                   received_to.
    received_to: Exact inclusive window end (ISO-8601 with UTC offset).
                 Requires received_from.
    before_received_at: Keyset cursor timestamp from the previous page's
                        next_cursor. Requires before_id AND the previous
                        page's exact applied_window as received_from/
                        received_to AND the previous page's query repeated
                        via query ('' if none).
    before_id: Keyset cursor id from the previous page's next_cursor.
               Requires before_received_at AND the previous page's exact
               applied_window as received_from/received_to AND the
               previous page's query repeated via query ('' if none).
    limit: Max rows per page (default 25, max 100).
    fields: Subset of fields to include. Valid: id, content,
            received_at, link.
    format: 'toon' (default, compact) or 'json'.
    timezone: IANA timezone for item timestamp conversion (e.g.
              'Europe/Warsaw'). Defaults to UTC if omitted or invalid;
              never changes the canonical cursor/window.
    query: Optional lexical keyword search over content (no stemming,
           multilingual-safe). Accepts quoted phrases, OR, and exclusion
           (-). Blank or whitespace-only strings are treated as no query.
```

### `get_squawk_context`

```text
get_squawk_context(
    mode: str = 'latest',
    view: str = 'dashboard',
    limit: int = 5,
    session_date: str | None = None,
    date_from: str | None = None,
    fields: list[str] | None = None,
    format: str = 'toon',
    timezone: str | None = None
) -> str | list[dict[str, Any]] | dict[str, Any]
```

| Parameter | Type | Default | Accepted values and behaviour |
|---|---|---|---|
| `mode` | `str` | `'latest'` | 'latest' (default) returns the single most-recent context row. 'history' returns one row per session_date (distinct days). 'date' returns context for a specific session_date (single row). |
| `view` | `str` | `'dashboard'` | Scope of processed_data fields returned — applies to every mode. 'dashboard' (default) — overview prose + key_data items. 'overview' — full analytical brief text only (self-contained). 'key_data' — key market data points with symbol/value/dt. 'themes' — session_themes causal bullet list. 'topics' — list available topic/domain names for this context. 'topic:<name>' — events_today filtered by domain name (e.g. 'topic:Geopolitics', 'topic:Central Banks'). 'theme_briefs' — full theme_briefs map + last_synthesis + input_completeness. 'theme_briefs:<section>' — single-section brief. Sections: energies, economy_macro, rates_bonds, fx, geopolitics, equities. Unknown section returns {section, brief: None, available_sections: [...]}. 'full' — entire processed payload, single-row deep inspection only (mode='latest' or 'date'); never available for mode='history' — rejected there to keep history a bounded scoped list, not an unbounded per-row JSON dump. |
| `limit` | `int` | `5` | Max rows for mode='history' (default 5, max 31). |
| `session_date` | `str \| None` | `None` | Specific date to retrieve (mode='date' only). Format: YYYY-MM-DD. Returns the final synthesis for that day. |
| `date_from` | `str \| None` | `None` | ISO date lower bound (YYYY-MM-DD) on session_date for mode='history'. |
| `fields` | `list[str] \| None` | `None` | Subset of top-level row fields. Valid: id, session_date, last_updated, processed_data, total_squawks_processed, llm_model. Only applies to mode='history'; ignored when view is set. |
| `format` | `str` | `'toon'` | 'toon' (default) or 'json'. |
| `timezone` | `str \| None` | `None` | IANA timezone for timestamp conversion (e.g. 'Europe/Warsaw'). Defaults to UTC if omitted or invalid. |

**Exact tool description as published to clients**

```text
Processed, synthesized rolling market intelligence over recent squawks:
overview, session themes, key data, and theme briefs.

Best for orientation and the current market picture — this is NOT raw
evidence. Inspect the freshness markers (synthesis time, age, stale
flag) before calling any view current; a missing marker is not the same
as fresh. Prefer a bounded view (dashboard, key_data, themes, one theme
brief) before requesting the full payload. Validate important claims
with get_squawks; if the view is stale or uncertain, fall back to raw
squawks for the same window. A concrete narrow example:
get_squawk_context(mode="latest", view="key_data").

Args:
    mode: 'latest' (default) returns the single most-recent context row.
          'history' returns one row per session_date (distinct days).
          'date' returns context for a specific session_date (single row).
    view: Scope of processed_data fields returned — applies to every mode.
          'dashboard' (default) — overview prose + key_data items.
          'overview'  — full analytical brief text only (self-contained).
          'key_data'  — key market data points with symbol/value/dt.
          'themes'    — session_themes causal bullet list.
          'topics'    — list available topic/domain names for this context.
          'topic:<name>' — events_today filtered by domain name
                           (e.g. 'topic:Geopolitics', 'topic:Central Banks').
          'theme_briefs' — full theme_briefs map + last_synthesis +
                           input_completeness.
          'theme_briefs:<section>' — single-section brief. Sections:
                           energies, economy_macro, rates_bonds, fx,
                           geopolitics, equities. Unknown section returns
                           {section, brief: None, available_sections: [...]}.
          'full'      — entire processed payload, single-row deep
                        inspection only (mode='latest' or 'date'); never
                        available for mode='history' — rejected there to
                        keep history a bounded scoped list, not an
                        unbounded per-row JSON dump.
    limit: Max rows for mode='history' (default 5, max 31).
    session_date: Specific date to retrieve (mode='date' only).
                  Format: YYYY-MM-DD. Returns the final synthesis for that day.
    date_from: ISO date lower bound (YYYY-MM-DD) on session_date for
               mode='history'.
    fields: Subset of top-level row fields. Valid: id, session_date,
            last_updated, processed_data, total_squawks_processed, llm_model.
            Only applies to mode='history'; ignored when view is set.
    format: 'toon' (default) or 'json'.
    timezone: IANA timezone for timestamp conversion (e.g. 'Europe/Warsaw').
              Defaults to UTC if omitted or invalid.
```

### `get_research`

```text
get_research(
    view: str = 'metadata',
    publisher: str | None = None,
    tag: str | None = None,
    series: str | None = None,
    language: str | None = None,
    query: str | None = None,
    has_summary: bool | None = None,
    date_from: str | None = None,
    date_to: str | None = None,
    limit: int | None = None,
    fields: list[str] | None = None,
    format: str = 'toon',
    timezone: str | None = None
) -> str | list[dict[str, Any]] | dict[str, Any]
```

| Parameter | Type | Default | Accepted values and behaviour |
|---|---|---|---|
| `view` | `str` | `'metadata'` | 'metadata' (default) or 'analytical'. |
| `publisher` | `str \| None` | `None` | Filter by publisher name (exact match). |
| `tag` | `str \| None` | `None` | Filter by tag — matches if tag is in the document's tags array. |
| `series` | `str \| None` | `None` | Filter by series name (exact match). |
| `language` | `str \| None` | `None` | Filter by document language code (exact match). |
| `query` | `str \| None` | `None` | Lexical substring match on title (case-insensitive). Ordering stays date-deterministic even when set. |
| `has_summary` | `bool \| None` | `None` | True=only documents with LLM summary, False=unsummarized. |
| `date_from` | `str \| None` | `None` | ISO date lower bound (YYYY-MM-DD) on doc_date. |
| `date_to` | `str \| None` | `None` | ISO date upper bound (YYYY-MM-DD) on doc_date. |
| `limit` | `int \| None` | `None` | Max rows to return. Defaults/max: metadata 20/50, analytical 10/10. |
| `fields` | `list[str] \| None` | `None` | Subset of fields to include (view-specific allow-list). |
| `format` | `str` | `'toon'` | 'toon' (default, compact) or 'json'. |
| `timezone` | `str \| None` | `None` | IANA timezone for timestamp conversion (e.g. 'Europe/Warsaw'). Defaults to UTC if omitted or invalid. |

**Exact tool description as published to clients**

```text
Discover formal research documents from institutional publishers
(PDF-sourced). Bounded discovery surface — never a full deep read; use
get_research_detail for a single selected document.

view='metadata' (default, max 50) returns document metadata plus
has_summary/has_key_insights presence flags — never summary or
key_insights content. view='analytical' (max 10) additionally adds a
bounded summary preview and the leading key_insights entries. Extracted
content is DERIVED, not verbatim source text, and extraction quality
varies with source layout. Check the document date and publisher before
treating material as current. Licensing and source boundaries apply: the
PDF text itself is not exposed, so preserve document identifiers for
attribution. A concrete narrow example: get_research(publisher="Goldman
Sachs", tag="rates", limit=10).

Args:
    view: 'metadata' (default) or 'analytical'.
    publisher: Filter by publisher name (exact match).
    tag: Filter by tag — matches if tag is in the document's tags array.
    series: Filter by series name (exact match).
    language: Filter by document language code (exact match).
    query: Lexical substring match on title (case-insensitive). Ordering
           stays date-deterministic even when set.
    has_summary: True=only documents with LLM summary, False=unsummarized.
    date_from: ISO date lower bound (YYYY-MM-DD) on doc_date.
    date_to: ISO date upper bound (YYYY-MM-DD) on doc_date.
    limit: Max rows to return. Defaults/max: metadata 20/50, analytical
           10/10.
    fields: Subset of fields to include (view-specific allow-list).
    format: 'toon' (default, compact) or 'json'.
    timezone: IANA timezone for timestamp conversion (e.g. 'Europe/Warsaw').
              Defaults to UTC if omitted or invalid.
```

### `get_research_detail`

```text
get_research_detail(
    document_id: str,
    fields: list[str] | None = None,
    format: str = 'toon',
    timezone: str | None = None
) -> str | dict[str, Any]
```

| Parameter | Type | Default | Accepted values and behaviour |
|---|---|---|---|
| `document_id` | `str` | `required` | ID of the research document to retrieve. |
| `fields` | `list[str] \| None` | `None` | Subset of fields. Valid: document_id, publisher, series, title, doc_date, tags, keywords, summary, key_insights, page_count, language, storage_provider. |
| `format` | `str` | `'toon'` | 'toon' (default) or 'json'. |
| `timezone` | `str \| None` | `None` | IANA timezone for timestamp conversion (e.g. 'Europe/Warsaw'). Defaults to UTC if omitted or invalid. |

**Exact tool description as published to clients**

```text
Get the full analytical record for one research document (deep-dive).

Returns the complete document: summary and key_insights plus metadata.
Use only for one selected document identified via get_research(view=
'metadata'/'analytical') — for browsing candidates prefer the discovery
surface. The summary and key_insights are extracted/derived content, not
verbatim source text; check the document date and publisher before
treating material as current. The response is bounded to 384 KiB total
(per-field and per-key_insight caps also apply); an over-cap request
fails structurally rather than being silently truncated below the caps.

Outcomes: a known document returns the full analytical record; an
unknown document_id returns {status: not_found}.

Args:
    document_id: ID of the research document to retrieve.
    fields: Subset of fields. Valid: document_id, publisher, series,
            title, doc_date, tags, keywords, summary, key_insights,
            page_count, language, storage_provider.
    format: 'toon' (default) or 'json'.
    timezone: IANA timezone for timestamp conversion (e.g. 'Europe/Warsaw').
              Defaults to UTC if omitted or invalid.
```

## 8. Efficient retrieval

Context efficiency is a product requirement.

- Start lists/searches around **10–25 items** unless the question needs less.
- Use the narrowest relevant time window.
- Prefer TOON for inspection and JSON for typed/programmatic processing.
- Expand one dimension at a time: synonyms → scope/window → pagination.
- Open full detail only after selection.
- Stop deepening once enough evidence exists.

Avoid:

- unfiltered 24-hour squawk retrieval;
- hard maxima on exploratory first calls;
- fetching article detail for every discovery result;
- `get_squawk_context(view="full")` as an opening call;
- repeated broad searches instead of narrowing;
- JSON when TOON is enough for inspection.

### Partial results

These multi-row surfaces can shorten emitted pages under their logical-body ceiling:

- `list_articles`
- `search_article_bullets`
- `get_article_bullets`
- `article_graph`
- `progressive_article_search`
- `get_squawk_context` in history mode
- `get_research`

Partial pages carry explicit completeness/omission metadata. JSON and TOON are bounded independently and can fit different row counts when both are requested.

---

## 9. Errors, limits and recovery

Invalid scope, unsupported combinations, hard-limit violations and non-adaptive payload overflows return structured errors rather than silently changing the request.

| Class | Logical-body ceiling |
|---|---:|
| health/guidance/compact article discovery | 65,536 bytes |
| standard bounded retrieval | 131,072 bytes |
| progressive article search | 196,608 bytes |
| article aggregation | 204,800 bytes |
| single-record deep reads / processed context | 393,216 bytes |

These are **logical tool-body ceilings before MCP transport framing**. They are safety boundaries, not normal-use targets.

The MCP/FastMCP envelope is larger than the logical body, so a logical ceiling is not a literal wire-byte maximum.

TOON escapes physical row/column separators and controls. It is optimized for compact inspection, not general typed round-trip of composite cells; request JSON when typed processing matters.

---

## 10. Access and compatibility

| Property | Public contract |
|---|---|
| Transport | Streamable HTTP |
| Endpoint | `/feeder/mcp` |
| Authentication | Mercury `X-API-Key` |
| Rate limit | 10 requests/second per client, burst 50 |
| Runtime version | `serverInfo.version` and `tool_health_check().version` |
| Default inspection format | TOON where supported |
| Structured format | JSON where supported |

The final release reports the bare version string `0.3.2`. `get_articles` remains deprecated for one compatibility period; it is not the preferred article workflow.

The documentation layers have separate jobs:

1. `tools/list` — exact callable schema and descriptions.
2. `get_capability_guide()` — compact runtime skill for an agent.
3. This guide — human-facing workflows, complete reference, limitations and release notes.

---

## 11. What changed in v0.3.2

This section is intentionally late. A first-time user should understand Darth Feedor as it exists now before reading release history.

- targeted squawk retrieval with smaller defaults, exact windows and stable pagination;
- compact/analytical article discovery and progressive deepening;
- `get_research_detail` for selected institutional research;
- truthful partial pages for bounded multi-row surfaces;
- request-path-aware recovery guidance;
- TOON row/column framing hardening;
- machine-checked parity between public descriptions, capability guidance and live schemas;
- runtime version discriminator;
- explicit field/page completeness markers.

---

## 12. Payload & release acceptance

This appendix records release-engineering evidence rather than leading the user journey.

The v0.3.2 release branch is based on accepted source:

```text
188d0d6a2e6fe576f65369ea355976eaa9d802d0
```

Release qualification records both:

```text
logical JSON/TOON bytes
+
production-path Streamable HTTP / MCP envelope bytes
```

and binds measurements to exact source and dependency versions.

Representative qualification covers normal and pressure cases for squawks, context, compact/analytical articles, bullets/graph/progressive search, aggregation, research discovery and single-record deep reads.

Measurements must:

- invoke production behavior rather than hand-built response approximations;
- use legal persisted/database shapes;
- freeze freshness clocks where output depends on time;
- bind exact Git SHA and dependency versions;
- exercise production middleware/Streamable HTTP framing for wire size;
- include lookahead/pagination metadata in maximum-page cases;
- fail on a served over-ceiling body independently of rejection flags;
- fail if an expected measurement case disappears or becomes stale;
- avoid retaining licensed/private source bodies.

Source/documentation preparation does not prove deployment:

```text
accepted source
→ v0.3.2 tag / GitHub release
→ exact image/provenance
→ authorized deployment
→ public MCP smoke
→ deployed payload/freshness/telemetry verification
→ canonical current-guide promotion
```

---

## 13. Known limitations

- Squawk search is lexical rather than semantic.
- Search-ranked article results are not necessarily recent-first.
- Generated analysis is derived intelligence, not verbatim source text.
- TOON is compact inspection format, not typed composite serialization.
- Some pathological single-record deep reads can still reject after field bounding.
- Exact continuation is not claimed where the public parameter surface cannot preserve relevance/tie ordering safely; narrow the request instead.
- Service health is not equivalent to intelligence freshness.

---

## 14. Quick reference

```text
CURRENT MARKET
get_squawk_context(view="dashboard")
→ get_squawks(query=..., limit=10–25) when evidence is needed

ARTICLE RESEARCH
list_articles(query=..., limit=10)
→ get_article_bullets(ids=[...])
→ get_article_detail(article_id=...)
→ article_graph / progressive_article_search when expansion is useful

INSTITUTIONAL RESEARCH
get_research(query=..., limit=10, view="metadata")
→ get_research_detail(document_id=...)

OPERATING POLICY
get_capability_guide()

AVAILABILITY / VERSION
tool_health_check()
```

> **Start narrow. Check freshness. Preserve evidence. Deepen deliberately.**
