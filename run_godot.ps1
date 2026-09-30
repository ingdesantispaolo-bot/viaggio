# IL GRANDE MERIDIANO - Godot 4 One-Click Launcher (Root)
$ErrorActionPreference = "Stop"
$workspaceRoot = $PSScriptRoot
$projectDir = Join-Path $workspaceRoot "godot_project"

# Locate Godot 4.3 executable
$godotExe = Get-ChildItem -Path $projectDir -Filter "*godot*.exe" -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -notlike "*console*" } | Select-Object -First 1

if (-not $godotExe) {
    Write-Host "Motore Godot 4 non trovato localmente. Download in corso..." -ForegroundColor Cyan
    & (Join-Path $projectDir "run_godot.ps1")
} else {
    Write-Host "==========================================================" -ForegroundColor Cyan
    Write-Host "AVVIO IL GRANDE MERIDIANO - MOTORE GODOT 4.3 (VULKAN)" -ForegroundColor Yellow
    Write-Host "==========================================================" -ForegroundColor Cyan
    Write-Host "Eseguibile: $($godotExe.FullName)" -ForegroundColor Green
    Write-Host "Progetto:   $projectDir" -ForegroundColor Green
    Write-Host "Premi F11 in gioco per passare a Schermo Intero." -ForegroundColor White
    Start-Process -FilePath $godotExe.FullName -ArgumentList "--path `"$projectDir`""
}
