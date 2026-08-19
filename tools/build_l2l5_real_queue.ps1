$ErrorActionPreference='Stop'
$root='D:\deepseek\yunxiaoxing-game004'
$dir=Join-Path $root 'configs\gp'
$style='GAME-004 approved art direction, warm ivory and sage-green habitat pod, rounded toy-like 3D animated-film render, soft diffuse lighting, gentle child-friendly forms, clear semantic silhouette, no text, no pseudo-UI, no watermark.'
$flowPatterns = @(Get-Content -Raw (Join-Path $root 'tools\flow_patterns.json') -Encoding UTF8 | ConvertFrom-Json)
$sep1=[string][char]0xFF1B
$items=@()
$seen=@{}
$packs=@('GF03-L2-P01','GF03-L2-P02','GF03-L2-P03','GF03-L2-P04','GF03-L3-P01','GF03-L3-P02','GF03-L3-P03','GF03-L3-P04','GF03-L4-P01','GF03-L4-P02','GF03-L4-P03','GF03-L4-P04','GF03-L5-P01','GF03-L5-P02','GF03-L5-P03','GF03-L5-P04')
foreach($pack in $packs){
  $p=Join-Path $dir ($pack+'.json')
  $c=Get-Content -Raw $p -Encoding UTF8|ConvertFrom-Json
  foreach($r in $c.rounds){
    $entries=@()
    $entries += [ordered]@{kind='object';label=[string]$r.target_display_name}
    $entries += [ordered]@{kind='region';label=[string]$r.correct_region_label}
    $entries += [ordered]@{kind='outcome';label=[string]$r.natural_outcome_label}
    foreach($e in $entries){
      $skip=$false
      foreach($pat in $flowPatterns){ if($e.label.Contains($pat)){ $skip=$true; break } }
      if($skip){ continue }
      if($e.label.Contains($sep1)){ continue }
      $key="$($e.kind)|$($e.label)"
      if($seen.ContainsKey($key)){ continue }
      $seen[$key]=$true
      $prompt=''
      if($e.kind -eq 'object'){ $prompt=($style+' A single isolated runtime object asset: '+$e.label+', exactly one object, centered, front three-quarter view, soft shadow, vivid matte colors, warm ivory background, no labels, no borders.') }
      if($e.kind -eq 'region'){ $prompt=($style+' A single isolated rounded diorama habitat region tile: '+$e.label+', exactly one tile, centered, front three-quarter view, same material language, low visual density, warm ivory background, no labels, no borders.') }
      if($e.kind -eq 'outcome'){ $prompt=($style+' A single compact natural ecosystem result state icon: '+$e.label+', exactly one icon, centered, same material language, no fireworks, no particles, warm ivory background, no labels, no borders.') }
      $items += [ordered]@{kind=$e.kind;label=$e.label;prompt=$prompt}
    }
  }
}
$out=[ordered]@{schema_version='game004-l2l5-real-assets-v1';baseline_version='GAME004-BASELINE-V1';model='google/nano-banana-pro/text-to-image';total=$items.Count;estimated_cost=[math]::Round($items.Count*0.14,2);items=$items}
$out|ConvertTo-Json -Depth 6|Set-Content (Join-Path $root 'assets\candidates\banana\l2l5_real_queue.json') -Encoding UTF8
Write-Host "L2L5_REAL_QUEUE_PASS total=$($items.Count) cost=$([math]::Round($items.Count*0.14,2))"
