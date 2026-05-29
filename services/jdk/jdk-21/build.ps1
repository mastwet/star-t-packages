# Build .star package for Eclipse Temurin JDK
param(
    [Parameter(Mandatory)]
    [string]$Version,
    [string]$OutputDir = "dist"
)

$ErrorActionPreference = "Stop"
$ProgressPreference = 'SilentlyContinue'

$serviceDir = $PSScriptRoot
$meta = Get-Content "$serviceDir/meta.json" -Raw -Encoding UTF8 | ConvertFrom-Json
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
    # Download with retry
    $maxRetries = 3
    for ($attempt = 1; $attempt -le $maxRetries; $attempt++) {
        try {
            Write-Host "Download attempt $attempt/$maxRetries..."
            Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath -UseBasicParsing -TimeoutSec 300
            break
        } catch {
            if ($attempt -eq $maxRetries) { throw }
            Write-Host "Download failed, retrying in $($attempt * 10) seconds..."
            Start-Sleep -Seconds ($attempt * 10)
        }
    }

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
$zipTemp = [System.IO.Path]::ChangeExtension($starPath, '.zip')
if (Test-Path $zipTemp) { Remove-Item $zipTemp -Force }
if (Test-Path $starPath) { Remove-Item $starPath -Force }
Compress-Archive -Path "$pkgDir\*" -DestinationPath $zipTemp -Force
Move-Item -Path $zipTemp -Destination $starPath -Force

$size = [math]::Round((Get-Item $starPath).Length / 1MB, 1)
Write-Host "Done: $starPath ($size MB)"

# Cleanup
Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
