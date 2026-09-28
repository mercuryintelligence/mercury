---
name: releasing
description: >
  Cut a user-facing release of the Mercury Platform in this repo (mercuryintelligence/mercury)
  and announce it on Discord. TRIGGER when the user says to release, cut a
  release, publish a version, announce an update, or points at an upstream
  Mercury change set (for example a darth-feedor release) and asks to turn it
  into a Mercury Platform release. The skill fixes the shape of the release body,
  the no-closed-source disclosure rules, and the independent versioning rule.
  It does NOT decide what to release — the user points at the source material.
---

# Releasing the Mercury Platform (mercuryintelligence/mercury)

This repo publishes the user-facing Mercury Platform: the `mercury`
plugin for Claude Code and Codex, the packaged Using Mercury skill, and the public docs in
`docs/`. Releases cut here are what users and beta testers see.

## What the agent is and is not responsible for

- **The user points at the source material** — typically a release or change
  set from an upstream Mercury repository (for example darth-feedor), or a
  list of changes they want surfaced. Read it, understand what changed from a
  *user's* perspective, and nothing more.
- **The agent writes the user-facing release** for this repo: version,
  title, body, and the GitHub Release.
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
5. **Create the Git tag and GitHub Release** on `main`:
   `gh release create vX.Y.Z --title "..." --notes-file RELEASE_BODY.md`
6. **Confirm the announcement** reached Discord. Publishing the GitHub Release
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

## The user-facing shape of the release body

Write for a person who uses Mercury through Claude. Short, concrete,
outcome-first. The shape below is the contract.

```markdown
## What's new

Lead with the one or two things that matter most to a user, in plain
language, tied to what they can now do. If the release is small, one short
paragraph or a tight bullet list is enough.

- **New capability** — what a user can now ask Mercury to do.
- **Improvement** — what works better than before.
- **Fix** — what no longer misbehaves.

## How to get it

One line on how existing users update (Claude Code: `claude plugin marketplace
update mercury` then `claude plugin update mercury@mercury`; Codex:
`codex plugin marketplace upgrade mercury`; Desktop: re-upload the skill if it
changed).

## Links

- Docs: [Quickstart](https://github.com/mercuryintelligence/mercury/blob/main/docs/quickstart.md) — and link the docs page that documents a changed
  capability, where one exists.
- [Tool reference](https://github.com/mercuryintelligence/mercury/blob/main/docs/tool-reference.md) if tool behavior changed.
- Website: https://mercuryintelligence.net
```

Rules that always apply:

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
- **Public links only.** Docs links point to this repo's public `docs/`, the
  public README, or https://mercuryintelligence.net. Verify every URL you
  emit is reachable by the public.
- **Accurate scope.** Only what the user pointed at and what is actually in
  the release. If a doc page describes a capability that did not change, do
  not imply it changed in this release.

When in doubt about whether a detail is safe to publish, leave it out. The
cost of a too-sparse body is low; the cost of leaking closed-source detail is
not.

## Discord announcement

The webhook workflow posts the release title and body automatically. The
announcement therefore inherits the body you wrote: keep the body
self-contained and useful on Discord (markdown renders in the embed). If the
body is long, the workflow truncates it at the Discord embed limit; put the
most important content in the first few lines.
