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
- Decide whether the release note also needs to live in the repository docs, and in which languages.

## 2. Collect evidence

- Run `scripts/collect-release-context.ps1` first.
- Read `git diff --stat` output for overall shape.
- Read `git log --reverse --stat` for sequence and grouping.
- Inspect the actual patches for major commits and changed files with `git show`.
- Prioritize scripts, workflows, fixtures, public docs, and visible assets.
- Keep a short evidence list so each release-note claim can be tied back to a file or diff.
- If docs-backed release notes are requested, inspect the docs framework, locale structure, and deployment path before drafting links.

## 3. Translate the diff into capabilities

- Translate file diffs into capabilities.
- Name concrete behavior such as supported flags, new detection rules, validation steps, or install flows.
- Mention docs and visual assets after core functionality unless the release is docs-only.
- If a script or workflow materially protects quality, explain what it checks.
- If you cannot explain why a change matters to a release reader, inspect the patch again before drafting.

## 4. Draft honestly

- Only mention validation that you actually ran.
- Only mention support that is visible in the code or docs you inspected.
- If a release body was previously thin, rewrite it instead of lightly appending bullets.
- Say explicitly when the note covers a first release or a partial branch-based target instead of a normal tag-to-tag comparison.
- Use [release-note-template.md](./release-note-template.md) when you need a neutral outline before editing the final prose.

## 5. Publish and verify

- Use `gh release create` for new releases.
- Use `gh release edit` for existing releases or rewrites.
- Write temporary note files as UTF-8 without BOM on Windows.
- Verify with `gh release view <tag> --json url,title,body`.
- If you added docs pages, publish those changes first and confirm the docs URLs resolve before finalizing badge links in the GitHub release body.

## Anti-patterns

- Writing from commit subjects alone
- Using `--generate-notes` as the only evidence source
- Reducing a large first release to a few generic bullets
- Leading with README polish when substantive code or tooling changed
- Claiming tests passed without running them
- Publishing a note without checking the final rendered body
- Pointing GitHub release badges at docs URLs that are not live yet
