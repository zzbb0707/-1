$ErrorActionPreference='Stop'
$root='D:\deepseek\yunxiaoxing-game004'
$dir=Join-Path $root 'configs\gp'
$dst=Join-Path $root 'assets\candidates\banana\approved_candidate'
# replacements: old path fragment -> new banana file
$replace=@{
  'res://assets/processed/objects_v001/red_circle_seed_v001.png' = 'res://assets/candidates/banana/approved_candidate/object_redcircleseed_v001.png'
  'res://assets/processed/objects_v001/round_icon_v001.png' = 'res://assets/candidates/banana/approved_candidate/object_roundicon_v001.jpg'
  'res://assets/processed/regions_l1p01_v001/red_circle_zone_idle_v001.png' = 'res://assets/candidates/banana/approved_candidate/region_red_zone_grid_v001.png'
  'res://assets/processed/regions_l1p01_v001/white_drop_zone_idle_v001.png' = 'res://assets/candidates/banana/approved_candidate/region_waterpool_v001.jpg'
  'res://assets/processed/regions_l1p01_v001/purple_tool_zone_idle_v001.png' = 'res://assets/candidates/banana/approved_candidate/region_toolzone_v001.jpg'
}
$replaced=0
$packs=@('GF03-L1-P01','GF03-L1-P02','GF03-L1-P03','GF03-L1-P04')
foreach($pack in $packs){
  $p=Join-Path $dir ($pack+'.json')
  if(!(Test-Path $p)){ continue }
  $raw = Get-Content -Raw $p -Encoding UTF8
  foreach($old in $replace.Keys){
    if($raw.Contains($old)){
      $raw = $raw.Replace($old, $replace[$old])
      $replaced++
    }
  }
  [System.IO.File]::WriteAllText($p, $raw, [System.Text.Encoding]::UTF8)
}
Write-Host "OLD_ASSET_REPLACED count=$replaced"
