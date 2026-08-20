$ErrorActionPreference='Stop'
foreach($pack in @('GF03-L1-P01','GF03-L1-P02','GF03-L1-P04')){
  $p = "D:\deepseek\yunxiaoxing-game004\configs\gp\$pack.json"
  if(!(Test-Path $p)){ continue }
  $c = Get-Content -Raw $p -Encoding UTF8 | ConvertFrom-Json
  Write-Host "===== $pack ====="
  $i=1
  foreach($r in $c.rounds){
    $regions = if($r.PSObject.Properties.Name -contains 'region_set'){ ($r.region_set -join ',') } else { '' }
    Write-Host ("R{0}: 目标={1} | 正确区={2} | region_set={3}" -f $i, $r.target_display_name, $r.correct_region_label, $regions)
    $i++
  }
}
