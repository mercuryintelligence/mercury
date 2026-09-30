#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
body=$(bash scripts/render-release-body.sh scripts/fixtures/plugin-note.md)
title=$(bash scripts/render-release-body.sh --title scripts/fixtures/plugin-note.md)
has() { grep -qF -- "$1" <<<"$body" || { echo "FAIL: body lacks: $1" >&2; exit 1; }; }
lacks() { ! grep -qE -- "$1" <<<"$body" || { echo "FAIL: body contains: $1" >&2; exit 1; }; }
has 'claude plugin marketplace update mercury'
has 'claude plugin update mercury@mercury'
has 'codex plugin marketplace upgrade mercury'
has 'https://docs.mercuryintelligence.net/docs/'
has 'https://mercuryintelligence.net'
lacks '^---$'
lacks '^(source|product|kind|highlight|summary|date|version|bundle|range|repo|tag):'
lacks '\]\(/docs/'
[ -n "$title" ] || { echo "FAIL: empty title" >&2; exit 1; }
echo "render-release-body: ok"
