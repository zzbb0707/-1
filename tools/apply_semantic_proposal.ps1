param(
 [string]$ProposalPath=(Join-Path (Split-Path -Parent $PSScriptRoot) 'baseline\game004_semantic_proposal_v1.json'),
 [string]$ConfigDir=(Join-Path (Split-Path -Parent $PSScriptRoot) 'configs\gp')
)
$ErrorActionPreference='Stop'
$proposal=Get-Content -Raw -LiteralPath $ProposalPath -Encoding UTF8 | ConvertFrom-Json
if(([int]($proposal.pack_count)) -ne 20){throw 'proposal pack count invalid'}
if(([int]($proposal.opportunity_count)) -ne 120){throw 'proposal opportunity count invalid'}
$byId=@{};foreach($p in $proposal.packs){$byId[$p.game_pack_id]=$p}
foreach($file in Get-ChildItem -LiteralPath $ConfigDir -Filter '*.json'){
 $config=Get-Content -Raw -LiteralPath $file.FullName -Encoding UTF8|ConvertFrom-Json
 $p=$byId[$config.game_pack_id];if($null -eq $p){throw "proposal missing $($config.game_pack_id)"}
 if($p.opportunities.Count -ne 6){throw "$($config.game_pack_id) proposal needs 6"}
 for($i=0;$i -lt 6;$i++){
  $source=$p.opportunities[$i];$round=$config.rounds[$i]
  if($round.frozen_content -ne $source[2]){throw "frozen content mismatch $($round.opportunity_id)"}
  $round | Add-Member -NotePropertyName target_display_name -NotePropertyValue $source[3] -Force
  $round | Add-Member -NotePropertyName correct_region_label -NotePropertyValue $source[4] -Force
  $round | Add-Member -NotePropertyName correct_region_id -NotePropertyValue ('REG-'+$round.opportunity_id) -Force
  $round | Add-Member -NotePropertyName rule_id -NotePropertyValue $source[5] -Force
  $round | Add-Member -NotePropertyName rule_label -NotePropertyValue $source[6] -Force
  $round | Add-Member -NotePropertyName region_set -NotePropertyValue @($source[7]) -Force
  $round | Add-Member -NotePropertyName semantic_feature -NotePropertyValue $source[8] -Force
  $round | Add-Member -NotePropertyName distractor_guidance -NotePropertyValue $source[9] -Force
  $round | Add-Member -NotePropertyName natural_outcome_label -NotePropertyValue $source[10] -Force
  $round | Add-Member -NotePropertyName natural_outcome_id -NotePropertyValue ('OUT-'+$round.opportunity_id) -Force
  $round | Add-Member -NotePropertyName implementation_status -NotePropertyValue 'semantic_defined_needs_art' -Force
 }
 $config|ConvertTo-Json -Depth 12|Set-Content -LiteralPath $file.FullName -Encoding UTF8
}
Write-Host 'SEMANTIC_PROPOSAL_APPLY_PASS packs=20 opportunities=120'
