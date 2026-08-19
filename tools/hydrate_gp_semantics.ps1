param(
  [string]$ConfigDir = (Join-Path (Split-Path -Parent $PSScriptRoot) 'configs\gp')
)
$ErrorActionPreference='Stop'
$arrow=[string][char]0x2192; $comma=[string][char]0xFF0C; $period=[string][char]0x3002; $semi=[string][char]0xFF1B; $pair=[string][char]0x914D
function Slug([string]$Value){
  $hex=($Value.ToCharArray() | ForEach-Object {[int][char]$_ | ForEach-Object {$_.ToString('x4')}}) -join '-'
  return $hex
}
Get-ChildItem -LiteralPath $ConfigDir -Filter '*.json' | ForEach-Object {
  $config=Get-Content -Raw -LiteralPath $_.FullName -Encoding UTF8 | ConvertFrom-Json
  foreach($round in $config.rounds){
    $text=[string]$round.frozen_content; $target='';$region='';$outcome='';$rule='RULE-CURRENT-EXPLICIT';$label='Follow the current rule';$regionSet=@('region-a','region-b')
    if($text.Contains($arrow)){
      $parts=$text.Split($arrow)
      $target=$parts[0].Trim()
      $right=$parts[1]
      $region=($right -split "[$comma$period$semi]")[0].Trim()
      if($right -match "[$comma$semi](.+?)(?:$period|$)$"){$outcome=$Matches[1].Trim()}
      $rule='RULE-FROZEN-ARROW';$label='Classify by the visible rule';$regionSet=@($region,'other-region')
    } elseif($text.Contains($pair)) {
      $parts=$text.Split($pair,2); $target=$parts[0].Trim(); $region='matching-region'; $rule='RULE-EXACT-MATCH';$label='Match the same picture';$regionSet=@('matching-region','other-region')
      if($text -match "[$comma](.+?)(?:$period|$)"){$outcome=$Matches[1].Trim()}
    } else {
      $target='current-target';$region='correct-region';$outcome='correct-region-response';$rule='RULE-FROZEN-REVIEW';$label='Follow the current rule';$regionSet=@('correct-region','other-region')
    }
    $round | Add-Member -NotePropertyName target_display_name -NotePropertyValue $target -Force
    $round | Add-Member -NotePropertyName correct_region_id -NotePropertyValue ('REG-'+(Slug $region)) -Force
    $round | Add-Member -NotePropertyName correct_region_label -NotePropertyValue $region -Force
    $round | Add-Member -NotePropertyName region_set -NotePropertyValue $regionSet -Force
    $round | Add-Member -NotePropertyName rule_id -NotePropertyValue $rule -Force
    $round | Add-Member -NotePropertyName rule_label -NotePropertyValue $label -Force
    $round | Add-Member -NotePropertyName natural_outcome_id -NotePropertyValue ('OUT-'+(Slug $outcome)) -Force
    $round | Add-Member -NotePropertyName natural_outcome_label -NotePropertyValue $outcome -Force
    $round | Add-Member -NotePropertyName implementation_status -NotePropertyValue 'semantic_hydrated_needs_art' -Force
  }
  $config | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $_.FullName -Encoding UTF8
}
Write-Host 'GP_SEMANTIC_HYDRATE_PASS'
