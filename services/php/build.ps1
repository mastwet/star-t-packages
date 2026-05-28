# Build .star package for PHP
param(
    [string]$Version = "8.3.21",
    [string]$OutputDir = "dist",
    [switch]$Nts
)

$ErrorActionPreference = "Stop"

$serviceDir = $PSScriptRoot
$meta = Get-Content "$serviceDir/meta.json" -Raw | ConvertFrom-Json

# Determine URL: Thread Safe (default for Apache/Nginx FastCGI) or NTS
if ($Nts) {
    $downloadUrl = $meta.downloadUrlNts
    $suffix = "-nts"
} else {
    $downloadUrl = $meta.downloadUrl
    $suffix = ""
}

# Replace version in URL
$downloadUrl = $downloadUrl -replace $meta.version, $Version
$packageName = "php-$Version$suffix-win-x64.star"
$tempDir = "$serviceDir/_temp"

Write-Host "=== Building $packageName ==="

if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
if (-not (Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null }

# Download
$zipPath = "$tempDir/php.zip"
Write-Host "Downloading: $downloadUrl"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath -UseBasicParsing

# Extract
Write-Host "Extracting..."
Expand-Archive -Path $zipPath -DestinationPath "$tempDir/php" -Force

# Package
$pkgDir = "$tempDir/pkg"
New-Item -ItemType Directory -Path $pkgDir -Force | Out-Null
New-Item -ItemType Directory -Path "$pkgDir\bin" -Force | Out-Null

Write-Host "Assembling package..."
Copy-Item -Path "$tempDir\php\*" -Destination "$pkgDir\bin" -Recurse -Force

# Copy config templates
New-Item -ItemType Directory -Path "$pkgDir\conf" -Force | Out-Null
Copy-Item -Path "$serviceDir\conf\*" -Destination "$pkgDir\conf" -Force

# Copy scripts
New-Item -ItemType Directory -Path "$pkgDir\scripts" -Force | Out-Null
Copy-Item -Path "$serviceDir\scripts\*" -Destination "$pkgDir\scripts" -Force

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

Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
