# Release QA Inventory Template

Use this template during a real release task. Save a filled copy in the target repository, for example `tmp/release-qa-v1.2.3.md`, before you publish or close the task.

Do not leave the required tables empty. If a release does not need a surface, use `not_applicable` or `user_waived` with concrete evidence.

Allowed QA inventory statuses:

- `pass`
- `not_applicable`
- `user_waived`
- `fail`
- `blocked`

## Release Context

- repository: `gh-release-notes-skill`
- release tag: `v0.1.0`
- compare range: `HEAD`
- requested outputs: GitHub release body, docs-backed release notes, companion walkthrough article
- validation commands run: `powershell -ExecutionPolicy Bypass -File ./scripts/verify-repo-surfaces.ps1`
- release URLs: not published in this example template

## Claim Matrix

| claim | code refs | validation refs | docs surfaces touched | scope |
| --- | --- | --- | --- | --- |
| Example: release tasks now require a validated QA inventory before close-out | `SKILL.md`, `agents/openai.yaml`, `scripts/verify-release-qa-inventory.ps1` | `powershell -ExecutionPolicy Bypass -File ./scripts/verify-repo-surfaces.ps1` | `README.md`, `README.ja.md` | steady_state |

## Steady-State Docs Review

| surface | status | evidence |
| --- | --- | --- |
| README.md | pass | Updated the operator-facing release workflow and QA gate guidance |
| README.ja.md | pass | Synced the Japanese quick start and workflow guidance |
| SKILL.md | pass | Added the mandatory QA inventory gate and validator references |

## QA Inventory

| criterion_id | status | evidence |
| --- | --- | --- |
| compare_range | pass | `HEAD` for the example template in this repository |
| release_claims_backed | pass | `git show`, changed files, and claim matrix rows reviewed |
| docs_release_notes | user_waived | Skill repo does not publish release docs pages in this example |
| companion_walkthrough | user_waived | Skill repo does not publish companion walkthrough docs in this example |
| operator_claims_extracted | pass | Claim matrix completed above |
| impl_sensitive_claims_verified | pass | Verified validator behavior and skill prompts against code paths |
| steady_state_docs_reviewed | pass | README and primary operator docs reviewed in the table above |
| claim_scope_precise | pass | Narrowed wording to the release task workflow and validator surfaces |
| latest_release_links_updated | not_applicable | Repository has no latest-release landing pointers |
| docs_assets_committed_before_tag | not_applicable | Example template is for skill QA, not a published release run |
| docs_deployed_live | not_applicable | Example template is not tied to deployed docs URLs |
| tag_local_remote | user_waived | Example template is not publishing a live tag |
| github_release_verified | user_waived | Example template is not editing a live GitHub release |
| validation_commands_recorded | pass | Recorded in Release Context |
| publish_date_verified | not_applicable | Example template is not tied to a published release timestamp |

## Notes

- blockers:
- waivers:
- follow-up docs tasks:
