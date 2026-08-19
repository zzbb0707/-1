$ErrorActionPreference='Stop'
$root='D:\deepseek\yunxiaoxing-game004'
$dir=Join-Path $root 'configs\gp'
$dst=Join-Path $root 'assets\candidates\banana\approved_candidate'
$files=@{}
Get-ChildItem $dst -Filter 'outcome_*' | Where-Object { $_.Extension -eq '.jpg' -or $_.Extension -eq '.png' } | ForEach-Object { $files[$_.BaseName] = $_.Name }
$outMapRaw = Get-Content -Raw (Join-Path $root 'tools\outcome_reuse_map.json') -Encoding UTF8 | ConvertFrom-Json
$outMap=@{}
foreach($prop in $outMapRaw.PSObject.Properties){ $outMap[$prop.Name] = $prop.Value }
foreach($v in $outMap.Values){ Write-Host "$v exists=$($files.ContainsKey($v))" }
$c=Get-Content -Raw (Join-Path $dir 'GF03-L2-P01.json') -Encoding UTF8|ConvertFrom-Json
foreach($r in $c.rounds){
  if(!($r.PSObject.Properties.Name.Contains('natural_outcome_asset_path')) -or !$r.natural_outcome_asset_path){
    $ol=[string]$r.natural_outcome_label
    Write-Host "missing outcome: $ol"
    foreach($kw in $outMap.Keys){
      if($ol.Contains($kw)){ Write-Host "  MATCH $kw -> $($outMap[$kw])" }
    }
  }
}
