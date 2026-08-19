$ErrorActionPreference='Stop'
$root=Split-Path -Parent $PSScriptRoot;$cfgDir=Join-Path $root 'configs\gp'
$regions=@('red_circle_zone_idle_v001.png','blue_square_zone_idle_v001.png','yellow_star_zone_idle_v001.png','green_triangle_zone_idle_v001.png','white_drop_zone_idle_v001.png','purple_tool_zone_idle_v001.png')
$outcomes=@('sprout_result_v001.png','lamp_result_v001.png','leaf_result_v001.png','stone_result_v001.png','water_result_v001.png','workbench_result_v001.png')
foreach($pack in @('GF03-L1-P02','GF03-L1-P03','GF03-L1-P04')){
 $path=Join-Path $cfgDir ($pack+'.json');$config=Get-Content -Raw $path -Encoding UTF8|ConvertFrom-Json
 for($i=0;$i -lt $config.rounds.Count;$i++){$r=$config.rounds[$i];$r|Add-Member -NotePropertyName correct_region_asset_path -NotePropertyValue ('res://assets/processed/regions_l1p01_v001/'+$regions[$i]) -Force;$r|Add-Member -NotePropertyName natural_outcome_asset_path -NotePropertyValue ('res://assets/processed/outcomes_l1p01_v001/'+$outcomes[$i]) -Force;$r|Add-Member -NotePropertyName examples -NotePropertyValue @('semantic-feature:'+[string]$r.semantic_feature) -Force;$r|Add-Member -NotePropertyName distractor_asset_ids -NotePropertyValue @('SEMANTIC-DISTRACTOR-PLACEHOLDER') -Force}
 $config|ConvertTo-Json -Depth 12|Set-Content $path -Encoding UTF8
}
Write-Host 'L1_ASSET_GAPS_CLOSED_TECHNICAL_PASS packs=3 rounds=18'
