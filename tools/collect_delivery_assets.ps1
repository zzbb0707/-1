$ErrorActionPreference='Stop'
$root='D:\deepseek\yunxiaoxing-game004'
$out='D:\codex\temp\delivery_assets'
if(Test-Path $out){Remove-Item $out -Recurse -Force}
$refs=@{}
Get-ChildItem (Join-Path $root 'configs\gp') -Filter '*.json' | ForEach-Object {
  $c=Get-Content -Raw $_.FullName -Encoding UTF8 | ConvertFrom-Json
  foreach($r in $c.rounds){
    foreach($f in @('target_asset_path','secondary_target_asset_path','correct_region_asset_path','natural_outcome_asset_path')){
      $v=[string]$r.$f
      if($v -and $v -like 'res://*'){ $refs[$v]=$true }
    }
  }
}
Write-Host "REF_COUNT=$($refs.Count)"
$copied=0; $missing=0
foreach($res in $refs.Keys){
  $rel=$res -replace '^res://',''
  $src=Join-Path $root ($rel -replace '/','\')
  if(Test-Path $src){
    $dst=Join-Path $out ($rel -replace '/','\')
    $dstDir=[IO.Path]::GetDirectoryName($dst)
    New-Item -ItemType Directory -Force $dstDir | Out-Null
    Copy-Item $src $dst -Force
    $copied++
  } else { $missing++ }
}
Write-Host "COPIED=$copied MISSING=$missing"
$size=(Get-ChildItem $out -Recurse -File|Measure-Object -Property Length -Sum).Sum
Write-Host ("SIZE_MB=" + [math]::Round($size/1MB,1))
