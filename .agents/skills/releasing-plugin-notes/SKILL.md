---
name: releasing-plugin-notes
description: >
  Cut a release of the Mercury plugin in this repo (mercuryintelligence/mercury): render the
  GitHub Release body from the merged platform corpus note
  (release-notes/plugins/<id>.md) and announce it on Discord. Not the generic npm
  releasing skill. TRIGGER when the user says to release, cut a
  release, publish a version, announce an update, or points at an upstream
  Mercury change set (for example a darth-feedor release) and asks to turn it
  into a Mercury Platform release. The skill fixes how the body is rendered,
  the no-closed-source disclosure rules, and the independent versioning rule.
  It does NOT decide what to release — the user points at the source material.
---

# Releasing the Mercury plugin from a corpus note (mercuryintelligence/mercury)

This repo publishes the user-facing Mercury Platform: the `mercury`
plugin for Claude Code and Codex, the packaged Using Mercury skill, and the public docs in
`docs/`. Releases cut here are what users and beta testers see.

## What the agent is and is not responsible for

- **The user points at the source material** — typically a release or change
  set from an upstream Mercury repository (for example darth-feedor), or a
  list of changes they want surfaced. Read it, understand what changed from a
  *user's* perspective, and nothing more.
- **The corpus note is the only authored text.** The user-facing note lives in
  the platform repo as `release-notes/plugins/<id>.md` (frontmatter + prose),
  is drafted and approved there, and must be merged before a release is cut
  here. The GitHub Release body is a rendering of it, never a second draft.
  If the note is missing or needs a change, fix it in platform and re-render;
  do not edit the rendered body.
- **The agent cuts the release** for this repo: version, changelog, tag, and
  the GitHub Release from the rendered body.
- **The agent never invents scope.** If the source material is thin or the
  user intent is ambiguous, ask. Do not pad a release with changes you cannot
  source to the pointed material.
- **The agent never exposes closed-source material.** Everything in the
  release body must be information a user of the product is entitled to see.

## The release lifecycle

1. **Confirm the version** (independent versioning — see below).
2. **Update `CHANGELOG.md`**: move the relevant entries out of `[Unreleased]`
   into a dated `## [x.y.z] - YYYY-MM-DD` section. Keep the keep-a-changelog
   shape already used in this file.
3. **Bump the plugin `version`** to match in both
   `plugins/mercury/.claude-plugin/plugin.json` and `plugins/mercury/plugin.json`
   (CI requires them equal). Installed plugins stay on their version until it
   changes. If the skill changed, rebuild `skills/using-mercury.skill` with
   `scripts/build-skill.sh` (CI checks it matches the source).
4. **Open and merge** the version/changelog change on a branch, or fold it
   into the release PR, per repo convention. The release tag must point at the
   merged commit.
5. **Render the body from the merged corpus note and dry-run it**:
   `scripts/render-release-body.sh <note.md> > RELEASE_BODY.md`
   (`--title` prints the note title). The script drops all frontmatter,
   including the `source` provenance block, and appends the "How to get it"
   and public links blocks. Show the operator the rendered body and get
   approval before publishing.
6. **Create the Git tag and GitHub Release** on `main`:
   `gh release create vX.Y.Z --title "$(scripts/render-release-body.sh --title <note.md>)" --notes-file RELEASE_BODY.md`
7. **Confirm the announcement** reached Discord. Publishing the GitHub Release
   fires `.github/workflows/discord-release-announce.yml`, which posts the
   body to the Discord webhook (`DISCORD_RELEASE_WEBHOOK_URL` secret). Check
   the workflow run succeeded, or re-run it if the webhook was down.

## Independent versioning — never mirror

Each Mercury repository versions independently. This repo does NOT mirror
the version of darth-feedor or any other upstream repo. A release here
that surfaces upstream work carries **this repo's own next version**.

- Current published version: read `plugins/mercury/.claude-plugin/plugin.json`.
- Patch bump (default): bug fixes, doc updates, plugin fixes.
- Minor bump: new user-visible capability or a notable platform step.
- Major bump: breaking install/usage change.

Name the upstream source release inside the body as *context* (for example
"pairs with the Darth Feedor v0.3.2 update"), never as the version of this
release.

## The release body is a rendering

The body is the note prose, then a fixed `## How to get it` block (Claude Code
install and update commands, Codex install and `codex mcp login mercury`,
Claude Desktop/claude.ai custom connector (the skill for these clients is coming), and removal of the older
four separate servers), then `## Links` to the public docs site
(platform-plugins, platform-clients, platform-skills) and
https://mercuryintelligence.net. Both fixed blocks live in
`scripts/render-release-body.sh`; change them there, with the check in
`scripts/render-release-body.test.sh`. Note-relative `/docs/...` routes are
rewritten to public docs URLs.

Disclosure rules apply to the note (the platform validator enforces them at
merge) and to anything you add here; keep them at least as strict:

- **No code.** No file paths, function names, internal module or service
  names, repo-internal identifiers, class names, or architecture.
- **No private infrastructure.** Never name or link the private upstream
  repositories (for example the darth-feedor private repo), internal docs,
  or anything under an org-internal URL.
- **No internal process.** No mention of CI, deployments, release machinery,
  migration steps, or engineering ceremony.
- **No roadmap promises.** Describe what is in THIS release, not what is
  planned.
- **User-visible behavior only.** If a user cannot observe or benefit from a
  change, it does not belong in the body. If it is observable, describe the
  observable behavior, not the mechanism.
- **Public links only.** Links point to https://docs.mercuryintelligence.net
  or https://mercuryintelligence.net. Verify every URL you
  emit is reachable by the public.
- **Accurate scope.** Only what the user pointed at and what is actually in
  the release. If a doc page describes a capability that did not change, do
  not imply it changed in this release.

When in doubt about whether a detail is safe to publish, leave it out. The
cost of a too-sparse body is low; the cost of leaking closed-source detail is
not.

## Discord announcement

The webhook workflow posts the release title and body automatically. The
announcement therefore inherits the rendered body: keep the note
self-contained and useful on Discord (markdown renders in the embed). If the
body is long, the workflow truncates it at the Discord embed limit; put the
most important content in the first few lines.
