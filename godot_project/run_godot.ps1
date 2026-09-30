# IL GRANDE MERIDIANO - Godot 4 One-Click Launcher
# Automatically detects or downloads the portable Godot 4.3 64-bit engine and launches the project.

$ErrorActionPreference = "Stop"
$projectDir = $PSScriptRoot

# 1. Search for existing Godot executable
$godotExe = Get-Command "godot" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
if (-not $godotExe) {
    $localExe = Get-ChildItem -Path $projectDir -Filter "*godot*.exe" -File -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($localExe) {
        $godotExe = $localExe.FullName
    }
}

# 2. Download portable Godot 4.3 if not present
if (-not $godotExe) {
    Write-Host "==========================================================" -ForegroundColor Cyan
    Write-Host "IL GRANDE MERIDIANO - DOWNLOAD MOTORE GRAFICO GODOT 4.3" -ForegroundColor Yellow
    Write-Host "==========================================================" -ForegroundColor Cyan
    Write-Host "Download in corso del binario portatile ufficiale (110 MB)..." -ForegroundColor White

    $godotUrl = "https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_win64.exe.zip"
    $zipPath = Join-Path $projectDir "godot_v4.3.zip"

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $godotUrl -OutFile $zipPath -UseBasicParsing

    Write-Host "Estrazione archivio portatile..." -ForegroundColor White
    Expand-Archive -Path $zipPath -DestinationPath $projectDir -Force
    Remove-Item $zipPath -Force

    $localExe = Get-ChildItem -Path $projectDir -Filter "*godot*.exe" -File | Select-Object -First 1
    $godotExe = $localExe.FullName
    Write-Host "Motore Godot 4.3 pronto: $godotExe" -ForegroundColor Green
}

# 3. Launch the game project
Write-Host "Avvio de IL GRANDE MERIDIANO su motore Godot 4 (Vulkan)..." -ForegroundColor Green
Set-Location $projectDir
Start-Process -FilePath $godotExe -ArgumentList "--path `"$projectDir`""
