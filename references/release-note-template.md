# Release Note Template

Use this outline after reading the actual diff. Replace the placeholders with release-specific evidence.

## Scope Sentence

- State the target tag and comparison range.
- Say explicitly when the release is an initial release with no previous tag.

## Default Docs Mirror

- When the repository already has a docs surface, add links or badges near the top of the GitHub release body that point to the published docs page.
- Mirror the release note into the repository docs in each already-supported language unless the user explicitly narrows the scope.
- Publish docs before the final `gh release edit` when the release body should point at live docs URLs.
- If the repository does not have a docs publishing surface, skip this section instead of inventing a new docs system just for the release note.

## Header Visual

- If the repository already has a versioned release header SVG such as `assets/release-header-v0.2.0.svg`, derive a new one for the target release instead of starting from scratch.
- Keep the established visual family, but update the version text and any release-specific emphasis.
- Make sure the final image is available from a published URL for the GitHub release body and from a docs-relative path for docs pages.
- Place the header image near the top of the GitHub release body, the docs release page, and any related docs article page.

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
