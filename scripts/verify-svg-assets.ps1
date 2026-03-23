param(
  [Parameter(Mandatory = $true)]
  [string[]]$Path,

  [string]$RepoPath = (Get-Location).Path
)

$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path -LiteralPath $RepoPath).Path
$failures = [System.Collections.Generic.List[string]]::new()
$checkedCount = 0

function Add-Failure {
  param([string]$Message)

  $script:failures.Add($Message) | Out-Null
}

function Resolve-CandidatePath {
  param([string]$InputPath)

  $candidate = if ([System.IO.Path]::IsPathRooted($InputPath)) {
    $InputPath
  } else {
    Join-Path $repoRoot $InputPath
  }

  if (-not (Test-Path -LiteralPath $candidate)) {
    Add-Failure("Missing SVG asset: $InputPath")
    return $null
  }

  return (Resolve-Path -LiteralPath $candidate).Path
}

function Test-SvgAsset {
  param(
    [string]$DisplayPath,
    [string]$FullPath
  )

  $rawContent = Get-Content -Raw -LiteralPath $FullPath
  if ([string]::IsNullOrWhiteSpace($rawContent)) {
    Add-Failure("$DisplayPath is empty.")
    return
  }

  $document = New-Object System.Xml.XmlDocument
  $document.XmlResolver = $null

  try {
    $document.LoadXml($rawContent)
  } catch {
    Add-Failure("$DisplayPath is not well-formed XML: $($_.Exception.Message)")
    return
  }

  $root = $document.DocumentElement
  if ($null -eq $root -or $root.LocalName -ne "svg") {
    Add-Failure("$DisplayPath does not have an <svg> root element.")
    return
  }

  $viewBox = $root.GetAttribute("viewBox")
  $width = $root.GetAttribute("width")
  $height = $root.GetAttribute("height")
  if ([string]::IsNullOrWhiteSpace($viewBox) -and ([string]::IsNullOrWhiteSpace($width) -or [string]::IsNullOrWhiteSpace($height))) {
    Add-Failure("$DisplayPath must define either viewBox or both width and height.")
  }

  $definedIds = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
  foreach ($node in $document.SelectNodes("//*[@id]")) {
    $idValue = $node.GetAttribute("id")
    if (-not [string]::IsNullOrWhiteSpace($idValue)) {
      [void]$definedIds.Add($idValue.Trim())
    }
  }

  $missingRefs = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
  $urlPattern = 'url\(\s*#([^)''"\s]+)\s*\)'

  foreach ($node in $document.SelectNodes("//*[@*]")) {
    foreach ($attribute in $node.Attributes) {
      $value = $attribute.Value

      foreach ($match in [regex]::Matches($value, $urlPattern)) {
        $targetId = $match.Groups[1].Value
        if (-not [string]::IsNullOrWhiteSpace($targetId) -and -not $definedIds.Contains($targetId)) {
          [void]$missingRefs.Add($targetId)
        }
      }

      $isHrefAttribute = $attribute.LocalName -eq "href" -or $attribute.Name -eq "xlink:href"
      if ($isHrefAttribute -and $value.StartsWith("#")) {
        $targetId = $value.Substring(1)
        if (-not [string]::IsNullOrWhiteSpace($targetId) -and -not $definedIds.Contains($targetId)) {
          [void]$missingRefs.Add($targetId)
        }
      }
    }
  }

  foreach ($styleNode in $document.SelectNodes("//*[local-name()='style']")) {
    foreach ($match in [regex]::Matches($styleNode.InnerText, $urlPattern)) {
      $targetId = $match.Groups[1].Value
      if (-not [string]::IsNullOrWhiteSpace($targetId) -and -not $definedIds.Contains($targetId)) {
        [void]$missingRefs.Add($targetId)
      }
    }
  }

  if ($missingRefs.Count -gt 0) {
    $missingList = ($missingRefs | Sort-Object) -join ", "
    Add-Failure("$DisplayPath references missing internal ids: $missingList")
  }

  $script:checkedCount += 1
}

$normalizedPaths = foreach ($item in $Path) {
  $item -split "," | ForEach-Object { $_.Trim() } | Where-Object { $_ }
}

foreach ($item in $normalizedPaths) {
  $resolvedPath = Resolve-CandidatePath -InputPath $item
  if ($null -eq $resolvedPath) {
    continue
  }

  Test-SvgAsset -DisplayPath $item -FullPath $resolvedPath
}

if ($failures.Count -gt 0) {
  foreach ($failure in $failures) {
    Write-Error $failure
  }

  throw "SVG validation failed with $($failures.Count) issue(s)."
}

Write-Output "SVG assets look valid."
Write-Output "Checked SVG files: $checkedCount"
