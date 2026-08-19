param(
  [string]$Baseline = (Join-Path (Split-Path -Parent $PSScriptRoot) 'baseline\game004_content_baseline.json'),
  [string]$OutputDir = (Join-Path (Split-Path -Parent $PSScriptRoot) 'configs\gp')
)
$ErrorActionPreference='Stop'
$root=Get-Content -Raw -LiteralPath $Baseline -Encoding UTF8|ConvertFrom-Json
New-Item -ItemType Directory -Force $OutputDir|Out-Null
function Get-LevelDefaults([string]$L){
  switch($L){
    'L1' {return @{region_count=2;prompt_strength='P2';rule_mode='explicit_match';low_sensory=$true}}
    'L2' {return @{region_count=3;prompt_strength='P2';rule_mode='explicit_attribute';low_sensory=$true}}
    'L3' {return @{region_count=3;prompt_strength='P1';rule_mode='explicit_switch';low_sensory=$true}}
    'L4' {return @{region_count=4;prompt_strength='P1';rule_mode='example_inference';low_sensory=$true}}
    'L5' {return @{region_count=3;prompt_strength='P1';rule_mode='authorized_photo_or_bridge';low_sensory=$true}}
  }
}
foreach($pack in $root.packs){
  $defaults=Get-LevelDefaults $pack.l_level
  $rounds=@(); foreach($op in $pack.opportunities){$rounds += [ordered]@{opportunity_id=$op.opportunity_id;order=$op.order;frozen_content=$op.frozen_content;implementation_status='content_semantics_pending';target_asset_id='';distractor_asset_ids=@();correct_region_id='';rule_id='';rule_label='';examples=@();natural_outcome_id='';data_fields=@('first_selection','final_selection','independent','highest_prompt','reaction_time_ms','error_type','retry_count','invalid_drag_count','stress_signal')}}
  $config=[ordered]@{schema_version='game004-gp-config-v1';baseline_version=$root.baseline_version;allocation_rule_version='ALLOC-CORE-V1';tag_schema_version='TAG-SCHEMA-V1';lifecycle_status='draft';game_pack_id=$pack.game_pack_id;game_id='GAME-004';game_family_id='GF-03';primary_training_unit_id='TU-011';title=$pack.title;l_level=$pack.l_level;fixed_opportunity_count=6;difficulty_profile=$defaults;asset_manifest_id='';rights_status='unknown';low_sensory_variant_id=('LOW-SENSORY-'+$pack.game_pack_id);rounds=$rounds}
  $path=Join-Path $OutputDir ($pack.game_pack_id+'.json');$config|ConvertTo-Json -Depth 8|Set-Content -LiteralPath $path -Encoding UTF8
}
Write-Host "GP_CONFIG_SKELETON_BUILD_PASS packs=$($root.packs.Count)"
