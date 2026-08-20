$ErrorActionPreference='Stop'
$c=Get-Content -Raw 'D:\deepseek\yunxiaoxing-game004\configs\gp\GF03-L1-P04.json' -Encoding UTF8|ConvertFrom-Json
$i=1
foreach($r in $c.rounds){
  Write-Host ("R{0}: 目标={1} obj={2}" -f $i, $r.target_display_name, $r.target_asset_path)
  $i++
}
