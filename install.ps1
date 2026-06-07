#Requires -Version 5.1
<#
.SYNOPSIS
    Clone (or update) msbuild-props and deploy MSBuild user props to
    %LOCALAPPDATA%\Microsoft\MSBuild\v4.0\
#>

$ErrorActionPreference = 'Stop'

$repoUrl   = 'https://github.com/terry-chao/msbuild-props.git'
$targetDir = Join-Path $env:LOCALAPPDATA 'Microsoft\MSBuild\v4.0'
$tempDir   = Join-Path $env:TEMP 'msbuild-props'

# ── 1. Clone / pull ──────────────────────────────────────────────────────────
if (Test-Path (Join-Path $tempDir '.git')) {
    Write-Host "Updating existing clone at $tempDir ..."
    git -C $tempDir pull --ff-only
} else {
    Write-Host "Cloning $repoUrl to $tempDir ..."
    if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
    git clone --depth 1 $repoUrl $tempDir
}

# ── 2. Copy props files ───────────────────────────────────────────────────────
$sourceDir = Join-Path $tempDir 'MSBuild\v4.0'

if (-not (Test-Path $sourceDir)) {
    Write-Warning "Source directory not found in clone, falling back to local script directory ..."
    $sourceDir = Join-Path $PSScriptRoot 'MSBuild\v4.0'
}

if (-not (Test-Path $sourceDir)) {
    Write-Error "Source directory not found: $sourceDir"
    exit 1
}

if (-not (Test-Path $targetDir)) {
    Write-Host "Creating $targetDir ..."
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
}

Write-Host "Copying props files to $targetDir ..."
Get-ChildItem -Path $sourceDir -Filter '*.props' | ForEach-Object {
    Copy-Item -Path $_.FullName -Destination $targetDir -Force
    Write-Host "  Copied: $($_.Name)"
}

Write-Host "`nDone. Props installed to:`n  $targetDir"
