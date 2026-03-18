---
name: gh-release-notes
description: Draft and publish GitHub release notes from actual git diffs and tags using gh, or turn the same release evidence into docs-backed article pages. Use when Codex needs to create, revise, or verify release notes for a GitHub release, especially when the notes must be based on real code changes, commit ranges, touched files, validation results, or a first release with no previous tag. Also use it when the user wants release articles written from GitHub release material or repository changes. When the target repository already has a docs surface, treat docs-backed release notes as mandatory and create a companion walkthrough article in docs by default for release publishing unless the user explicitly narrows the scope.
---

# GitHub Release Notes

## Overview

Create release notes from repository evidence, not commit subjects alone.

Use this skill to:

- draft release notes before publishing a tag
- rewrite thin or inaccurate existing GitHub release bodies
- create or update GitHub releases with `gh release create` or `gh release edit`
- handle first releases where there is no previous tag
- draft docs-backed article pages from the same release evidence when the user wants a blog or announcement post
- create a companion walkthrough article by default when publishing a release from a repository that already has a docs surface
- derive a new versioned release header SVG when the repository already has an earlier release header asset
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
   - Search for existing release header assets such as `assets/release-header-v0.2.0.svg`, `docs/public/.../release-header-v0.2.0.svg`, or similar versioned SVGs before deciding whether to create a new header image.
   - Use `git show` on major commits and touched files until you can name concrete capabilities added.
5. Draft the requested output in the user's requested language.
   - Open with release scope and whether it is an initial release.
   - Group the material by user-visible capabilities and implementation areas, not by raw commit count.
   - Mention validation only if you actually ran it.
   - Use [references/release-note-template.md](./references/release-note-template.md) when you want a release-note scaffold.
   - If the user wants GitHub release notes, draft a publishable release body.
   - If the repository has a docs surface and the user is publishing a release, create both docs-backed release notes and a companion walkthrough article by default unless the user explicitly asks for release-notes-only.
   - If the user wants article output, draft docs-backed article pages instead of a detached local draft whenever the repository has a docs surface.
   - Do not stop at "I will draft the article next" when article output is in scope. Create the article pages in the same task unless the user explicitly paused the work.
   - Do not treat the release-note page as a substitute for the companion walkthrough article when the repository already publishes docs and the release is being published.
6. If you are drafting article output, or if you are publishing a release in a repository with a docs surface, inspect the repository docs surface and place the article in docs by default.
   - When the repository already has bilingual English and Japanese docs, create both `docs/guide/articles/<slug>.md` and `docs/ja/guide/articles/<slug>.md`.
   - When the repository has only one docs locale, use the matching existing docs structure.
   - Keep the body free of Zenn or Qiita frontmatter.
   - Use a structure such as short introduction, key points, main features, workflow impact, validation, and links.
   - Reuse public screenshots, animated assets, and docs links when they help readers understand the release.
   - Update article index pages such as `docs/guide/articles.md` and `docs/ja/guide/articles.md` when they already exist.
   - Add a related article link from release summary pages when the docs structure already has release pages.
7. If the repository already has versioned release header SVG assets, create a new header image for the target version and reuse it everywhere the release appears.
   - Use the nearest existing asset, such as `assets/release-header-v0.2.0.svg`, as the visual base instead of inventing a totally new style.
   - Update the version text and adjust the header copy or visual emphasis to match the current release scope.
   - Save the new asset using the repository's established naming and folder pattern.
   - When the seed asset is outside the published docs asset surface, also create or mirror a published copy so docs pages and GitHub releases can reference it.
   - Place the header image near the top of the GitHub release body, the docs release page, and any docs article page created for the same release.
   - In the GitHub release body, use a published URL such as the docs site URL or a raw GitHub asset URL rather than a local relative path.
8. Inspect the repository docs surface before publishing and treat docs-backed release notes plus a companion docs-backed walkthrough article as the default path.
   - Reuse the existing docs framework, locale structure, and navigation style instead of inventing a parallel format.
   - Create or update the matching docs page in every language already supported by the repository, unless the user narrowed the request.
   - If the GitHub release body should link into docs, commit and push the docs changes first, wait for docs deployment, and only then publish or edit the final GitHub release body so it can point at live URLs.
   - Prefer badge-style links at the top of the GitHub release body so readers can jump to the docs pages.
   - Prefer linking both the docs-backed release notes page and the companion walkthrough article from the GitHub release body when both exist.
   - Skip the companion article only when the repository clearly has no docs publishing surface or the user explicitly asks for release-notes-only.
9. Publish or update the release with `gh` when GitHub publication is part of the task.
   - Ensure every docs page and asset referenced by the release body is already committed before creating the release tag.
   - Create and push the release tag only after the release docs and article pages are committed if those artifacts are part of the shipped release collateral.
   - Use `gh release create <tag> --title ... --notes-file ...` when the release does not exist.
   - Use `gh release edit <tag> --notes-file ...` when the release already exists or needs a rewrite.
10. Verify the published body when you published or edited the GitHub release.
   - Run `gh release view <tag> --json url,title,body` and confirm the text matches what you intended.
   - If you created docs pages, verify those URLs resolve and that the release body points at the published docs routes.
   - If you created a companion walkthrough article, verify that URL too and confirm the release body links to it when expected.
   - If you added a release header image, verify that the image URL resolves and renders from the GitHub release body and the docs pages.

## Evidence Standard

- Do not rely on `git log --oneline` alone.
- Do not rely on `gh release create --generate-notes` alone when the user asks for diff-based notes.
- Do not summarize a large initial release with only generic bullets.
- Do not claim support for a feature unless you can point to the file or diff that introduced it.
- Do not claim checks passed unless you ran them in the current repo.
- If the earlier note is thin, deepen it by reading the code diffs and rewriting the release body.
- Do not turn a docs article into vague marketing copy detached from the diff evidence.

## Inspection Priorities

Inspect these categories whenever they appear in the diff:

- new or rewritten scripts under `scripts/`
- CI or automation under `.github/workflows/`
- fixtures, test data, or regression helpers
- README, `SKILL.md`, docs, references, or public assets
- versioned release header assets such as `release-header-v*.svg`
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
- When a versioned release header SVG already exists in the repository, create and include the updated header instead of leaving the release without a hero image.
- Keep the final note dense with evidence but still readable.

## Docs Article Mode

When the user wants article output instead of, or in addition to, a GitHub release body, or when you are publishing a release in a repository that already has a docs surface:

- write natural prose, not translated commit history
- explain reader impact before internal implementation detail
- create docs article pages in the repository instead of saving a detached draft elsewhere
- finish the docs article pages in the same turn instead of leaving a follow-up promise
- when the docs site already supports both English and Japanese, write both locale pages
- place the release header image near the top when a versioned header SVG exists or can be derived from an earlier version
- include a final title, stable lead paragraph, main sections, and explicit links
- treat the docs article as the canonical source that can later be handed to `oasis-skill` for Zenn and Qiita distribution

## QA Inventory Gate

Before calling the release task done, produce and internally check a QA inventory with criterion status for at least these items:

- comparison range resolved from actual tags or an explicitly justified commitish override
- release claims backed by inspected diffs, files, or commits
- docs-backed release notes created or explicitly skipped with user-approved rationale
- companion walkthrough article created or explicitly skipped with user-approved rationale
- docs pages and assets referenced by the release body committed before tag creation
- docs deployment completed and live URLs verified before the final release body links to them
- release tag created locally and pushed remotely
- GitHub release published or updated and the final body verified with `gh release view`
- validation commands actually run, or clearly marked as not run
- hardcoded publish dates sourced from the actual tag or release timing, or omitted until the release exists

Do not mark the work complete while any required item is `fail` or `blocked`.

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
- If the repository has a docs surface and you published a release, verify the live docs-backed release-note URL and the live companion walkthrough-article URL unless the user explicitly opted out of the article.
- If the release body links to docs, confirm those docs pages were committed, pushed, and deployed before the final release body was published.
- If you created a release header image, report where the SVG was saved and where it is referenced.
- Do not hardcode a `Published on ...` date before the release exists. After publishing, align the date with the actual release or tag timing, or state the exact source of the date.
- If you drafted only docs article pages and did not publish a GitHub release, say that clearly and report the saved docs paths.

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
