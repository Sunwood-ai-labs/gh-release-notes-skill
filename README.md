<div align="center">
  <img src="./assets/logo.svg" alt="GitHub Release Notes Skill logo" width="112" height="112">
  <h1>GitHub Release Notes Skill</h1>
  <p><strong>Codex skill for drafting and publishing GitHub release notes from real git diffs, tags, and validation evidence, or turning that same evidence into docs-backed article pages.</strong></p>
  <p>
    <a href="./README.ja.md">Japanese</a>
    |
    <a href="./SKILL.md">Skill Source</a>
    |
    <a href="./CONTRIBUTING.md">Contributing</a>
  </p>
  <p>
    <img src="https://img.shields.io/badge/Codex-Skill-0ea5e9.svg" alt="Codex Skill">
    <img src="https://img.shields.io/badge/PowerShell-5%2B-5391fe.svg" alt="PowerShell 5 or newer">
    <img src="https://img.shields.io/badge/GitHub%20CLI-gh-181717.svg" alt="GitHub CLI">
    <a href="./LICENSE"><img src="https://img.shields.io/badge/License-MIT-0f172a.svg" alt="MIT License"></a>
  </p>
</div>

![GitHub Release Notes Skill hero](./assets/hero.svg)

GitHub Release Notes Skill helps Codex turn repository evidence into publishable GitHub release notes or docs-backed article pages. It packages a production-ready `SKILL.md`, a PowerShell context collector, reusable drafting references, and repository QA so release bodies and article pages stay grounded in actual diffs instead of thin commit summaries.

## Why This Repo

- Build release notes from real code changes, not `git log --oneline` alone.
- Handle both first releases and incremental tagged releases with the same workflow.
- Reuse the same release evidence to draft docs article pages when the user wants a blog or announcement post.
- Reuse an existing versioned release header SVG when the target repository already has one.
- Derive a versioned release header SVG by default from existing repo branding such as `assets/icon.svg`, `assets/logo.svg`, or a branded `assets/social-card.svg` when no earlier release-header asset exists yet, the release would benefit from a hero image, and the branding is suitable for reuse.
- Validate every candidate or generated SVG with the bundled SVG validator before reusing it in release collateral.
- Keep publication grounded in `gh release create`, `gh release edit`, and post-publish verification.
- Mirror release notes into repository docs by default when the target repository already publishes a docs site.
- Force a code-backed truth-sync pass so README and primary operator docs do not drift behind release collateral.
- Leave an auditable release QA inventory artifact and validate it before calling the release task complete.
- Ship the skill with bilingual top-level docs and lightweight QA so the repository is ready to share.

## Quick Start

1. Confirm the required tools are available:

   ```powershell
   git --version
   gh --version
   gh auth status
   ```

2. Fetch the latest tags in the target repository if needed:

   ```powershell
   git fetch --tags --force
   ```

3. Run the bundled collector from this repository against the tag or target you want to describe:

   ```powershell
   powershell -ExecutionPolicy Bypass -File ./scripts/collect-release-context.ps1 -Tag v0.1.0
   ```

4. Inspect the highest-impact patches before drafting:

   ```powershell
   git show --stat v0.1.0
   git show HEAD~1..HEAD
   ```

5. Draft the requested output from the inspected evidence and keep each claim scoped to the exact command, service, or surface the code supports:

   ```text
   Use $gh-release-notes to inspect the real diff for this tag and draft either the GitHub release body or docs-backed article pages.
   ```

6. Publish or update the GitHub release after drafting a notes file:

   ```powershell
   gh release create v0.1.0 --title "v0.1.0" --notes-file .\tmp\release-notes-v0.1.0.md
   gh release view v0.1.0 --json url,body
   ```

7. If the user asked for article output instead of only release notes, create the article pages in the repository docs during the same task, for example `docs/guide/articles/<slug>.md` and `docs/ja/guide/articles/<slug>.md` when the docs site already supports both locales.

8. If the target repository already has a versioned header SVG such as `assets/release-header-v0.2.0.svg`, derive a new header for the target version, publish it where docs can serve it, and place it near the top of the GitHub release body plus the related docs pages. If there is no versioned header yet but the repository already ships reusable SVG branding such as `assets/icon.svg`, `assets/logo.svg`, or a branded `assets/social-card.svg`, derive a new `release-header-v*.svg` from that branding by default when the release would benefit from a hero image and the branding is suitable for reuse. In both cases, validate every candidate source SVG and the generated output with `powershell -ExecutionPolicy Bypass -File ./scripts/verify-svg-assets.ps1 -RepoPath . -Path <svg-paths>` before you reuse or publish them; otherwise document why you skipped the header.

9. If the target repository already publishes docs, update those docs pages first, run a truth-sync pass across `README` and the primary operator guides, and then edit the GitHub release so badge links point at live docs URLs.

10. Save a filled release QA inventory file at the standard path `tmp/release-qa-v0.1.0.md` in the target repository from [`references/release-qa-inventory-template.md`](./references/release-qa-inventory-template.md), then validate it as the mandatory pre-close gate:

   ```powershell
   powershell -ExecutionPolicy Bypass -File D:\Prj\gh-release-notes-skill\scripts\verify-release-qa-inventory.ps1 -RepoPath . -Tag v0.1.0
   ```

11. Trigger the skill from Codex:

   ```text
   Use $gh-release-notes to draft or update GitHub release notes from the actual code diff for this tag, or turn that same evidence into docs article pages.
   ```

## What Ships In The Repo

| Surface | Purpose |
| --- | --- |
| [`SKILL.md`](./SKILL.md) | Core Codex skill prompt and release-note workflow |
| [`agents/openai.yaml`](./agents/openai.yaml) | Metadata for skill discovery surfaces |
| [`scripts/collect-release-context.ps1`](./scripts/collect-release-context.ps1) | Collects tags, commit range, changed files, diff stats, and ordered commit history |
| [`scripts/verify-release-qa-inventory.ps1`](./scripts/verify-release-qa-inventory.ps1) | Validates the per-release QA inventory artifact before the task is closed |
| [`scripts/verify-svg-assets.ps1`](./scripts/verify-svg-assets.ps1) | Validates candidate SVG branding and generated header SVGs before they are reused or published |
| [`references/release-note-checklist.md`](./references/release-note-checklist.md) | Review checklist for large or messy releases |
| [`references/release-note-outline.md`](./references/release-note-outline.md) | Reusable drafting outline for release-note structure |
| [`references/release-qa-inventory-template.md`](./references/release-qa-inventory-template.md) | Runtime QA artifact template for claim matrices and truth-sync evidence |
| [`references/release-note-template.md`](./references/release-note-template.md) | Fill-in template for turning diff evidence into a release body |
| [`CONTRIBUTING.md`](./CONTRIBUTING.md) | Maintenance and QA guidance for future updates |

## Recommended Release Workflow

1. Read the target repository `README.md` if it exists.
2. Inspect the current release body with `gh release view <tag>` when the tag is already published.
3. Run [`scripts/collect-release-context.ps1`](./scripts/collect-release-context.ps1) to determine the comparison range.
4. Review the actual diffs for changed scripts, workflows, docs, packaging files, and user-facing assets.
5. Draft notes around behavior and release scope, not raw filenames.
6. Inspect the code paths or tests behind implementation-sensitive claims such as routing, retry/backoff, model selection, defaults, environment variables, telemetry surfaces, and path-specific outputs.
7. Reuse the repository's docs framework, locale structure, and any existing release header SVG pattern when a docs surface already exists.
8. If no versioned release header exists yet but the repository already ships reusable SVG branding, default to deriving and shipping a new `release-header-v*.svg` when the release would benefit from a hero image and the branding is suitable for reuse; otherwise record an explicit skip or review-required decision.
9. Run [`scripts/verify-svg-assets.ps1`](./scripts/verify-svg-assets.ps1) on every candidate source SVG before reuse, then validate the generated `release-header-v*.svg` before you publish or reference it.
10. Treat release notes and walkthrough articles as release collateral, then review `README` plus the primary operator guides to decide which steady-state docs also need updates.
11. Materialize the release QA inventory at `tmp/release-qa-<tag>.md` in the target repository and validate it with [`scripts/verify-release-qa-inventory.ps1`](./scripts/verify-release-qa-inventory.ps1) by passing the repo path and tag.
12. Publish with `gh release create` or `gh release edit`.
13. Verify the published body with `gh release view <tag> --json url,body`, and verify docs URLs, header-image URLs, SVG validator results, truth-synced operator docs, and the validated QA inventory artifact too.

## Setup And Applied Example

One good real-repo example is [Sunwood-ai-labs/bitnet-android-lab](https://github.com/Sunwood-ai-labs/bitnet-android-lab). Its public README describes a narrow Android Termux lab path that worked on March 23, 2026, with follow-up spot checks from March 25, 2026, and it explicitly avoids broad compatibility claims. That makes it a strong example for `$gh-release-notes` because the skill has to keep release wording narrow, evidence-backed, and aligned with docs plus caveats.

Use that repo as a setup-and-application pattern like this:

1. Read the root README and the published docs-linked setup guide such as `docs/guide/setup-termux.md`.
2. Inspect the repo map and evidence surfaces called out by the project itself: `docs/`, `evidence/`, `patches/`, `scripts/termux/`, and `scripts/windows/`.
3. Run [`scripts/collect-release-context.ps1`](./scripts/collect-release-context.ps1) in the target clone to resolve the actual compare range before drafting.
4. Treat docs-backed release notes and a companion walkthrough article as the default outcome because the repo already publishes docs.
5. Keep claims scoped to the verified path only, including the repo's own caveats about patched local builds, checkpoint status, and limited rerun coverage.
6. If the repo later adds SVG header assets or branded SVG seeds, validate them with [`scripts/verify-svg-assets.ps1`](./scripts/verify-svg-assets.ps1) before reusing them in release collateral.
7. Record the docs review, evidence review, and any validation commands in `tmp/release-qa-<tag>.md`, then validate the artifact before closing the task.

Example prompt:

```text
Use $gh-release-notes for Sunwood-ai-labs/bitnet-android-lab. Treat docs-backed release notes and a companion walkthrough article as the default outcome. Inspect README.md, docs/guide/setup-termux.md, docs/results/, docs/reference/, evidence/manifest.md, patches/qvac-fabric-llm.cpp/, scripts/termux/, and scripts/windows/. Keep every claim scoped to the verified Android Termux path documented in the repo and preserve the repo's caveats instead of generalizing to broad Android compatibility.
```

## Local QA

Run the repository verification script before publishing changes to this repo:

```powershell
powershell -ExecutionPolicy Bypass -File ./scripts/verify-repo-surfaces.ps1
```

The script checks required files, relative Markdown links, README language switches, asset wiring, PowerShell syntax for the bundled scripts, and the validity of the repo's own SVG assets.

## Compatibility Notes

- The helper scripts are PowerShell-based because release-note work often happens in Windows-heavy repositories. Local examples use `powershell`, while the GitHub workflow runs them in `pwsh` for cross-platform CI.
- This repository intentionally uses focused top-level documentation instead of a full docs site because the product surface is a single skill, one helper script, and a small set of references.
- When writing a temporary notes file on Windows, use UTF-8 without BOM before calling `gh release create` or `gh release edit`.

## License

This repository is released under the [MIT License](./LICENSE).
