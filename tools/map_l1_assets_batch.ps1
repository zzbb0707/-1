$ErrorActionPreference='Stop'
$root=Split-Path -Parent $PSScriptRoot
$dir=Join-Path $root 'configs\gp'
$assets=@('fish','bird','flower','hammer','apple','toy_car','cup','shoe','red_circle_seed','white_round_drop','purple_square_tool','large_stone','round_icon','square_icon')
foreach($packId in @('GF03-L1-P02','GF03-L1-P03','GF03-L1-P04')){
 $path=Join-Path $dir ($packId+'.json');$config=Get-Content -Raw $path -Encoding UTF8|ConvertFrom-Json
 for($i=0;$i -lt $config.rounds.Count;$i++){$asset=$assets[($i + ($(if($packId.EndsWith('P03')){6}elseif($packId.EndsWith('P04')){10}else{0}))) % $assets.Count];$round=$config.rounds[$i];$round|Add-Member -NotePropertyName target_asset_id -NotePropertyValue ('AS-GAME004-L1-'+$asset.ToUpper()) -Force;$round|Add-Member -NotePropertyName target_asset_path -NotePropertyValue ('res://assets/processed/objects_v001/'+$asset+'_v001.png') -Force;$round|Add-Member -NotePropertyName implementation_status -NotePropertyValue 'object_asset_mapped_needs_region_outcome' -Force}
 $config|ConvertTo-Json -Depth 12|Set-Content $path -Encoding UTF8
}
Write-Host 'L1_BATCH_OBJECT_MAPPING_PASS packs=3'
