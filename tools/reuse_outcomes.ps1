$ErrorActionPreference='Stop'
$root='D:\deepseek\yunxiaoxing-game004'
$dir=Join-Path $root 'configs\gp'
$dst=Join-Path $root 'assets\candidates\banana\approved_candidate'
$files=@{}
Get-ChildItem $dst -Filter 'outcome_*' | Where-Object { $_.Extension -eq '.jpg' -or $_.Extension -eq '.png' } | ForEach-Object { $files[$_.BaseName] = $_.Name }
$outMapRaw = @(Get-Content -Raw (Join-Path $root 'tools\outcome_reuse_map.json') -Encoding UTF8 | ConvertFrom-Json)
$outMap = @{}
foreach ($prop in $outMapRaw.PSObject.Properties) { $outMap[$prop.Name] = $prop.Value }
$bound=0
$packs=@('GF03-L2-P01','GF03-L2-P02','GF03-L2-P03','GF03-L2-P04','GF03-L3-P01','GF03-L3-P02','GF03-L3-P03','GF03-L3-P04','GF03-L4-P01','GF03-L4-P02','GF03-L4-P03','GF03-L4-P04','GF03-L5-P01','GF03-L5-P02','GF03-L5-P03','GF03-L5-P04')
foreach($pack in $packs){
  $p=Join-Path $dir ($pack+'.json')
  if(!(Test-Path $p)){ continue }
  $c=Get-Content -Raw $p -Encoding UTF8|ConvertFrom-Json
  foreach($r in $c.rounds){
    if($r.PSObject.Properties.Name.Contains('natural_outcome_asset_path') -and $r.natural_outcome_asset_path -and $r.natural_outcome_asset_path -ne ''){ continue }
    $ol=[string]$r.natural_outcome_label
    if($ol.Contains('LIFE') -or $ol.Contains('OBS') -or $ol.Contains('签发')){ continue }
    foreach($kw in $outMap.Keys){
      if($ol.Contains($kw)){
        if(!$r.PSObject.Properties.Name.Contains('natural_outcome_asset_path')){ $r | Add-Member -NotePropertyName natural_outcome_asset_path -NotePropertyValue '' -Force }
        $r.natural_outcome_asset_path="res://assets/candidates/banana/approved_candidate/$($files[$outMap[$kw]])"
        $bound++
        break
      }
    }
  }
  $c|ConvertTo-Json -Depth 12|Set-Content $p -Encoding UTF8
}
Write-Host "OUTCOME_PATTERN_REUSE bound=$bound"
