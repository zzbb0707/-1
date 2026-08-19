# GAME-004 grid batch auto-register
# After slicing a 3x3 grid into 9 PNGs, map them to labels and copy into approved_candidate
param(
    [string]$SlicedDir = "D:\deepseek\yunxiaoxing-game004\assets\candidates\banana\sliced",
    [string]$ApprovedDir = "D:\deepseek\yunxiaoxing-game004\assets\candidates\banana\approved_candidate",
    [string]$Labels = ""  # comma-separated 9 labels, e.g. "comb,book,cup,plate,towel,toothbrush,phone,remote,ball"
)
$ErrorActionPreference = 'Stop'
if (-not $Labels) { Write-Error "Labels required (9 comma-separated)"; exit 1 }
$labels = $Labels -split ',' | ForEach-Object { $_.Trim() }
if ($labels.Count -ne 9) { Write-Error "Need exactly 9 labels, got $($labels.Count)"; exit 1 }
New-Item -ItemType Directory -Force $ApprovedDir | Out-Null
$mapped = 0
for ($i = 0; $i -lt 9; $i++) {
    $src = Join-Path $SlicedDir ("slice_{0:D2}.png" -f ($i + 1))
    if (-not (Test-Path $src)) { Write-Warning "missing slice $($i+1)"; continue }
    $safe = ($labels[$i] -replace '[^\w\-]', '')
    $dst = Join-Path $ApprovedDir ("object_" + $safe + "_grid_v001.png")
    Copy-Item $src $dst -Force
    $mapped++
}
Write-Host "GRID_REGISTER_PASS mapped=$mapped"
