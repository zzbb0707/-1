$ErrorActionPreference='Stop'
$root='D:\deepseek\yunxiaoxing-game004'
$dir=Join-Path $root 'configs\gp'
$regMapRaw = Get-Content -Raw (Join-Path $root 'tools\region_reuse_map.json') -Encoding UTF8 | ConvertFrom-Json
$regMap=@{}
foreach($prop in $regMapRaw.PSObject.Properties){ $regMap[$prop.Name] = $prop.Value }
$bound=0
$packs=@('GF03-L2-P01','GF03-L2-P02','GF03-L2-P03','GF03-L2-P04','GF03-L3-P01','GF03-L3-P02','GF03-L3-P03','GF03-L3-P04','GF03-L4-P01','GF03-L4-P02','GF03-L4-P03','GF03-L4-P04','GF03-L5-P01','GF03-L5-P02','GF03-L5-P03','GF03-L5-P04')
foreach($pack in $packs){
  $p=Join-Path $dir ($pack+'.json')
  if(!(Test-Path $p)){ continue }
  $c=Get-Content -Raw $p -Encoding UTF8|ConvertFrom-Json
  foreach($r in $c.rounds){
    if($r.PSObject.Properties.Name.Contains('correct_region_asset_path') -and $r.correct_region_asset_path -and $r.correct_region_asset_path -ne ''){ continue }
    $rl=[string]$r.correct_region_label
    foreach($kw in $regMap.Keys){
      if($rl.Contains($kw)){
        if(-not $r.PSObject.Properties.Name.Contains("correct_region_asset_path")){ $r | Add-Member -NotePropertyName correct_region_asset_path -NotePropertyValue "" -Force }
        $r.correct_region_asset_path="res://assets/candidates/banana/approved_candidate/$($regMap[$kw])"
        $bound++
        break
      }
    }
  }
  $c|ConvertTo-Json -Depth 12|Set-Content $p -Encoding UTF8
}
Write-Host "REGION_REUSE_BACKFILL bound=$bound"
