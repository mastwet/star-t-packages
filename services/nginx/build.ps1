# Build .star package for Nginx
param(
    [string]$Version = "1.27.5",
    [string]$OutputDir = "dist"
)

$ErrorActionPreference = "Stop"

$serviceDir = $PSScriptRoot
$meta = Get-Content "$serviceDir/meta.json" -Raw -Encoding UTF8 | ConvertFrom-Json
$downloadUrl = $meta.downloadUrl -replace $meta.version, $Version
$packageName = "nginx-$Version-win-x64.star"
$tempDir = "$serviceDir/_temp"

Write-Host "=== Building $packageName ==="

if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
if (-not (Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null }

# Download
$zipPath = "$tempDir/nginx.zip"
Write-Host "Downloading: $downloadUrl"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath -UseBasicParsing

# Extract
Write-Host "Extracting..."
Expand-Archive -Path $zipPath -DestinationPath $tempDir -Force

$extractedDir = Get-ChildItem $tempDir -Directory | Where-Object { $_.Name -like "nginx*" } | Select-Object -First 1
if (-not $extractedDir) {
    Write-Error "Could not find extracted Nginx directory"
    exit 1
}

# Package
$pkgDir = "$tempDir/pkg"
New-Item -ItemType Directory -Path $pkgDir -Force | Out-Null

Write-Host "Assembling package..."
Copy-Item -Path "$($extractedDir.FullName)\*" -Destination $pkgDir -Recurse -Force

# Copy config templates (overwrite default nginx.conf)
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
$zipTemp = [System.IO.Path]::ChangeExtension($starPath, '.zip')
if (Test-Path $zipTemp) { Remove-Item $zipTemp -Force }
if (Test-Path $starPath) { Remove-Item $starPath -Force }
Compress-Archive -Path "$pkgDir\*" -DestinationPath $zipTemp -Force
Move-Item -Path $zipTemp -Destination $starPath -Force

$size = [math]::Round((Get-Item $starPath).Length / 1MB, 1)
Write-Host "Done: $starPath ($size MB)"

Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
