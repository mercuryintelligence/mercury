# Releasing

Release contract for `mercuryintelligence/mercury` (the Mercury plugin for Claude Code and Codex). Canon lives in
the platform repo (operations release-lifecycle doc). Procedure: `.agents/skills/releasing-plugin-notes/SKILL.md`.

## Release mode

RELEASE_MODE: operator-cut

A person tags and publishes a GitHub Release by hand with `gh release create`; no workflow builds or publishes
anything on tag. The release body is rendered from the merged platform corpus note by `scripts/render-release-body.sh`.

## Tag policy

Tags are `vX.Y.Z`, SemVer, versioned independently of every other Mercury repo (never mirrored). The tag points at
the merged commit on `main`. The plugin `version` in `plugins/mercury/.claude-plugin/plugin.json` and
`plugins/mercury/plugin.json` must match and equal the tag. No frozen lines.

## Artifacts

The plugin is distributed from the repo itself through the plugin marketplace. The only built artifact is
`skills/using-mercury.skill`, rebuilt by `scripts/build-skill.sh`; CI checks it matches its source.

## Docs bundle

None. This repo produces no docs bundle; the reader note is authored in platform as a corpus note.

## Deploy boundary

Merging or publishing here deploys nothing. The platform docs deploy publishes the reader note, and the platform
Discord bot posts it after that deploy (canon step 9). Publishing the GitHub Release posts nothing to Discord; the
disabled `discord-release-announce.yml` workflow was removed (PLT-731). Draft-first stays: create the release as a
draft and publish only on the operator's explicit go.

## Deviation

If hosted CI is billing-blocked, verify locally (`scripts/render-release-body.test.sh`, `scripts/build-skill.sh`),
admin-merge after the operator's go, and cut the release by hand as above.

## Public note

Yes. The reader note is authored and merged in the platform repo as a plugins corpus note before the release is
cut here. The GitHub Release body is a rendering of it, never a second draft.

## Yank

Delete the GitHub Release and the tag (`gh release delete vX.Y.Z --cleanup-tag`), then ship a corrected patch
version; the platform note is withdrawn or corrected through a platform correction note.
