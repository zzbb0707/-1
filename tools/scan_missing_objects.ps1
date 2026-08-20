$ErrorActionPreference='Stop'
$root='D:\deepseek\yunxiaoxing-game004'
$dir=Join-Path $root 'configs\gp'
# scan for rounds with empty target_asset_path but non-flow labels that need assets
$patterns=@('不同形状','不同大小','变化','新样式','大件','中件','小件','红色','蓝色','黄色','绿色','三色')
$found=@()
$packs=@('GF03-L2-P01','GF03-L2-P02','GF03-L2-P03','GF03-L2-P04','GF03-L3-P01','GF03-L3-P02','GF03-L3-P03','GF03-L3-P04','GF03-L4-P01','GF03-L4-P02','GF03-L4-P03','GF03-L4-P04','GF03-L5-P01','GF03-L5-P02','GF03-L5-P03','GF03-L5-P04')
foreach($pack in $packs){
  $p=Join-Path $dir ($pack+'.json')
  if(!(Test-Path $p)){ continue }
  $c=Get-Content -Raw $p -Encoding UTF8|ConvertFrom-Json
  foreach($r in $c.rounds){
    if($r.PSObject.Properties.Name.Contains('target_asset_path') -and $r.target_asset_path -and $r.target_asset_path -ne ''){ continue }
    $t=[string]$r.target_display_name
    if($t.Contains('当前') -or $t.Contains('照片') -or $t.Contains('家庭') -or $t.Contains('候选') -or $t.Contains('新实例') -or $t.Contains('切换后') -or $t.Contains('连续') -or $t.Contains('六种') -or $t.Contains('屏幕') -or $t.Contains('真实')){ continue }
    if($t.Contains('；') -or $t.Contains([string][char]0xFF1B)){ continue }
    $found += "$pack $($r.opportunity_id) $t"
  }
}
Write-Host "需补素材的回合: $($found.Count)"
$found | ForEach-Object { Write-Host $_ }
