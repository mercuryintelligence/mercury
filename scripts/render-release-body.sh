#!/usr/bin/env bash
set -euo pipefail
# Render the GitHub Release body from a platform corpus note
# (release-notes/plugins/<id>.md: YAML frontmatter + prose).
# The note is the only authored text; this script adds the fixed
# "How to get it" and "Links" blocks and drops all frontmatter (incl. `source`).
#   render-release-body.sh <note.md>           body to stdout
#   render-release-body.sh --title <note.md>   frontmatter title to stdout
mode=body
if [ "${1:-}" = "--title" ]; then mode=title; shift; fi
note="${1:-}"
[ -f "$note" ] || { echo "usage: $0 [--title] <corpus-note.md>" >&2; exit 2; }
[ "$(head -n1 "$note")" = "---" ] || { echo "$note: missing frontmatter" >&2; exit 1; }

if [ "$mode" = title ]; then
  title=$(awk 'NR>1 && /^---$/{exit} NR>1 && /^title:/{sub(/^title:[ \t]*/,""); gsub(/^"|"$/,""); print; exit}' "$note")
  [ -n "$title" ] || { echo "$note: no title in frontmatter" >&2; exit 1; }
  printf '%s\n' "$title"
  exit 0
fi

# Prose = everything after the closing frontmatter fence; note-relative docs routes become public URLs.
prose=$(awk 'c>=2{print} /^---$/ && c<2{c++}' "$note" | sed 's#](/docs/#](https://docs.mercuryintelligence.net/docs/#g')
[ -n "${prose//[[:space:]]/}" ] || { echo "$note: empty note body" >&2; exit 1; }

cat <<BODY
## What's new
${prose}

## How to get it

Claude Code: \`claude plugin marketplace update mercury\` then \`claude plugin update mercury@mercury\`.
Codex: \`codex plugin marketplace upgrade mercury\`.
Desktop: re-upload the skill if it changed.

## Links

- Docs: [Quickstart](https://github.com/mercuryintelligence/mercury/blob/main/docs/quickstart.md)
- [Tool reference](https://github.com/mercuryintelligence/mercury/blob/main/docs/tool-reference.md)
- Website: https://mercuryintelligence.net
BODY
