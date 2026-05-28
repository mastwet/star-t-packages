# Build .star package for Eclipse Temurin JDK
param(
    [Parameter(Mandatory)]
    [string]$Version,
    [string]$OutputDir = "dist"
)

$ErrorActionPreference = "Stop"

$serviceDir = $PSScriptRoot
$meta = Get-Content "$serviceDir/meta.json" -Raw | ConvertFrom-Json
$downloadUrl = $meta.downloadUrl
$packageName = "$($meta.id)-$Version-win-x64.star"
$tempDir = "$serviceDir/_temp"

Write-Host "=== Building $packageName ==="

# Clean
if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
if (-not (Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null }

# Download (Adoptium API returns the binary directly)
$zipPath = "$tempDir/jdk.zip"
Write-Host "Downloading from Adoptium API..."
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath -UseBasicParsing

# Extract
Write-Host "Extracting..."
Expand-Archive -Path $zipPath -DestinationPath $tempDir -Force

# Find extracted JDK directory
$jdkDir = Get-ChildItem $tempDir -Directory | Where-Object { $_.Name -like "jdk*" } | Select-Object -First 1
if (-not $jdkDir) {
    Write-Error "Could not find extracted JDK directory"
    exit 1
}

# Package
$pkgDir = "$tempDir/pkg"
New-Item -ItemType Directory -Path $pkgDir -Force | Out-Null

Write-Host "Assembling package..."
# JDK files go into bin/ per .star convention
Copy-Item -Path "$($jdkDir.FullName)\*" -Destination $pkgDir -Recurse -Force

# Write meta.json
$meta.version = $Version
$meta | ConvertTo-Json -Depth 10 | Set-Content "$pkgDir\meta.json" -Encoding UTF8

# Create .star archive
Write-Host "Packing $packageName..."
$starPath = "$OutputDir/$packageName"
if (Test-Path $starPath) { Remove-Item $starPath -Force }
Compress-Archive -Path "$pkgDir\*" -DestinationPath $starPath -Force

$size = [math]::Round((Get-Item $starPath).Length / 1MB, 1)
Write-Host "Done: $starPath ($size MB)"

# Cleanup
Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
