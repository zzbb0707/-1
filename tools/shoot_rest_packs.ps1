$ErrorActionPreference='Continue'
$godot='C:\Users\Administrator\Desktop\Godot_v4.7.1-stable_win64.exe'
$proj='D:\deepseek\yunxiaoxing-game004'
$out='D:\codex\temp\habitat_rest_shots'
New-Item -ItemType Directory -Force $out | Out-Null
$packs=@('GF03-L2-P03','GF03-L2-P04','GF03-L3-P02','GF03-L3-P03','GF03-L3-P04','GF03-L4-P02','GF03-L4-P03','GF03-L4-P04','GF03-L5-P02','GF03-L5-P03','GF03-L5-P04')
foreach($pack in $packs){
  $movie = Join-Path $out ($pack + '.png')
  & $godot --path $proj --scene 'res://scenes/habitat_slice.tscn' --write-movie $movie --fixed-fps 30 --quit-after 3 --disable-vsync -- --game-pack=$pack 2>&1 | Out-Null
  $png = Get-ChildItem $out -Filter ($pack + '00000000.png') | Select-Object -First 1
  if($png){ Write-Host "OK $pack $($png.Length)" } else { Write-Host "FAIL $pack" }
}
