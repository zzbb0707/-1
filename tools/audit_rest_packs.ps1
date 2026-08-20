$ErrorActionPreference='Continue'
$root='D:\deepseek\yunxiaoxing-game004'
$shots='D:\codex\temp\habitat_rest_shots'
$packs=@('GF03-L2-P03','GF03-L2-P04','GF03-L3-P02','GF03-L3-P03','GF03-L3-P04','GF03-L4-P02','GF03-L4-P03','GF03-L5-P02','GF03-L5-P03','GF03-L5-P04')
foreach($pack in $packs){
  $src = Get-ChildItem $shots -Filter ($pack+'00000000.png') | Select-Object -First 1
  if(-not $src){ Write-Host "NO_SHOT $pack"; continue }
  Copy-Item $src.FullName (Join-Path $root ('artifacts\' + $pack + '_check.png')) -Force
  $img = Join-Path $root ('artifacts\' + $pack + '_check.png')
  $resp = & (Join-Path $root 'tools\blackai_vision.ps1') -Image $img -Question "IMPORTANT: captioning only. Output ONLY JSON: {center_object_desc, left_region_label, right_region_label, overall_polish (1-10)}. habitat scene $pack round 1/6." 2>&1
  Write-Host "== $pack =="
  Write-Host ($resp | Select-Object -Last 1)
}
