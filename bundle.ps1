# Bundler script to create zero-dependency bundle.js
$srcOrder = @(
    "src/config.js",
    "src/engine/TextureGenerator.js",
    "src/engine/WebAudioEngine.js",
    "src/engine/Renderer.js",
    "src/engine/CameraController.js",
    "src/engine/TouchInput.js",
    "src/world/BiomeManager.js",
    "src/world/RoadGenerator.js",
    "src/world/ScenerySpawner.js",
    "src/world/POIManager.js",
    "src/world/LandscapeManager.js",
    "src/entities/Vehicle.js",
    "src/entities/PlayerCharacter.js",
    "src/entities/Hazards.js",
    "src/systems/SurvivalState.js",
    "src/systems/InventorySystem.js",
    "src/systems/WeatherDirector.js",
    "src/systems/UpgradeSystem.js",
    "src/systems/MalfunctionManager.js",
    "src/systems/StoryDirector.js",
    "src/ui/DashboardHUD.js",
    "src/ui/InventoryModal.js",
    "src/ui/ScavengeModal.js",
    "src/ui/UpgradeModal.js",
    "src/ui/MeridianAtlasModal.js",
    "src/ui/StoryDiaryModal.js",
    "src/main.js"
)

$bundle = "(function() {`n'use strict';`n`n"

foreach ($file in $srcOrder) {
    $content = Get-Content $file -Raw -Encoding UTF8
    # Strip import statements
    $content = [System.Text.RegularExpressions.Regex]::Replace($content, "(?m)^import\s+.*?;\s*`r?`n?", "")
    # Strip export keyword while preserving const/class/function/let/var
    $content = [System.Text.RegularExpressions.Regex]::Replace($content, '(?m)^export\s+(const|class|function|let|var)\s+', '$1 ')
    # Strip export default or named export blocks
    $content = [System.Text.RegularExpressions.Regex]::Replace($content, "(?m)^export\s*\{.*?\};?\s*`r?`n?", "")
    
    $bundle += "// --- FILE: $file ---`n" + $content + "`n`n"
}

$bundle += "})();`n"

Set-Content -Path "bundle.js" -Value $bundle -Encoding UTF8
Write-Host "Bundle created successfully with length: $($bundle.Length)"
