param(
  [string]$Path,
  [string]$RepoPath,
  [string]$Tag
)

$ErrorActionPreference = "Stop"

$allowedStatuses = @(
  "pass",
  "not_applicable",
  "user_waived",
  "fail",
  "blocked"
)

$requiredCriteria = @(
  "compare_range",
  "release_claims_backed",
  "docs_release_notes",
  "companion_walkthrough",
  "operator_claims_extracted",
  "impl_sensitive_claims_verified",
  "steady_state_docs_reviewed",
  "claim_scope_precise",
  "latest_release_links_updated",
  "docs_assets_committed_before_tag",
  "docs_deployed_live",
  "tag_local_remote",
  "github_release_verified",
  "validation_commands_recorded",
  "publish_date_verified"
)

$blockingStatuses = @("fail", "blocked")
$failures = [System.Collections.Generic.List[string]]::new()

function Add-Failure {
  param([string]$Message)

  $script:failures.Add($Message) | Out-Null
}

function Normalize-CellText {
  param([string]$Value)

  return ($Value -replace '`', '').Trim()
}

function Get-ListItemsFromCell {
  param([string]$Value)

  return (Normalize-CellText $Value).Split(",") | ForEach-Object { $_.Trim() } | Where-Object { $_ }
}

function Get-SectionContent {
  param(
    [string[]]$Lines,
    [string]$Header
  )

  $startIndex = -1
  for ($i = 0; $i -lt $Lines.Count; $i++) {
    if ($Lines[$i].Trim() -eq $Header) {
      $startIndex = $i + 1
      break
    }
  }

  if ($startIndex -lt 0) {
    Add-Failure("Missing required section: $Header")
    return @()
  }

  $sectionLines = [System.Collections.Generic.List[string]]::new()
  for ($i = $startIndex; $i -lt $Lines.Count; $i++) {
    $line = $Lines[$i]
    if ($line -match '^##\s+' -and $line.Trim() -ne $Header) {
      break
    }

    $sectionLines.Add($line) | Out-Null
  }

  return $sectionLines.ToArray()
}

function Get-MarkdownTableRows {
  param([string[]]$SectionLines)

  $rows = [System.Collections.Generic.List[object]]::new()
  foreach ($line in $SectionLines) {
    $trimmed = $line.Trim()
    if (-not $trimmed.StartsWith("|")) {
      continue
    }

    $cells = $trimmed.Trim("|").Split("|") | ForEach-Object { $_.Trim() }
    if ($cells.Count -lt 3) {
      continue
    }

    if ($cells[0] -match '^-+$') {
      continue
    }

    if ($cells -contains "---") {
      continue
    }

    $rows.Add($cells) | Out-Null
  }

  if ($rows.Count -gt 0) {
    $rows.RemoveAt(0)
  }

  return $rows.ToArray()
}

if ([string]::IsNullOrWhiteSpace($Path)) {
  if ([string]::IsNullOrWhiteSpace($RepoPath) -or [string]::IsNullOrWhiteSpace($Tag)) {
    throw "Specify -Path, or provide both -RepoPath and -Tag so the validator can resolve tmp/release-qa-<tag>.md."
  }

  $resolvedRepoRoot = (Resolve-Path -LiteralPath $RepoPath).Path
  $Path = Join-Path $resolvedRepoRoot ("tmp/release-qa-{0}.md" -f $Tag)
}

if (-not (Test-Path -LiteralPath $Path)) {
  throw "QA inventory file not found: $Path"
}

$fullPath = (Resolve-Path -LiteralPath $Path).Path
$resolvedInventoryPath = [System.IO.Path]::GetFullPath($fullPath)
$content = Get-Content -LiteralPath $fullPath
$rawContent = Get-Content -Raw -LiteralPath $fullPath

$repoRoot = $null
if (-not [string]::IsNullOrWhiteSpace($RepoPath)) {
  $repoRoot = (Resolve-Path -LiteralPath $RepoPath).Path
  $normalizedRepoRoot = [System.IO.Path]::GetFullPath($repoRoot)
  if (-not $resolvedInventoryPath.StartsWith($normalizedRepoRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
    Add-Failure("QA inventory file must live inside the target repository when -RepoPath is provided.")
  }
}

$claimMatrixRows = Get-MarkdownTableRows -SectionLines (Get-SectionContent -Lines $content -Header "## Claim Matrix")
$docsReviewRows = Get-MarkdownTableRows -SectionLines (Get-SectionContent -Lines $content -Header "## Steady-State Docs Review")
$qaRows = Get-MarkdownTableRows -SectionLines (Get-SectionContent -Lines $content -Header "## QA Inventory")

if ($claimMatrixRows.Count -lt 1) {
  Add-Failure("Claim Matrix must contain at least one data row.")
}

if ($docsReviewRows.Count -lt 1) {
  Add-Failure("Steady-State Docs Review must contain at least one data row.")
}

if ($qaRows.Count -lt 1) {
  Add-Failure("QA Inventory must contain data rows.")
}

$criteriaMap = @{}
foreach ($row in $qaRows) {
  $criterionId = $row[0]
  $status = $row[1].ToLowerInvariant()
  $evidence = $row[2]

  if ([string]::IsNullOrWhiteSpace($criterionId)) {
    Add-Failure("QA Inventory contains a row with an empty criterion_id.")
    continue
  }

  if ($criteriaMap.ContainsKey($criterionId)) {
    Add-Failure("QA Inventory contains a duplicate criterion_id: $criterionId")
    continue
  }

  if ($allowedStatuses -notcontains $status) {
    Add-Failure("QA Inventory row '$criterionId' has invalid status '$status'.")
  }

  if ([string]::IsNullOrWhiteSpace($evidence)) {
    Add-Failure("QA Inventory row '$criterionId' must include evidence.")
  }

  if ($blockingStatuses -contains $status) {
    Add-Failure("QA Inventory row '$criterionId' is '$status', so the release task is not ready to close.")
  }

  $criteriaMap[$criterionId] = @{
    status = $status
    evidence = $evidence
  }
}

foreach ($criterion in $requiredCriteria) {
  if (-not $criteriaMap.ContainsKey($criterion)) {
    Add-Failure("QA Inventory is missing required criterion_id '$criterion'.")
  }
}

if ($repoRoot) {
  foreach ($criterionId in @("docs_release_notes", "companion_walkthrough")) {
    if ($criteriaMap.ContainsKey($criterionId) -and $criteriaMap[$criterionId].status -eq "pass") {
      $pathItems = Get-ListItemsFromCell $criteriaMap[$criterionId].evidence
      $existingPathFound = $false
      foreach ($item in $pathItems) {
        if ($item -match '(?i)\.md$') {
          $candidatePath = Join-Path $repoRoot $item
          if (Test-Path -LiteralPath $candidatePath) {
            $existingPathFound = $true
            break
          }
        }
      }

      if (-not $existingPathFound) {
        Add-Failure("QA Inventory criterion '$criterionId' is 'pass' but does not point at an existing docs page in the target repo.")
      }
    }
  }
}

$readmeReviewed = $false
$docsReviewSurfaceSet = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
foreach ($row in $docsReviewRows) {
  $surface = Normalize-CellText $row[0]
  $status = $row[1]
  $evidence = $row[2]

  if ([string]::IsNullOrWhiteSpace($surface) -or [string]::IsNullOrWhiteSpace($status) -or [string]::IsNullOrWhiteSpace($evidence)) {
    Add-Failure("Steady-State Docs Review rows must include surface, status, and evidence.")
  }

  [void]$docsReviewSurfaceSet.Add($surface)

  if ($surface -match '(?i)readme') {
    $readmeReviewed = $true
  }

  if ($repoRoot -and ($surface -match '(?i)\.md$' -or $surface -match '^(?i)README(\.[^\\\/]+)?$' -or $surface -match '[\\\/]')) {
    $candidatePath = Join-Path $repoRoot $surface
    if (-not (Test-Path -LiteralPath $candidatePath)) {
      Add-Failure("Steady-State Docs Review references a missing repo path: $surface")
    }
  }
}

if (-not $readmeReviewed) {
  Add-Failure("Steady-State Docs Review must include at least one README surface or an explicit README review row.")
}

if ($repoRoot) {
  $rootReadmePath = Join-Path $repoRoot "README.md"
  if ((Test-Path -LiteralPath $rootReadmePath) -and (-not $readmeReviewed)) {
    Add-Failure("Target repository has README.md, but the Steady-State Docs Review did not include a README row.")
  }
}

foreach ($row in $claimMatrixRows) {
  if ($row.Count -lt 4) {
    continue
  }

  $docsSurfaceItems = Get-ListItemsFromCell $row[3]
  foreach ($item in $docsSurfaceItems) {
    if ($item -eq "none" -or $item -eq "n/a") {
      continue
    }

    if (-not $docsReviewSurfaceSet.Contains($item)) {
      Add-Failure("Claim Matrix references docs surface '$item' that is missing from Steady-State Docs Review.")
    }
  }
}

if (-not [string]::IsNullOrWhiteSpace($Tag)) {
  $tagLine = [regex]::Match($rawContent, '(?im)^\s*-\s*release tag:\s*(.+)\s*$')
  if (-not $tagLine.Success) {
    Add-Failure("Release Context must include '- release tag:' when -Tag is provided.")
  }
  else {
    $recordedTag = (Normalize-CellText $tagLine.Groups[1].Value).Trim()
    if ([string]::IsNullOrWhiteSpace($recordedTag)) {
      Add-Failure("Release Context must record the release tag when -Tag is provided.")
    }
    elseif ($recordedTag -ne $Tag) {
      Add-Failure("Release Context tag '$recordedTag' does not match requested -Tag '$Tag'.")
    }
  }
}

if ($failures.Count -gt 0) {
  foreach ($failure in $failures) {
    Write-Error $failure
  }

  throw "QA inventory validation failed with $($failures.Count) issue(s)."
}

Write-Output "Release QA inventory looks ready."
Write-Output "Checked file: $fullPath"
Write-Output "Checked criteria: $($requiredCriteria.Count)"
