$ErrorActionPreference='Stop'
$root='D:\deepseek\yunxiaoxing-game004'
$cutout = Join-Path $root 'assets\processed\cutout_v001'
$cutFiles = @{}
Get-ChildItem $cutout -Filter '*_alpha.png' | ForEach-Object { $cutFiles[$_.BaseName] = $_.Name }
$packs=@('GF03-L1-P01','GF03-L1-P02','GF03-L1-P03','GF03-L1-P04')
$missing=@(); $have=0; $total=0
foreach($pack in $packs){
  $p = Join-Path $root ("configs\gp\$pack.json")
  $c = Get-Content -Raw $p -Encoding UTF8 | ConvertFrom-Json
  foreach($r in $c.rounds){
    $obj = [string]$r.target_asset_path
    if($obj -eq ''){ continue }
    $total++
    $base = [IO.Path]::GetFileNameWithoutExtension($obj)
    if($cutFiles.ContainsKey($base + '_alpha')){ $have++ }
    else { $missing += "$pack R$($r.opportunity_id) $base" }
  }
}
Write-Host "L1对象总数=$total 已抠=$have 未抠=$($missing.Count)"
$missing | Select-Object -First 20
