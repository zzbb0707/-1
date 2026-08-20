$ErrorActionPreference='Continue'
$godot='C:\Users\Administrator\Desktop\Godot_v4.7.1-stable_win64.exe'
$proj='D:\deepseek\yunxiaoxing-game004'
$out='D:\codex\temp\habitat_l1_verify'
New-Item -ItemType Directory -Force $out | Out-Null
$packs=@('GF03-L1-P01','GF03-L1-P02','GF03-L1-P03','GF03-L1-P04')
$ok=0; $fail=0
foreach($pack in $packs){
  $log = Join-Path $out ($pack+'.log')
  & $godot --headless --path $proj --scene 'res://scenes/habitat_slice.tscn' --quit-after 5 -- --game-pack=$pack 2>&1 | Out-File $log -Encoding UTF8
  $err = Select-String -Path $log -Pattern 'SCRIPT ERROR|Parse Error|Failed to load' | Select-Object -First 1
  if($err){ $fail++; Write-Host "FAIL $pack : $($err.Line)" } else { $ok++; Write-Host "OK $pack" }
}
Write-Host "L1_VERIFY_OK=$ok FAIL=$fail"
