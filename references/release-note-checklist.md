# Release Note Checklist

Use this checklist when the release is large, the history is messy, or the user explicitly wants notes based on the actual code diff.

## 1. Confirm scope

- Identify the target tag, commit, or branch.
- Confirm whether you are drafting, rewriting, or publishing the release body.
- Check whether a GitHub release already exists.
- Fetch tags if the local clone may be stale.
- Determine the previous tag.
- If no previous tag exists, treat the release as an initial release and say so in the notes.
- Decide the note language and whether publication is expected in the current task.
- Assume the release note should also live in the repository docs when a docs surface exists, and identify which languages the docs already support.
- Check whether the repository already has a versioned release header SVG that should be updated for this release.

## 2. Collect evidence

- Run `scripts/collect-release-context.ps1` first.
- Read `git diff --stat` output for overall shape.
- Read `git log --reverse --stat` for sequence and grouping.
- Inspect the actual patches for major commits and changed files with `git show`.
- Prioritize scripts, workflows, fixtures, public docs, and visible assets.
- Inspect any existing `release-header-v*.svg` assets so you can reuse the established visual language when needed.
- Keep a short evidence list so each release-note claim can be tied back to a file or diff.
- Inspect the docs framework, locale structure, and deployment path before drafting links whenever the repository already has a docs surface.
- For implementation-sensitive claims such as routing, retry/backoff, model selection, defaults, environment variables, telemetry, or output surfaces, inspect the implementing code paths and relevant tests, not just the top-level diff.
- When those claims depend on runtime wiring, read the config readers, command entrypoints, runtime call sites, and operator-visible output formatting.

## 3. Translate the diff into capabilities

- Translate file diffs into capabilities.
- Name concrete behavior such as supported flags, new detection rules, validation steps, or install flows.
- Mention docs and visual assets after core functionality unless the release is docs-only.
- If the repository already ships release header art, carry that forward into the new release instead of silently dropping the visual header.
- If a script or workflow materially protects quality, explain what it checks.
- If you cannot explain why a change matters to a release reader, inspect the patch again before drafting.
- Keep each claim scoped to the exact command, service, embed, deployment mode, or operator surface the implementation supports.

## 4. Truth-sync steady-state docs

- Treat the GitHub release body, docs-backed release notes page, and companion walkthrough article as release collateral, not as a substitute for steady-state docs.
- Extract the operator-facing claims introduced or emphasized by the release collateral.
- Decide which of those claims are stable enough that `README`, overview, CLI, setup, deployment, smoke-test, quickstart, env docs, or operator runbooks should also change.
- Record a small claim matrix with `claim`, `code refs`, `validation refs`, `docs surfaces touched`, and `version-scoped or steady-state`.
- Materialize that evidence in the standard release QA inventory path `tmp/release-qa-<tag>.md`, copied from [release-qa-inventory-template.md](./release-qa-inventory-template.md), so the task leaves a durable audit trail.
- Update stale "latest release" links, overview pointers, or docs navigation where the repository exposes them.
- Validate the filled inventory file with [../scripts/verify-release-qa-inventory.ps1](../scripts/verify-release-qa-inventory.ps1) by passing the target repo path and tag.
- Do not call the task done while a required steady-state docs update is still missing, blocked, only present in release collateral, or failing inventory validation.

## 5. Draft honestly

- Only mention validation that you actually ran.
- Only mention support that is visible in the code or docs you inspected.
- If a release body was previously thin, rewrite it instead of lightly appending bullets.
- Say explicitly when the note covers a first release or a partial branch-based target instead of a normal tag-to-tag comparison.
- Use [release-note-template.md](./release-note-template.md) when you need a neutral outline before editing the final prose.

## 6. Publish and verify

- Use `gh release create` for new releases.
- Use `gh release edit` for existing releases or rewrites.
- Write temporary note files as UTF-8 without BOM on Windows.
- Verify with `gh release view <tag> --json url,title,body`.
- If you added docs pages, publish those changes first and confirm the docs URLs resolve before finalizing badge links in the GitHub release body.
- If you added a release header image, confirm the image URL resolves from the GitHub release body and that the docs pages render it.
- If the release introduced operator-facing claims, report which steady-state docs were checked, updated, or explicitly left unchanged with rationale.
- Report the QA inventory artifact path and the validator result alongside the usual release verification output.

## Anti-patterns

- Writing from commit subjects alone
- Using `--generate-notes` as the only evidence source
- Reducing a large first release to a few generic bullets
- Leading with README polish when substantive code or tooling changed
- Claiming tests passed without running them
- Publishing a note without checking the final rendered body
- Pointing GitHub release badges at docs URLs that are not live yet
- Forgetting to carry forward an existing versioned release header asset pattern when the repository already uses one
- Treating a companion walkthrough article as sufficient while README or primary operator docs are still stale
- Broadening a path-specific implementation detail into a repo-wide claim without code evidence
