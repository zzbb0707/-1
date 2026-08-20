$ErrorActionPreference='Stop'
$c=Get-Content -Raw 'D:\deepseek\yunxiaoxing-game004\configs\gp\GF03-L1-P03.json' -Encoding UTF8|ConvertFrom-Json
$i=1
foreach($r in $c.rounds){
  Write-Host ("R{0}: {1}" -f $i, $r.target_display_name)
  Write-Host ("   规则: {0}" -f $r.rule_label)
  Write-Host ("   正确区: {0}" -f $r.correct_region_label)
  Write-Host ("   结果: {0}" -f $r.natural_outcome_label)
  Write-Host ("   obj: {0}" -f $r.target_asset_path)
  Write-Host ("   reg: {0}" -f $r.correct_region_asset_path)
  $i++
}
