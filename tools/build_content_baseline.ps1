param(
  [string]$Source = (Join-Path (Split-Path -Parent $PSScriptRoot) 'baseline\authoritative_sources\GAME004_20_PACKS_SOURCE_V1.md'),
  [string]$Output = (Join-Path (Split-Path -Parent $PSScriptRoot) 'baseline\game004_content_baseline.json')
)
$ErrorActionPreference='Stop'
$lines=Get-Content -LiteralPath $Source -Encoding UTF8
$level=''; $pack=$null; $packs=@()
foreach($line in $lines){
  if($line -match '^## (L[1-5])\s*$'){ $level=$Matches[1]; continue }
  if($line -match '^### (GF03-L[1-5]-P\d{2})\s+(.+?)\s*$'){
    if($pack){$packs += $pack}
    $pack=[ordered]@{game_pack_id=$Matches[1];title=$Matches[2].Trim();l_level=$level;game_id='GAME-004';game_family_id='GF-03';primary_training_unit_id='TU-011';fixed_opportunity_count=6;opportunities=@()}
    continue
  }
  if($pack -and $line -match '^(\d+)\.\s+(.+?)\s*$'){
    $n=[int]$Matches[1]; $content=$Matches[2].Trim()
    $pack.opportunities += [ordered]@{opportunity_id=($pack.game_pack_id + '-R' + $n.ToString('00'));order=$n;frozen_content=$content}
  }
}
if($pack){$packs += $pack}
if($packs.Count -ne 20){throw "Expected 20 packs, got $($packs.Count)"}
foreach($p in $packs){if($p.opportunities.Count -ne 6){throw "$($p.game_pack_id) expected 6 opportunities, got $($p.opportunities.Count)"}}
$root=[ordered]@{schema_version='game004-content-baseline-v1';baseline_version='GAME004-BASELINE-V1';source_file=$Source;source_sha256=(Get-FileHash -Algorithm SHA256 -LiteralPath $Source).Hash;game_id='GAME-004';game_family_id='GF-03';primary_training_unit_id='TU-011';pack_count=20;opportunity_count=120;packs=$packs}
New-Item -ItemType Directory -Force (Split-Path -Parent $Output) | Out-Null
$root | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $Output -Encoding UTF8
Write-Host "CONTENT_BASELINE_BUILD_PASS packs=$($packs.Count) opportunities=$((($packs|ForEach-Object {$_.opportunities.Count})|Measure-Object -Sum).Sum)"
