#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
body=$(bash scripts/render-release-body.sh scripts/fixtures/plugin-note.md)
title=$(bash scripts/render-release-body.sh --title scripts/fixtures/plugin-note.md)
has() { grep -qF -- "$1" <<<"$body" || { echo "FAIL: body lacks: $1" >&2; exit 1; }; }
lacks() { ! grep -qE -- "$1" <<<"$body" || { echo "FAIL: body contains: $1" >&2; exit 1; }; }
has 'claude plugin marketplace update mercury'
has 'claude plugin update mercury@mercury'
has '/plugin marketplace add mercuryintelligence/mercury'
has '/plugin install mercury@mercury'
has 'codex plugin marketplace add mercuryintelligence/mercury'
has 'codex plugin add mercury@mercury'
has 'codex mcp login mercury'
has '**Claude Desktop and claude.ai**: add a custom connector with the Mercury address; the skill for these clients is coming.'
lacks 'upload the skill'
has 'older four separate Mercury servers'
has 'https://docs.mercuryintelligence.net/docs/platform-plugins'
has 'https://docs.mercuryintelligence.net/docs/platform-clients'
has 'https://docs.mercuryintelligence.net/docs/platform-skills'
lacks 'github.com/mercuryintelligence'
has 'https://docs.mercuryintelligence.net/docs/'
has 'https://mercuryintelligence.net'
lacks '^---$'
lacks '^(source|product|kind|highlight|summary|date|version|bundle|range|repo|tag):'
lacks '\]\(/docs/'
[ -n "$title" ] || { echo "FAIL: empty title" >&2; exit 1; }

# (*) markers and the footnote pass through the note body unchanged.
fbody=$(bash scripts/render-release-body.sh scripts/fixtures/plugin-note-footnote.md)
for want in 'Desktop skill support (*) arrives later.' '(*) This feature is coming and is not available yet.'; do
  grep -qF -- "$want" <<<"$fbody" || { echo "FAIL: footnote body lacks: $want" >&2; exit 1; }
done
echo "render-release-body: ok"
