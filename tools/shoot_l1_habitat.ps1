$ErrorActionPreference='Continue'
$godot='C:\Users\Administrator\Desktop\Godot_v4.7.1-stable_win64.exe'
$proj='D:\deepseek\yunxiaoxing-game004'
$out='D:\codex\temp\habitat_l1_shots'
New-Item -ItemType Directory -Force $out | Out-Null
$packs=@('GF03-L1-P01','GF03-L1-P02','GF03-L1-P03','GF03-L1-P04')
foreach($pack in $packs){
  $shot = Join-Path $out ($pack + '.png')
  & $godot --path $proj --scene 'res://scenes/habitat_slice.tscn' --write-movie $shot --fixed-fps 30 --quit-after 3 --disable-vsync -- --game-pack=$pack 2>&1 | Out-Null
  $png = Get-ChildItem $out -Filter ($pack + '00000000.png') | Select-Object -First 1
  if($png){ Write-Host "SHOT_OK $pack $($png.Length)" } else { Write-Host "SHOT_FAIL $pack" }
}
