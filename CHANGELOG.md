# Changelog

All notable changes to this project are documented here.

## [Unreleased]

### Added

- **Migrate mercury-econ-data to streamable HTTP transport** ([cadb39a](https://github.com/mercuryintelligence/terminalbeta/commit/cadb39a3de41fd440f55a2aaa164d9af909c4f8c)) — 2026-03-06 00:15

  Update URL /econ/sse → /econ/mcp and transport sse → http,
  matching the econ_mcp_server migration.


- **Migrate feeder MCP to streamable HTTP transport** ([8ec7ba8](https://github.com/mercuryintelligence/terminalbeta/commit/8ec7ba85e3daf7e757651d24b83bf28be528ffd8)) — 2026-03-06 01:11

  - URL: /feeder/sse → /feeder/mcp
  - transport: sse → http


- **Update MCP servers to streamable-http transport** ([646cb80](https://github.com/mercuryintelligence/terminalbeta/commit/646cb8084a9bf7cd7ec1da5ea54db1e1c2a202ce)) — 2026-03-06 01:32

  Switch all three server URLs from /sse to /mcp and transport from
  sse to streamable-http (MCP 2025-03-26 spec).


- **Add Mercury agent skills to repo** ([b3a7d77](https://github.com/mercuryintelligence/terminalbeta/commit/b3a7d771f349897152724e9a113e908328f04aa0)) — 2026-03-09 17:00

  Move all 11 skills into skills/ directory so beta testers can
  clone the repo and copy them directly to ~/.claude/skills/.

  Update README with clone + copy install instructions.


- **Add mercury-pubfinance MCP server (#1)** ([6135e19](https://github.com/mercuryintelligence/terminalbeta/commit/6135e198399cb0879ede64536359fd33182643fb)) — 2026-03-16 16:46

  Adds pubfinance to the installer registry:
  - Fed reference rates: SOFR, EFFR, OBFR, BGCR, TGCR
  - Repo / RRP operations, Treasury auctions
  - TGA balance, primary dealers, fiscal flows


- **Add mercury-pubfinance MCP server** ([7e783d5](https://github.com/mercuryintelligence/terminalbeta/commit/7e783d547861f7b0dc2a1b779e07ef914b98012f)) — 2026-03-16 16:29

  Adds pubfinance to the installer registry:
  - Fed reference rates: SOFR, EFFR, OBFR, BGCR, TGCR
  - Repo / RRP operations, Treasury auctions
  - TGA balance, primary dealers, fiscal flows


- **Add Claude Desktop Extension (.mcpb) for Windows users** ([25e8a19](https://github.com/mercuryintelligence/terminalbeta/commit/25e8a19d10676e64b6450504c8001ae8f32182e1)) — 2026-04-07 07:08

  - Build mercury-platform.mcpb: single extension aggregating all 4 Mercury
    HTTP endpoints via a bundled Node.js proxy (no mcp-remote, no npx cache)
  - Update index.js: on Windows, offer Desktop Extension vs Claude Code path;
    extension path copies .mcpb to Desktop and opens the install dialog
  - Update README: non-developer Windows path (download + double-click) at top;
    Claude Code path below; architecture section updated
  - Update package.json: include ext/ in files, update description


- **Add filing-bugs skill (#31)** ([8644717](https://github.com/mercuryintelligence/terminalbeta/commit/86447173ec5db363cfd8e263607611b46b33d208)) — 2026-05-05 17:32

  * chore: exclude dev-tool dot dirs from git

  Add .beads, .claude, .gitnexus, .mcp.json, .pi, .serena, .specialists,
  and .xtrm to .gitignore and untrack all 569 files. This repo is
  user-facing — these are local dev tooling artifacts, not project content.

  Also fix stale absolute paths in .claude/settings.json hooks
  (/home/dawid/projects/mercury/terminalbeta → /mnt/c/dev/terminalbeta).


- **Bootstrap Mercury security pipeline (#38)** ([fecf96a](https://github.com/mercuryintelligence/terminalbeta/commit/fecf96a7d7c34828481ba1211c035c0ac9905efd)) — 2026-05-09 07:26

  * specialists: wire scoping-service-skills into explorer (user-layer override)

  * feat(security): bootstrap Mercury security pipeline

  Mirrors mercury-infra security baseline. See SECURITY-PIPELINE.md in
  mercury-infra for the full reference.


### Fixed

- **Correct transport flag from streamable-http to http** ([432e82b](https://github.com/mercuryintelligence/terminalbeta/commit/432e82b17d8a40d8e788d7621c7e77f6d6c78ebc)) — 2026-03-09 16:57

  Claude CLI only accepts 'http' as the transport value for the
  Streamable HTTP protocol. 'streamable-http' is not a valid flag.


- **Move skills to .claude/skills/ so Claude Code picks them up** ([4c27b54](https://github.com/mercuryintelligence/terminalbeta/commit/4c27b5498122f6bc8d490ed780bd92a278a0d98b)) — 2026-03-09 17:13


- **Add trailing newline to servers.json** ([2cd1b41](https://github.com/mercuryintelligence/terminalbeta/commit/2cd1b412dfd11b3d8fae6adf7e8b5674c518773f)) — 2026-03-16 16:35


- **Use canonical .xtrm paths (sync from market-data)** ([d00eadc](https://github.com/mercuryintelligence/terminalbeta/commit/d00eadcfa487a071021035d9a77a4b886b49f8cb)) — 2026-04-23 11:22


- **Use portable .claude/skills/ path alias; scope.py searches user packs first** ([49690f9](https://github.com/mercuryintelligence/terminalbeta/commit/49690f9197130c5f0998d79963b38123df8c141f)) — 2026-04-23 12:00

  - Replace .xtrm/skills/active/claude/ with .claude/skills/ in executor, explorer, service-skills-sync
  - scope.py find_registry() now searches .xtrm/skills/user/packs/*/service-registry.json before legacy fallback
  - .claude/skills/ is the portable symlink alias that works on both old and new xt layouts


- **Drop --skip-git from osv-scanner; pull-request-only semgrep (#40)** ([da13922](https://github.com/mercuryintelligence/terminalbeta/commit/da1392285ba307b22f9c7bfcbf8ebc3a725eb87f)) — 2026-05-09 08:40

  osv-scanner-action v2.3+ removed the --skip-git flag → workflow exits 127
  after Dependabot bumped the action version. Recursive scan respects
  .gitignore by default; --skip-git is unnecessary.

  semgrep workflow no longer triggers on push to main. semgrep ci has no
  baseline ref on push events and re-flags pre-existing debt every commit.
  PR-event keeps diff-aware behavior. Weekly schedule covers full scan.


- **Consolidated Codex audit fixes (P1 + P2) (#43)** ([b0e8bfa](https://github.com/mercuryintelligence/terminalbeta/commit/b0e8bfa2b688afcb097a144e3cc2198bd201723d)) — 2026-05-09 09:07

  Address findings from Codex inline reviews on the security pipeline rollout:

  P1 (gate-blocking bugs):
  - .pre-commit-config.yaml: osv-scanner pre-push entry was 'cmd && X || echo'
    which converted any non-zero exit (including real findings) into success.
    Push gate was silently bypassed. Now uses if/else to distinguish 'not
    installed' from 'scan failed'.
  - .gitleaks.toml: '.env\..*' regex was a blanket allowlist hiding real
    secrets in tracked files like .env.production. Narrowed to local-only
    patterns: .env, .env.local, .env.*.local, .env.example.
  - scripts/security-bootstrap.sh: copy_file resolved sources from $SOURCE root,
    but skill ships templates under templates/. Now tries templates/ first,
    falls back to root. Also: pre-push merge logic — if .githooks/pre-push
    exists, append baseline with idempotency marker; otherwise install.
    Reads pre-push.template (skill name) as fallback to .githooks/pre-push.

  P2 (regressions / coverage gaps):
  - .github/workflows/osv-scanner.yml: restored push:[main,master] trigger.
    Previous removal created a coverage gap — vulns from merges/admin pushes
    deferred to weekly cron. OSV scan is fast and has no 'pre-existing debt'
    issue (unlike semgrep), so push trigger is appropriate.
  - .githooks/pre-push: protected-branch guard checked HEAD instead of
    remote_ref, so 'git push origin HEAD:main' bypassed it. Now keys off
    destination ref directly.
  - scripts/semgrep-diff.sh: hard-coded origin/main as baseline. Now derives
    from current branch's tracked upstream, falling back to common defaults,
    finally walking back HEAD~50 if no remote tracking exists. Multi-commit
    pushes no longer skip earlier commits.

  All fixes propagated to mercury-infra, .xtrm/skills/default/security-pipeline/
  templates, and 10 sibling Mercury repos (and xtrm-tools as skill source).


- **Wrapper-pattern pre-push merge + semgrep-diff baseline guard (#44)** ([2574deb](https://github.com/mercuryintelligence/terminalbeta/commit/2574debb2bf5dbdc88ca8062cf29ebd7c613b781)) — 2026-05-09 09:28

  Codex audit on PR #32 wave found two P1/P2 regressions in the previous fix:


- **Codex audit follow-ups (preserve pre-push.local, baseline correctness) (#45)** ([616142b](https://github.com/mercuryintelligence/terminalbeta/commit/616142b3f809e64dcb4cf70db54023d2737c1a02)) — 2026-05-09 09:34


- **Phase 5 codex follow-ups (e9e/q81/b52) (#87)** ([4ac3e60](https://github.com/mercuryintelligence/terminalbeta/commit/4ac3e604f1a258438e87747c51f3e19ce8225d7f)) — 2026-05-10 06:33

  infra-e9e (P3): semgrep-diff would silently scan an empty diff when BASE_REF
  fell back to a local branch name equal to the current HEAD branch (e.g.
  running on 'main' without upstream → BASE_REF=main → merge-base=HEAD).
  Fix: skip a local-branch candidate that equals current branch name.

  infra-q81 (P3): .semgrepignore blanket-excluded .xtrm/, hiding the
  security-pipeline skill source from SAST. Replaced with per-skill
  exclusions; .xtrm/skills/default/security-pipeline/ is now scanned.

  infra-b52 (P4): bootstrap script tracked pip and pip-pyproject as two
  distinct ecosystems but both generated identical dependabot blocks for /,
  producing invalid duplicate entries. Now: single 'pip' entry covers any
  combination of requirements*.txt and pyproject.toml.


- **Semgrepignore wildcard + explicit unignore for security-pipeline (#88)** ([d2cd46e](https://github.com/mercuryintelligence/terminalbeta/commit/d2cd46eef2771b06d2790c05f03bfd6fcd1245ab)) — 2026-05-10 06:37

  Codex P2 finding on PR #10: hardcoded list of default skills to exclude
  was incomplete (missed hook-development, planning, prompt-improving,
  service-skills-set, specialists-creator, xt-* etc.) and brittle — new
  skills would silently become scan targets. Replace with blanket
  '.xtrm/skills/default/' + explicit unignore for security-pipeline/**.


- **Semgrepignore — use glob '*' so re-include actually works (#89)** ([141356d](https://github.com/mercuryintelligence/terminalbeta/commit/141356dfdd114dd85ebeb1332cf3da7b02c8b381)) — 2026-05-10 06:42

  Codex P1 finding: gitignore semantics refuse to descend into an excluded
  parent directory, so '.xtrm/skills/default/' + '!.../security-pipeline/'
  results in security-pipeline being silently excluded. Replace with a glob
  on immediate children: '.xtrm/skills/default/*' + the negation. This is
  the canonical gitignore pattern for 'exclude all but one'.


### Other changes

- **Update name** ([03dcd83](https://github.com/mercuryintelligence/terminalbeta/commit/03dcd83465fc5b3f03ec78c1f81ada1ed7132a50)) — 2026-03-09 16:53


- **Merge pull request #2 from Jaggerxtrm/feature/add-pubfinance-mcp

feat: add mercury-pubfinance MCP server** ([4f3f612](https://github.com/mercuryintelligence/terminalbeta/commit/4f3f6122fd733bac3c6c0ac58e8566a662536c3d)) — 2026-03-17 13:35


- **Bd init: initialize beads issue tracking** ([69772a1](https://github.com/mercuryintelligence/terminalbeta/commit/69772a185ffb96e4a704f2b89acdad3e436fa207)) — 2026-03-17 14:23


- **Merge feature/migrate-beads-issues into main

- Migrated 28 beads issues from terminalbeta to their respective service repos
- Updated README.md with mercury-pubfinance server entry
- Fixed "three MCPs" → "four MCPs" references in skills
- Updated serena project config with line_ending setting

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>** ([a9ef103](https://github.com/mercuryintelligence/terminalbeta/commit/a9ef1031f30f252289a7513b6067c1619faf211b)) — 2026-03-17 22:05


- **Added bug file** ([661401f](https://github.com/mercuryintelligence/terminalbeta/commit/661401fb7abcb9afa35d7e1154446712c174f58d)) — 2026-03-27 13:12


- **Filing bugs** ([0101275](https://github.com/mercuryintelligence/terminalbeta/commit/0101275fe2e8652c4d33c8b3cbdafb7b5b25ae68)) — 2026-03-27 13:13


- **Added .skill and modified using-mercury** ([57aa3c2](https://github.com/mercuryintelligence/terminalbeta/commit/57aa3c2ebe066d17fa523a5fa248d8f7ded348be)) — 2026-04-18 01:15


- **Merge remote-tracking branch 'origin/main'** ([cde06c6](https://github.com/mercuryintelligence/terminalbeta/commit/cde06c67ad1b8be16c678e9606fd08241d790664)) — 2026-04-23 12:02


- **Added caveman-mercury** ([6aaadb5](https://github.com/mercuryintelligence/terminalbeta/commit/6aaadb59140d5f5e85431efba38066a681d28c4e)) — 2026-05-12 15:07


- **Added caveman-mercury** ([96ba271](https://github.com/mercuryintelligence/terminalbeta/commit/96ba271b130ea2e03d7d39d20bc7134b1c7753cd)) — 2026-05-12 15:11


- **Merge branch 'chore/update-skill-bundle'** ([5df624f](https://github.com/mercuryintelligence/terminalbeta/commit/5df624f304a951dce68d2c620bd36dc8456b0250)) — 2026-05-12 15:39


### Project maintenance

- **Drop npm publish — distribute via npx github: instead** ([3bb2760](https://github.com/mercuryintelligence/terminalbeta/commit/3bb27608062b7ff43f4cb20c5857e38df3998c18)) — 2026-03-05 18:50

  Removes GH Actions publish workflow. Users run:
    npx github:Jaggerxtrm/mercury-install-mcp


- **Add README and sync installer_ssot memory to streamable-http** ([13bc6c8](https://github.com/mercuryintelligence/terminalbeta/commit/13bc6c8c2034707b62d3e72db5f8fa4a9d369db2)) — 2026-03-09 15:42

  - Add README.md covering usage, server table, UX flow, architecture,
    version pinning, and how to add new servers
  - Update installer_ssot memory: fix stale SSE transport/URL references
    to reflect streamable-http migration (commits 646cb80–cadb39a)


- **Add Mercury agent skills reference to README** ([617d7c9](https://github.com/mercuryintelligence/terminalbeta/commit/617d7c90ddf031e184515c9223bb92540c8fd3dc)) — 2026-03-09 15:55

  Documents all 11 Claude Code skills for beta testers — session
  onboarding skill plus 10 scenario workflows covering market scan,
  deep dive, yield curve, FX, commodities, news flow, econ calendar,
  vol regime, and cross-asset risk mapping.


- **Clarify skills workflow — beta runs in repo, copy is optional** ([71d0b02](https://github.com/mercuryintelligence/terminalbeta/commit/71d0b02be767f87eb79fa7c94caacec5f1e91433)) — 2026-03-09 17:09


- **Add mercury-pubfinance to README server table and fix "three MCPs" references** ([c7731bc](https://github.com/mercuryintelligence/terminalbeta/commit/c7731bc4467507ad071162744f7c552c0eee8a91)) — 2026-03-17 12:43


- **Update serena project config with line_ending setting** ([429ae0a](https://github.com/mercuryintelligence/terminalbeta/commit/429ae0a9742dd426b2987b2c517864b389fadc18)) — 2026-03-17 16:38


- **Sync specialist configs from market-data** ([6955b9d](https://github.com/mercuryintelligence/terminalbeta/commit/6955b9d42bcf98ac4b2486eeac6bfdc1036c0c04)) — 2026-04-23 11:10

  - Added service-skills-sync specialist (Librarian for SKILL.md drift sync)
  - Updated explorer: scoping-service-skills wired in, scope.py pre-script
  - Updated executor: scoping-service-skills wired in, scope.py pre-script
  - Fixed service-skills-sync model (nano-gpt/zai-org/glm-5), context guard


- **Chore** ([e2382ad](https://github.com/mercuryintelligence/terminalbeta/commit/e2382adadd856ed5923e7e86abf7aa58c6985c54)) — 2026-05-05 15:35


- **Clean up repo for public users (#30)** ([20d61a3](https://github.com/mercuryintelligence/terminalbeta/commit/20d61a320ad5912d57a3e2589d193c4b30ca993d)) — 2026-05-05 16:58

  * chore: exclude dev-tool dot dirs from git

  Add .beads, .claude, .gitnexus, .mcp.json, .pi, .serena, .specialists,
  and .xtrm to .gitignore and untrack all 569 files. This repo is
  user-facing — these are local dev tooling artifacts, not project content.

  Also fix stale absolute paths in .claude/settings.json hooks
  (/home/dawid/projects/mercury/terminalbeta → /mnt/c/dev/terminalbeta).


- **Add filing-bugs as reference in using-mercury.skill bundle (#33)** ([37f5937](https://github.com/mercuryintelligence/terminalbeta/commit/37f5937241ed19d4cc0ea19bbc5d886b6c24cecc)) — 2026-05-05 18:21


- **Add security-pipeline default skill (#37)** ([71f6f9a](https://github.com/mercuryintelligence/terminalbeta/commit/71f6f9abe9fc6f4091aa6d197308323c3bef3bb1)) — 2026-05-09 07:20

  * specialists: wire scoping-service-skills into explorer (user-layer override)

  * chore(skills): add security-pipeline default skill

  Project-agnostic skill packaging the Mercury security baseline
  (Dependabot + OSV + Semgrep + gitleaks + pre-commit + Codex).


- **Sync security-pipeline templates with workflow fix (#42)** ([5fa140a](https://github.com/mercuryintelligence/terminalbeta/commit/5fa140ae71fe8794be6b67bd8804646519f72b58)) — 2026-05-09 08:51

  Mirrors the canonical workflow fix applied earlier (osv-scanner --skip-git
  removal + semgrep PR-only trigger) into the local skill templates copy
  so the skill stays self-consistent.


- **Add filing-bugs as reference in using-mercury.skill bundle** ([471f68f](https://github.com/mercuryintelligence/terminalbeta/commit/471f68f2a00ad86775227c88f40873a36af01137)) — 2026-05-05 18:21


- **Reconcile pi update git state** ([828d450](https://github.com/mercuryintelligence/terminalbeta/commit/828d450f846ab99ac443fe8017477e87c4afd199)) — 2026-05-21 15:18

  Reconcile pi/xtrm generated git state, fix OSV findings, and pin OSV scanner action.


- **Close completed Mercury docs issues** ([942c0b0](https://github.com/mercuryintelligence/terminalbeta/commit/942c0b0bd4de15bef77f973d961e62487299fae9)) — 2026-05-21 16:06

  Close stale in-progress docs beads terminalbeta-9kr and terminalbeta-90p.


- **Commit xtrm-tools 0.8.3 service-skills propagation (managed files only)** ([2e11958](https://github.com/mercuryintelligence/terminalbeta/commit/2e11958896b99616e30368ff861202f9b0fdc5c7)) — 2026-06-01 18:36


- **Sync xtrm v0.9.0 assets** ([7474ade](https://github.com/mercuryintelligence/terminalbeta/commit/7474ade49d042902ee7ec927741f140199e6ad14)) — 2026-06-07 01:47


- **Apply bd auto-stage patch (xtrm-tools auto-applied)** ([be4e08c](https://github.com/mercuryintelligence/terminalbeta/commit/be4e08cddac0af1219077d7f96d8f5411fa6dd46)) — 2026-07-13 06:07


- **Finalize v2 skills migration, adopt v0.10.4 hook paths** ([af96ef7](https://github.com/mercuryintelligence/terminalbeta/commit/af96ef78751eb82f7c8fbf89f74852121ea863a4)) — 2026-07-13 10:27

  - Stage retirement of per-repo .xtrm/skills/default/** (skills now global
    at ~/.xtrm/skills/default/ under v2 layout).
  - Adopt v0.10.4 service-skills hook paths: $CLAUDE_PROJECT_DIR -> $HOME
    (both .claude/settings.json and .xtrm/config/hooks.json).
  - Untrack runtime state (.xtrm/skills/state.json, .xtrm/worktrees/*, .pi/skills/)
    and gitignore them going forward.


- **Add git-cliff config and changelog** ([84167fc](https://github.com/mercuryintelligence/terminalbeta/commit/84167fc1bafe6205b31cf25846c50b940c425cc6)) — 2026-07-14 00:55

  Generic type-based parsers; repo-specific scopes to be tuned (see P0 bead).
