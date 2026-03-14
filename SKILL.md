---
name: gh-release-notes
description: Draft and publish GitHub release notes from actual git diffs and tags using gh. Use when Codex needs to create, revise, or verify release notes for a GitHub release, especially when the notes must be based on real code changes, commit ranges, touched files, validation results, or a first release with no previous tag. By default, mirror the release note into repository docs too when the target repository already has a docs surface, unless the user explicitly asks not to.
---

# GitHub Release Notes

## Overview

Create release notes from repository evidence, not commit subjects alone.

Use this skill to:

- draft release notes before publishing a tag
- rewrite thin or inaccurate existing GitHub release bodies
- create or update GitHub releases with `gh release create` or `gh release edit`
- handle first releases where there is no previous tag
- mirror release notes into repository docs by default when the target repository already publishes docs
- keep release notes grounded in actual shipped behavior

## Prerequisites

- access to a local clone of the target repository
- `git` available in the shell
- `gh` installed and authenticated if publishing is requested
- permission to inspect diffs, tags, and release state

## Default Workflow

1. Read the target repository `README` if one exists and inspect the tag or release state.
   - Run `gh auth status` if the user expects you to publish or edit a GitHub release.
   - Fetch tags first when the local clone may be stale.
2. Determine the comparison range.
   - If the target tag has a previous tag, compare from that previous tag to the target tag.
   - If there is no previous tag, treat the release as an initial release and cover the full shipped history explicitly.
   - Use an explicit base tag when the release line is non-linear or when backfilled tags make auto-detection ambiguous.
3. Run the bundled collector first.
   - `powershell -ExecutionPolicy Bypass -File ./scripts/collect-release-context.ps1 -Tag v0.1.0`
   - If the tag exists only on GitHub and not in the local clone yet, fetch tags first or use `-Target <commit-or-branch>`.
   - Use `-BaseTag <tag>` to override the automatically detected previous tag.
   - Read the output, then inspect the actual diffs for the high-impact files and commits.
4. Review implementation diffs, not just summaries.
   - Read the changed file list and diff stats first.
   - Always inspect new or heavily changed scripts, workflows, fixtures, docs, and user-facing assets.
   - Use `git show` on major commits and touched files until you can name concrete capabilities added.
5. Draft the notes in the user's requested language.
   - Open with release scope and whether it is an initial release.
   - Group notes by user-visible capabilities and implementation areas, not by raw commit count.
   - Mention validation only if you actually ran it.
   - Use [references/release-note-template.md](./references/release-note-template.md) when you want a drafting scaffold.
6. Inspect the repository docs surface before publishing and treat docs-backed release notes as the default path.
   - Reuse the existing docs framework, locale structure, and navigation style instead of inventing a parallel format.
   - Create or update the matching docs page in every language already supported by the repository, unless the user narrowed the request.
   - If the GitHub release body should link into docs, publish the docs changes first so the final release body can point at live URLs.
   - Prefer badge-style links at the top of the GitHub release body so readers can jump to the docs pages.
   - Skip the docs mirror only when the repository clearly has no docs publishing surface or the user explicitly asks you not to add docs pages.
7. Publish or update the release with `gh`.
   - Use `gh release create <tag> --title ... --notes-file ...` when the release does not exist.
   - Use `gh release edit <tag> --notes-file ...` when the release already exists or needs a rewrite.
8. Verify the published body.
   - Run `gh release view <tag> --json url,title,body` and confirm the text matches what you intended.
   - If you created docs pages, verify those URLs resolve and that the release body points at the published docs routes.

## Evidence Standard

- Do not rely on `git log --oneline` alone.
- Do not rely on `gh release create --generate-notes` alone when the user asks for diff-based notes.
- Do not summarize a large initial release with only generic bullets.
- Do not claim support for a feature unless you can point to the file or diff that introduced it.
- Do not claim checks passed unless you ran them in the current repo.
- If the earlier note is thin, deepen it by reading the code diffs and rewriting the release body.

## Inspection Priorities

Inspect these categories whenever they appear in the diff:

- new or rewritten scripts under `scripts/`
- CI or automation under `.github/workflows/`
- fixtures, test data, or regression helpers
- README, `SKILL.md`, docs, references, or public assets
- packaging or version metadata such as `package.json`, `pyproject.toml`, or release config

For detailed drafting rules and anti-patterns, read [references/release-note-checklist.md](./references/release-note-checklist.md).

## Drafting Rules

- Prefer sections like `Highlights`, `Tooling`, `Validation`, `Docs And Assets`, or equivalent based on the diff.
- Lead with the biggest shipped change, not the easiest file to summarize.
- Mention docs and visuals after the product or tooling changes unless the release is docs-only.
- For initial releases, say explicitly that the notes cover the full history shipped in that tag.
- When a script adds real behavior, name the behavior, not just the filename.
- When a workflow or fixture materially protects the release, explain what it validates.
- Keep the GitHub release body readable on its own and use badges or short links to point at the fuller docs pages.
- Treat docs-backed release notes as the standard outcome whenever the repository already has a published docs surface.
- Keep the final note dense with evidence but still readable.

## Windows Notes File Handling

When you need a temporary notes file on Windows, write UTF-8 without BOM before calling `gh`:

```powershell
$notesPath = Join-Path $env:TEMP "release-notes-v0.1.0.md"
$body = @"
# Highlights

- Replace this with evidence-based release notes.
"@
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($notesPath, $body, $utf8NoBom)
```

## Verification

- If you did not publish the release, say so clearly.
- If you did not run validation in the target repository, say so clearly.
- If there is no previous tag, verify that the drafted scope really covers the full shipped history.
- If the release already existed, confirm the final published body matches the rewritten note.
- If you created docs-backed release notes, confirm the docs build or deployment path succeeded before you call the work done.

## Publishing With gh

Common commands:

```powershell
gh release view v0.1.0
gh release create v0.1.0 --target main --title "v0.1.0" --notes-file $notesPath
gh release edit v0.1.0 --notes-file $notesPath
gh release view v0.1.0 --json url,body
```

## Resources

- Use [scripts/collect-release-context.ps1](./scripts/collect-release-context.ps1) to gather tags, commit range, diff stats, and changed files.
- Use [references/release-note-checklist.md](./references/release-note-checklist.md) when the repo is large or when you need a second pass on release-note depth and accuracy.
- Use [references/release-note-template.md](./references/release-note-template.md) for a drafting scaffold before publishing.
