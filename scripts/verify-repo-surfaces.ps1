param(
  [string]$RepoPath = (Join-Path $PSScriptRoot "..")
)

$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path $RepoPath).Path
$failures = [System.Collections.Generic.List[string]]::new()

function Add-Failure {
  param([string]$Message)

  $script:failures.Add($Message) | Out-Null
}

function Resolve-RepoItem {
  param([string]$RelativePath)

  return Join-Path $repoRoot $RelativePath
}

function Test-RequiredFile {
  param([string]$RelativePath)

  $fullPath = Resolve-RepoItem $RelativePath
  if (-not (Test-Path -LiteralPath $fullPath)) {
    Add-Failure("Missing required file: $RelativePath")
  }
}

function Test-RequiredText {
  param(
    [string]$RelativePath,
    [string[]]$ExpectedText
  )

  $fullPath = Resolve-RepoItem $RelativePath
  if (-not (Test-Path -LiteralPath $fullPath)) {
    Add-Failure("Cannot inspect missing file: $RelativePath")
    return
  }

  $content = Get-Content -Raw -LiteralPath $fullPath
  foreach ($snippet in $ExpectedText) {
    if (-not $content.Contains($snippet)) {
      Add-Failure("$RelativePath is missing expected text: $snippet")
    }
  }
}

function Test-MarkdownLinks {
  param([string]$RelativePath)

  $fullPath = Resolve-RepoItem $RelativePath
  if (-not (Test-Path -LiteralPath $fullPath)) {
    Add-Failure("Cannot inspect missing Markdown file: $RelativePath")
    return
  }

  $content = Get-Content -Raw -LiteralPath $fullPath
  $matches = [regex]::Matches($content, '(?<!!)\[[^\]]+\]\(([^)]+)\)')
  foreach ($match in $matches) {
    $rawTarget = $match.Groups[1].Value.Trim()
    if ($rawTarget -match '\s+".*"$') {
      $rawTarget = $rawTarget -replace '\s+".*"$', ''
    }

    if ($rawTarget.StartsWith("#")) {
      continue
    }

    if ($rawTarget -match '^(https?:|mailto:)') {
      continue
    }

    if ($rawTarget -match '^[a-zA-Z][a-zA-Z0-9+.-]*:') {
      continue
    }

    $relativeTarget = ($rawTarget -split '#', 2)[0]
    if ([string]::IsNullOrWhiteSpace($relativeTarget)) {
      continue
    }

    $resolvedTarget = Join-Path (Split-Path -Parent $fullPath) $relativeTarget
    if (-not (Test-Path -LiteralPath $resolvedTarget)) {
      Add-Failure("$RelativePath references a missing local path: $rawTarget")
    }
  }
}

function Test-PowerShellSyntax {
  param([string]$RelativePath)

  $fullPath = Resolve-RepoItem $RelativePath
  if (-not (Test-Path -LiteralPath $fullPath)) {
    Add-Failure("Cannot parse missing PowerShell file: $RelativePath")
    return
  }

  $tokens = $null
  $errors = $null
  [void][System.Management.Automation.Language.Parser]::ParseFile($fullPath, [ref]$tokens, [ref]$errors)
  foreach ($error in $errors) {
    Add-Failure("$RelativePath has a PowerShell parse error: $($error.Message)")
  }
}

$requiredFiles = @(
  ".github/workflows/repo-qa.yml",
  ".gitignore",
  "LICENSE",
  "README.md",
  "README.ja.md",
  "CONTRIBUTING.md",
  "CONTRIBUTING.ja.md",
  "SKILL.md",
  "agents/openai.yaml",
  "assets/logo.svg",
  "assets/hero.svg",
  "fixtures/release-gate-fixture/README.md",
  "fixtures/release-gate-fixture/docs/guide/overview.md",
  "fixtures/release-gate-fixture/docs/guide/release-notes-v9.9.9.md",
  "fixtures/release-gate-fixture/docs/guide/whats-new-v9.9.9.md",
  "fixtures/release-gate-fixture/tmp/release-qa-v9.9.9.md",
  "references/release-note-checklist.md",
  "references/release-note-outline.md",
  "references/release-qa-inventory-template.md",
  "references/release-note-template.md",
  "scripts/collect-release-context.ps1",
  "scripts/verify-release-qa-inventory.ps1",
  "scripts/verify-repo-surfaces.ps1"
)

$markdownFiles = @(
  "README.md",
  "README.ja.md",
  "CONTRIBUTING.md",
  "CONTRIBUTING.ja.md",
  "SKILL.md",
  "fixtures/release-gate-fixture/README.md",
  "fixtures/release-gate-fixture/docs/guide/overview.md",
  "fixtures/release-gate-fixture/docs/guide/release-notes-v9.9.9.md",
  "fixtures/release-gate-fixture/docs/guide/whats-new-v9.9.9.md",
  "fixtures/release-gate-fixture/tmp/release-qa-v9.9.9.md",
  "references/release-note-checklist.md",
  "references/release-note-outline.md",
  "references/release-qa-inventory-template.md",
  "references/release-note-template.md"
)

$powerShellFiles = @(
  "scripts/collect-release-context.ps1",
  "scripts/verify-release-qa-inventory.ps1",
  "scripts/verify-repo-surfaces.ps1"
)

foreach ($file in $requiredFiles) {
  Test-RequiredFile $file
}

foreach ($file in $markdownFiles) {
  Test-MarkdownLinks $file
}

foreach ($file in $powerShellFiles) {
  Test-PowerShellSyntax $file
}

Test-RequiredText "README.md" @("./README.ja.md", "./SKILL.md", "./CONTRIBUTING.md", "./LICENSE")
Test-RequiredText "README.ja.md" @("./README.md", "./SKILL.md", "./CONTRIBUTING.ja.md", "./LICENSE")
Test-RequiredText "SKILL.md" @("./scripts/collect-release-context.ps1", "./scripts/verify-release-qa-inventory.ps1", "./references/release-note-checklist.md", "./references/release-qa-inventory-template.md", "./references/release-note-template.md")
Test-RequiredText "agents/openai.yaml" @("GitHub Release Notes", "gh-release-notes")
Test-RequiredText ".github/workflows/repo-qa.yml" @("verify-repo-surfaces.ps1", "verify-release-qa-inventory.ps1")

if ($failures.Count -gt 0) {
  foreach ($failure in $failures) {
    Write-Error $failure
  }

  throw "Repository surface validation failed with $($failures.Count) issue(s)."
}

Write-Output "Repository surfaces look consistent."
Write-Output "Checked Markdown files: $($markdownFiles.Count)"
Write-Output "Checked PowerShell files: $($powerShellFiles.Count)"
