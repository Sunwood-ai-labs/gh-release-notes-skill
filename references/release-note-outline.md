# Release Note Outline

Use this outline when you need a clean release-note structure after you finish reading the real diffs.

## 1. Release Scope

- State the target tag.
- State the comparison range.
- Say explicitly whether this is an initial release.

Example:

```text
This release covers v0.4.0, compared with v0.3.0.
```

## 2. Highlights

Lead with the highest-value user-visible changes.

- new capabilities
- notable behavior changes
- important workflow or automation additions

## 3. Tooling And Validation

Use this section only when you actually ran or inspected meaningful checks.

- validation commands you ran
- release-protection workflows or fixtures added in the diff
- follow-up operational notes that materially affect the release

## 4. Docs And Assets

Place README, docs, examples, or visual updates after product or tooling changes unless the release is docs-only.

## 5. Initial Release Note

When there is no previous tag, say so directly instead of pretending the release is incremental.

Example:

```text
This is the initial tagged release, so the notes below cover the full shipped history included in v0.1.0.
```

## 6. Avoid These Weak Patterns

- raw filename lists without explaining behavior
- commit-subject summaries with no diff evidence
- claiming checks passed when you did not run them
- leading with docs polish when the actual release added functionality
