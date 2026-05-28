# Build .star package for RabbitMQ (with bundled Erlang)
param(
    [string]$Version = "4.1.3",
    [string]$OutputDir = "dist"
)

$ErrorActionPreference = "Stop"

$serviceDir = $PSScriptRoot
$meta = Get-Content "$serviceDir/meta.json" -Raw | ConvertFrom-Json
$downloadUrl = $meta.downloadUrl -replace $meta.version, $Version
$erlangUrl = $meta.erlang.downloadUrl
$erlangVersion = $meta.erlang.version
$packageName = "rabbitmq-$Version-win-x64.star"
$tempDir = "$serviceDir/_temp"

Write-Host "=== Building $packageName ==="
Write-Host "  Erlang OTP $erlangVersion (bundled)"
Write-Host "  RabbitMQ $Version"

if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
if (-not (Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null }
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

# === Step 1: Download and extract Erlang ===
Write-Host ""
Write-Host "--- Step 1: Erlang OTP ---"
$erlangExe = "$tempDir/erlang.exe"
Write-Host "Downloading Erlang installer..."
Invoke-WebRequest -Uri $erlangUrl -OutFile $erlangExe -UseBasicParsing

# Erlang NSIS installer can be extracted with 7-Zip
# Check if 7z is available
$7z = $null
if (Get-Command "7z" -ErrorAction SilentlyContinue) {
    $7z = "7z"
} elseif (Get-Command "7z.exe" -ErrorAction SilentlyContinue) {
    $7z = "7z.exe"
} elseif (Test-Path "C:\Program Files\7-Zip\7z.exe") {
    $7z = "C:\Program Files\7-Zip\7z.exe"
} elseif (Test-Path "C:\Program Files (x86)\7-Zip\7z.exe") {
    $7z = "C:\Program Files (x86)\7-Zip\7z.exe"
}

if (-not $7z) {
    Write-Error @"
7-Zip not found. Required to extract Erlang NSIS installer.
Install 7-Zip or add it to PATH.
  winget install 7zip.7zip
"@
    exit 1
}

$erlangDir = "$tempDir/erlang"
New-Item -ItemType Directory -Path $erlangDir -Force | Out-Null
Write-Host "Extracting Erlang with 7-Zip..."
& $7z x $erlangExe -o"$erlangDir" -y | Out-Null

# Delete erl.ini — this makes Erlang portable (confirmed by core dev @garazdawi)
$erlIni = Get-ChildItem $erlangDir -Recurse -Filter "erl.ini" -ErrorAction SilentlyContinue
foreach ($ini in $erlIni) {
    Write-Host "Deleting $($ini.FullName) (portability fix)"
    Remove-Item $ini.FullName -Force
}

Write-Host "Erlang extracted to $erlangDir"

# === Step 2: Download and extract RabbitMQ ===
Write-Host ""
Write-Host "--- Step 2: RabbitMQ Server ---"
$rabbitZip = "$tempDir/rabbitmq.zip"
Write-Host "Downloading: $downloadUrl"
Invoke-WebRequest -Uri $downloadUrl -OutFile $rabbitZip -UseBasicParsing

Write-Host "Extracting RabbitMQ..."
Expand-Archive -Path $rabbitZip -DestinationPath $tempDir -Force

$rabbitDir = Get-ChildItem $tempDir -Directory | Where-Object { $_.Name -like "rabbitmq_server-*" } | Select-Object -First 1
if (-not $rabbitDir) {
    Write-Error "Could not find extracted RabbitMQ directory"
    exit 1
}
Write-Host "RabbitMQ extracted to $($rabbitDir.FullName)"

# === Step 3: Assemble .star package ===
Write-Host ""
Write-Host "--- Step 3: Assembling package ---"
$pkgDir = "$tempDir/pkg"
New-Item -ItemType Directory -Path $pkgDir -Force | Out-Null

# Erlang goes into erlang/
Write-Host "Copying Erlang..."
Copy-Item -Path $erlangDir -Destination "$pkgDir\erlang" -Recurse -Force

# RabbitMQ goes into rabbitmq/
Write-Host "Copying RabbitMQ..."
Copy-Item -Path "$($rabbitDir.FullName)" -Destination "$pkgDir\rabbitmq" -Recurse -Force

# Config templates
New-Item -ItemType Directory -Path "$pkgDir\conf" -Force | Out-Null
Copy-Item -Path "$serviceDir\conf\*" -Destination "$pkgDir\conf" -Force

# Scripts
New-Item -ItemType Directory -Path "$pkgDir\scripts" -Force | Out-Null
Copy-Item -Path "$serviceDir\scripts\*" -Destination "$pkgDir\scripts" -Force

# meta.json
$meta.version = $Version
$meta | ConvertTo-Json -Depth 10 | Set-Content "$pkgDir\meta.json" -Encoding UTF8

# === Step 4: Pack ===
Write-Host ""
Write-Host "--- Step 4: Creating archive ---"
$starPath = "$OutputDir/$packageName"
if (Test-Path $starPath) { Remove-Item $starPath -Force }
Compress-Archive -Path "$pkgDir\*" -DestinationPath $starPath -Force

$size = [math]::Round((Get-Item $starPath).Length / 1MB, 1)
Write-Host ""
Write-Host "Done: $starPath ($size MB)"

Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
