@echo off
title IL GRANDE MERIDIANO - Avvio Godot 4.3 Vulkan
cd /d "%~dp0"
echo ========================================================
echo IL GRANDE MERIDIANO - Avvio Progetto Godot 4 (Vulkan)
echo ========================================================
echo Cartella progetto: %~dp0godot_project
echo.
start "" "%~dp0godot_project\Godot_v4.3-stable_win64.exe" --path "%~dp0godot_project"
