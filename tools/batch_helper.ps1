# GAME-004 batch download + review helper
# Reads batch_v2_manifest.json, prints download commands for completed items
param(
    [string]$ManifestPath = "D:\deepseek\yunxiaoxing-game004\assets\candidates\banana\batch_v2_manifest.json",
    [string]$OutputDir = "D:\deepseek\yunxiaoxing-game004\assets\candidates\banana\single"
)
$ErrorActionPreference = 'Stop'
$manifest = Get-Content -Raw $ManifestPath -Encoding UTF8 | ConvertFrom-Json
Write-Host "BATCH_MANIFEST items=$($manifest.items.Count)"
foreach ($item in $manifest.items) {
    Write-Host "label=$($item.label) pred=$($item.prediction_id) status=$($item.status)"
}
