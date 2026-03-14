param(
  [string]$Tag,
  [string]$Target = "HEAD",
  [string]$BaseTag
)

$ErrorActionPreference = "Stop"

function Invoke-Git {
  param([string[]]$GitArgs)

  $output = & git @GitArgs 2>&1
  if ($LASTEXITCODE -ne 0) {
    throw "git $($GitArgs -join ' ') failed`n$output"
  }

  if ($output -is [System.Array]) {
    return ($output -join "`n").TrimEnd()
  }

  if ($null -eq $output) {
    return ""
  }

  return ([string]$output).TrimEnd()
}

function Try-Git {
  param([string[]]$GitArgs)

  $previousErrorActionPreference = $ErrorActionPreference
  $ErrorActionPreference = "Continue"
  try {
    $output = & git @GitArgs 2>$null
  } finally {
    $ErrorActionPreference = $previousErrorActionPreference
  }

  if ($LASTEXITCODE -ne 0) {
    return $null
  }

  if ($null -eq $output) {
    return $null
  }

  if ($output -is [System.Array]) {
    return ($output -join "`n").TrimEnd()
  }

  return ([string]$output).TrimEnd()
}

function Resolve-Commitish {
  param([string]$RefName)

  if (-not $RefName) {
    return $null
  }

  return Try-Git @("rev-parse", "$RefName^{commit}")
}

function First-Line {
  param([string]$Text)

  if (-not $Text) {
    return $null
  }

  $lines = @($Text -split "`r?`n" | Where-Object { $_ })
  if ($lines.Count -eq 0) {
    return $null
  }

  return $lines[0]
}

$repoRoot = Invoke-Git @("rev-parse", "--show-toplevel")
$originUrl = Try-Git @("remote", "get-url", "origin")
$targetRef = if ($Tag) { $Tag } else { $Target }
$targetCommit = Resolve-Commitish $targetRef
if (-not $targetCommit) {
  throw "Unable to resolve '$targetRef' locally. Fetch tags first or pass -Target <commit-or-branch>."
}

$rootCommit = First-Line (Invoke-Git @("rev-list", "--max-parents=0", $targetCommit))

$allTagsText = Try-Git @("tag", "--sort=creatordate")
$allTags = @()
if ($allTagsText) {
  $allTags = $allTagsText -split "`r?`n" | Where-Object { $_ }
}

if (-not $BaseTag) {
  if ($Tag -and ($allTags -contains $Tag)) {
    $tagIndex = [Array]::IndexOf($allTags, $Tag)
    if ($tagIndex -gt 0) {
      $BaseTag = $allTags[$tagIndex - 1]
    }
  } elseif ($allTags.Count -gt 0) {
    $BaseTag = First-Line (Try-Git @("describe", "--tags", "--abbrev=0", "$targetCommit^"))
  }
}

$emptyTree = "4b825dc642cb6eb9a060e54bf8d69288fbee4904"
$baseCommit = if ($BaseTag) { Resolve-Commitish $BaseTag } else { $null }

if ($BaseTag -and -not $baseCommit) {
  throw "Unable to resolve base tag '$BaseTag' locally."
}

if ($BaseTag) {
  $logRange = $BaseTag + ".." + $targetCommit
  $compareRange = $BaseTag + ".." + $targetRef
  $diffArgs = @("diff", "--stat", "--summary", "--find-renames", $BaseTag, $targetCommit)
  $changedArgs = @("diff", "--name-only", "--find-renames", $BaseTag, $targetCommit)
} else {
  $logRange = $targetCommit
  $compareRange = "<none>; initial release mode"
  $diffArgs = @("diff", "--stat", "--summary", "--find-renames", $emptyTree, $targetCommit)
  $changedArgs = @("diff", "--name-only", "--find-renames", $emptyTree, $targetCommit)
}

$releaseExists = "not checked"
$releaseUrl = ""
if ($Tag) {
  $ghCommand = Get-Command gh -ErrorAction SilentlyContinue
  if (-not $originUrl) {
    $releaseExists = "no remote"
  } elseif ($ghCommand) {
    & gh release view $Tag *> $null
    if ($LASTEXITCODE -eq 0) {
      $releaseExists = "true"
      $releaseJson = & gh release view $Tag --json url 2>$null
      if ($LASTEXITCODE -eq 0 -and $releaseJson) {
        $releaseUrl = (ConvertFrom-Json $releaseJson).url
      }
    } else {
      $releaseExists = "false"
    }
  } else {
    $releaseExists = "gh unavailable"
  }
}

Write-Output "[release-context] repo: $repoRoot"
if ($originUrl) {
  Write-Output "[release-context] origin: $originUrl"
}
Write-Output "[release-context] target: $targetRef ($targetCommit)"
if ($BaseTag) {
  Write-Output "[release-context] base tag: $BaseTag"
} else {
  Write-Output "[release-context] base tag: <none>; initial release mode"
}
Write-Output "[release-context] compare range: $compareRange"
Write-Output "[release-context] root commit: $rootCommit"
Write-Output "[release-context] gh release exists: $releaseExists"
if ($releaseUrl) {
  Write-Output "[release-context] gh release url: $releaseUrl"
}
Write-Output ""

Write-Output "=== Changed Files ==="
$changedFiles = Invoke-Git $changedArgs
if ($changedFiles) {
  Write-Output $changedFiles
} else {
  Write-Output "<none>"
}
Write-Output ""

Write-Output "=== Diff Stat ==="
$diffStat = Invoke-Git $diffArgs
if ($diffStat) {
  Write-Output $diffStat
} else {
  Write-Output "<none>"
}
Write-Output ""

Write-Output "=== Commit Log With Stats ==="
$logOutput = Invoke-Git @("log", "--reverse", "--stat", "--format=commit %H%n%s", $logRange)
if ($logOutput) {
  Write-Output $logOutput
} else {
  Write-Output "<none>"
}
