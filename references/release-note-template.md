# Release Note Template

Use this outline after reading the actual diff. Replace the placeholders with release-specific evidence.

## Scope Sentence

- State the target tag and comparison range.
- Say explicitly when the release is an initial release with no previous tag.

## Optional Docs Mirror

- If the user wants docs-backed release notes, add links or badges near the top of the GitHub release body that point to the published docs page.
- Mirror the release note into the repository docs in each requested language.
- Publish docs before the final `gh release edit` when the release body should point at live docs URLs.

## Highlights

- Describe the most important shipped behavior first.
- Prefer outcome-focused bullets over filename-only bullets.

## Tooling And Automation

- Capture scripts, workflows, fixtures, or packaging changes that materially affect delivery or verification.

## Docs And Assets

- Mention README, docs, or public assets after substantive product or tooling changes unless the release is docs-only.

## Validation

- List the checks you actually ran.
- If you did not run validation, say so instead of implying it passed.

## Upgrade Notes

- Mention migration steps, manual follow-up, or compatibility notes only when the diff supports them.
