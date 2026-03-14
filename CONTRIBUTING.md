# Contributing

## Scope

This repository packages one Codex skill, one release-context collector, and a small set of references. Keep changes focused on improving release-note drafting quality, publication reliability, and repository clarity.

## Repository Layout

| Path | Purpose |
| --- | --- |
| `SKILL.md` | Core skill instructions that Codex reads directly |
| `agents/openai.yaml` | Discovery metadata for the skill |
| `scripts/` | PowerShell helpers for release-note workflows and repository QA |
| `references/` | Human-readable drafting guidance and checklists |
| `assets/` | Shared README branding assets |

## Before Opening A Change

1. Update `README.md` and `README.ja.md` together when public guidance changes.
2. Keep `SKILL.md`, helper scripts, and reference files aligned when the workflow changes.
3. If you add a new public-facing file, wire it into `scripts/verify-repo-surfaces.ps1`.

## Local QA

Run the repository verification script:

```powershell
powershell -ExecutionPolicy Bypass -File ./scripts/verify-repo-surfaces.ps1
```

The script checks:

- required repository files
- relative Markdown links
- README language switches
- README asset references
- PowerShell syntax for the bundled scripts

## Editing Guidelines

- Prefer extending bundled scripts and references over duplicating the same guidance in multiple files.
- Keep examples grounded in actual `git` and `gh` commands that are valid on Windows.
- When examples write a notes file for `gh release create` or `gh release edit`, keep the encoding guidance aligned with `SKILL.md`.
- Keep README and contributing docs structurally parallel across English and Japanese.

## Commit Style

Use the repository convention for commits:

- English title
- emoji prefix in the title
- about three bullet lines in the body describing the actual work
