param(
  [string]$Baseline = (Join-Path (Split-Path -Parent $PSScriptRoot) 'baseline\game004_content_baseline.json'),
  [string]$Output = (Join-Path (Split-Path -Parent $PSScriptRoot) 'baseline\game004_asset_matrix.json')
)
$ErrorActionPreference = 'Stop'
$root = Get-Content -Raw -LiteralPath $Baseline -Encoding UTF8 | ConvertFrom-Json
$rows = @()
$tokens = @{}
foreach($pack in $root.packs){
  foreach($opportunity in $pack.opportunities){
    $text = [string]$opportunity.frozen_content
    $tokensForRow = [regex]::Matches($text, '[\p{IsCJKUnifiedIdeographs}A-Za-z0-9]+') | ForEach-Object {$_.Value}
    foreach($token in $tokensForRow){ if($token.Length -gt 1){ if($tokens.ContainsKey($token)){$tokens[$token]++}else{$tokens[$token]=1} } }
    $rows += [ordered]@{
      game_pack_id=$pack.game_pack_id
      opportunity_id=$opportunity.opportunity_id
      l_level=$pack.l_level
      frozen_content=$text
      asset_status='unproduced'
      required_layers=@('target','contrast_or_distractor','region','rule_or_example','natural_outcome','neutral_buffer','low_sensory_variant','rights_record')
    }
  }
}
$matrix=[ordered]@{
  schema_version='game004-asset-matrix-v1'
  baseline_version=$root.baseline_version
  source_sha256=$root.source_sha256
  opportunity_count=$rows.Count
  production_rule='Every opportunity requires target, contrast/distractor, region, rule/example, natural outcome, neutral buffer, low-sensory variant and rights record before active.'
  opportunities=$rows
  semantic_token_frequency=($tokens.GetEnumerator()|Sort-Object Value -Descending|ForEach-Object {[ordered]@{token=$_.Key;uses=$_.Value}})
}
New-Item -ItemType Directory -Force (Split-Path -Parent $Output)|Out-Null
$matrix|ConvertTo-Json -Depth 8|Set-Content -LiteralPath $Output -Encoding UTF8
Write-Host "ASSET_MATRIX_BUILD_PASS opportunities=$($rows.Count) tokens=$($tokens.Count)"
