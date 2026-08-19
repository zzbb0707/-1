$ErrorActionPreference='Stop'
$root=Split-Path -Parent $PSScriptRoot
$dir=Join-Path $root 'configs\gp'
$maps=@{
  'GF03-L1-P02'=@('fish,bird','flower,hammer','apple,toy_car','cup,shoe','red_circle_seed,white_round_drop','lamp,large_stone')
  'GF03-L1-P03'=@('round_icon,square_icon','square_icon,round_icon','large_stone,small_stone','square_icon,round_icon','round_icon,square_icon','round_icon,square_icon')
  'GF03-L1-P04'=@('red_circle_seed,blue_square_crystal','fish,bird','round_icon,square_icon','flower,purple_square_tool','round_icon,square_icon','round_icon,square_icon')
}
foreach($pack in $maps.Keys){
  $path=Join-Path $dir ($pack+'.json')
  $config=Get-Content -Raw $path -Encoding UTF8|ConvertFrom-Json
  for($i=0;$i -lt 6;$i++){
    $pair=$maps[$pack][$i].Split(',')
    $r=$config.rounds[$i]
    $primaryName=[string]$r.target_display_name
    $secondaryName=$primaryName
    $sep=[char]0xFF1B
    if($primaryName.Contains($sep)){$secondaryName=$primaryName.Split($sep)[-1].Trim()}
    $r|Add-Member -NotePropertyName target_asset_path -NotePropertyValue ('res://assets/processed/objects_v001/'+$pair[0]+'_v001.png') -Force
    $r|Add-Member -NotePropertyName secondary_target_display_name -NotePropertyValue $secondaryName -Force
    $r|Add-Member -NotePropertyName secondary_target_asset_path -NotePropertyValue ('res://assets/processed/objects_v001/'+$pair[1]+'_v001.png') -Force
  }
  $config|ConvertTo-Json -Depth 12|Set-Content $path -Encoding UTF8
}
Write-Host 'L1_SECONDARY_OBJECT_MAPPING_PASS packs=3 rounds=18'
