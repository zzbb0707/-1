$ErrorActionPreference='Continue'
$godot='C:\Users\Administrator\Desktop\Godot_v4.7.1-stable_win64.exe'
$proj='D:\deepseek\yunxiaoxing-game004'
$out='D:\codex\temp\habitat_allpacks'
New-Item -ItemType Directory -Force $out | Out-Null
$packs=@('GF03-L1-P01','GF03-L1-P02','GF03-L1-P03','GF03-L1-P04','GF03-L2-P01','GF03-L2-P02','GF03-L2-P03','GF03-L2-P04','GF03-L3-P01','GF03-L3-P02','GF03-L3-P03','GF03-L3-P04','GF03-L4-P01','GF03-L4-P02','GF03-L4-P03','GF03-L4-P04','GF03-L5-P01','GF03-L5-P02','GF03-L5-P03','GF03-L5-P04')
$ok=0; $fail=0; $failList=@()
foreach($pack in $packs){
  $tmp = Join-Path $out ($pack + '.log')
  & $godot --headless --path $proj --quit-after 5 -- --game-pack=$pack res://scenes/habitat_slice.tscn 2>&1 | Out-File $tmp -Encoding UTF8
  $errs = Select-String -Path $tmp -Pattern 'SCRIPT ERROR|Parse Error|Invalid' | Select-Object -First 1
  if($errs){ $fail++; $failList += "$pack : $($errs.Line)" } else { $ok++ }
}
Write-Host "LOAD_OK=$ok FAIL=$fail"
if($failList.Count -gt 0){ $failList | Select-Object -First 10 }
