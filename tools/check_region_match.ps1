$ErrorActionPreference='Continue'
$root='D:\deepseek\yunxiaoxing-game004'
$dst = Join-Path $root 'assets\candidates\banana\approved_candidate'
$files = @{}
Get-ChildItem $dst -Filter 'region_*' | Where-Object { $_.Extension -in '.jpg','.png' } | ForEach-Object { $files[$_.BaseName] = $_.Name }
$slugRaw = Get-Content -Raw (Join-Path $root 'tools\region_slug_map.json') -Encoding UTF8 | ConvertFrom-Json
$slugMap=@{}
foreach($prop in $slugRaw.PSObject.Properties){ $slugMap[$prop.Name] = $prop.Value }
$packs=@('GF03-L1-P01','GF03-L1-P02','GF03-L1-P03','GF03-L1-P04','GF03-L2-P01','GF03-L2-P02','GF03-L2-P03','GF03-L2-P04','GF03-L3-P01','GF03-L3-P02','GF03-L3-P03','GF03-L3-P04','GF03-L4-P01','GF03-L4-P02','GF03-L4-P03','GF03-L4-P04','GF03-L5-P01','GF03-L5-P02','GF03-L5-P03','GF03-L5-P04')
$unique=@{}
foreach($pack in $packs){
  $p = Join-Path $root ("configs\gp\$pack.json")
  if(!(Test-Path $p)){ continue }
  $c = Get-Content -Raw $p -Encoding UTF8 | ConvertFrom-Json
  foreach($r in $c.rounds){
    $rs = @($r.region_set)
    foreach($rn in $rs){ if($rn -and $rn -ne ''){ $unique[[string]$rn] = $true } }
  }
}
$matched=0; $unmatched=@()
foreach($rn in ($unique.Keys | Sort-Object)){
  $slug=''
  foreach($k in $slugMap.Keys){ if($rn.Contains($k)){ $slug=$slugMap[$k]; break } }
  $hit = $false
  if($slug -ne ''){
    $cand = "region_${slug}_grid_v001"
    if($files.ContainsKey($cand)){ $hit=$true }
  }
  if($hit){ $matched++ } else { $unmatched += $rn }
}
Write-Host "UNIQUE_REGIONS=$($unique.Count) MATCHED=$matched UNMATCHED=$($unmatched.Count)"
$unmatched | Sort-Object
