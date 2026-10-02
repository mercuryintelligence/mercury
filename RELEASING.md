# Releasing

Release contract for `mercuryintelligence/mercury` (the Mercury plugin for Claude Code and Codex). Canon lives in
the platform repo (operations release-lifecycle doc). Procedure: `.agents/skills/releasing-plugin-notes/SKILL.md`.

## Release mode

RELEASE_MODE: operator-cut

A person tags and publishes a GitHub Release by hand with `gh release create` (skill step 6); no workflow in
`.github/workflows/` builds or publishes on tag. The body is rendered from the merged platform corpus note by
`scripts/render-release-body.sh`.

## Tag policy

Tags are `vX.Y.Z`, versioned independently of other Mercury repos (skill, "Independent versioning"). Evidenced in
`.github/workflows/ci.yml`: the Claude and Codex plugin versions must be equal (line 90). Anything further
(tag-to-version equality, which commit is tagged, frozen lines) is not enforced by CI and is not stated here.

## Artifacts

Evidenced in `.github/workflows/ci.yml`: the packaged skill `skills/using-mercury.skill` must match a rebuild by
`scripts/build-skill.sh` (lines 108-112), and the plugin must include the `using-mercury` skill (line 105). No other
built artifact is evidenced.

## Docs bundle

None. This repo produces no docs bundle; the reader note is authored in platform as a corpus note.

## Deploy boundary

Merging or publishing here deploys nothing and posts nothing to Discord. The platform docs deploy publishes the
reader note. The Discord post is a deliberate platform `workflow_dispatch` run by the release coordinator after that
deploy (canon step 9): dry run first, live run only after the operator's go, and products in `exclude_products` are
skipped. It is not automatic. The former `discord-release-announce.yml` workflow was removed (PLT-731), so no
workflow here announces on publish and a draft release is not required.

## Deviation

If hosted CI is billing-blocked, verify locally (`scripts/render-release-body.test.sh`, `scripts/build-skill.sh`),
admin-merge after the operator's go, and cut the release by hand as above.

## Public note

Yes. The reader note is authored and merged in the platform repo as a plugins corpus note before the release is
cut here. The GitHub Release body is a rendering of it, never a second draft.

## Yank

Not defined for this repo yet; decide with the operator when a release must be withdrawn.
