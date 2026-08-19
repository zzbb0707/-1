# GAME-004 classify queue: visual assets vs flow-only descriptions
$ErrorActionPreference = 'Stop'
$root = 'D:\deepseek\yunxiaoxing-game004'
$q = Get-Content -Raw (Join-Path $root 'assets\candidates\banana\single_clean_queue.json') -Encoding UTF8 | ConvertFrom-Json

$flowOnly = @(
  ([string][char]0x5019 + [string][char]0x9009 + 'MP'),
  ([string][char]0x5BF9 + [string][char]0x5E94 + [string][char]0x751F + [string][char]0x5883 + [string][char]0x533A + [string][char]0x57DF),
  ([string][char]0x5F53 + [string][char]0x524D + [string][char]0x5C42 + [string][char]0x7EA7 + [string][char]0x76EE + [string][char]0x6807),
  ([string][char]0x5207 + [string][char]0x6362 + [string][char]0x540E + [string][char]0x5F53 + [string][char]0x524D + [string][char]0x76EE + [string][char]0x6807),
  ([string][char]0x5339 + [string][char]0x914D + [string][char]0x533A + [string][char]0x57DF + [string][char]0x54CD + [string][char]0x5E94),
  ([string][char]0x989C + [string][char]0x8272 + [string][char]0x5206 + [string][char]0x533A + [string][char]0x54CD + [string][char]0x5E94),
  ([string][char]0x5F62 + [string][char]0x72B6 + [string][char]0x5206 + [string][char]0x533A + [string][char]0x54CD + [string][char]0x5E94),
  ([string][char]0x5927 + [string][char]0x5C0F + [string][char]0x5206 + [string][char]0x533A + [string][char]0x54CD + [string][char]0x5E94),
  ([string][char]0x6B63 + [string][char]0x786E + [string][char]0x914D + [string][char]0x5BF9 + [string][char]0x533A + [string][char]0x57DF + [string][char]0x54CD + [string][char]0x5E94),
  ([string][char]0x7528 + [string][char]0x54C1 + [string][char]0x5C42 + [string][char]0x4E0E + [string][char]0x5DE5 + [string][char]0x5177 + [string][char]0x5C42 + [string][char]0x4F9D + [string][char]0x6B21 + [string][char]0x5C55 + [string][char]0x5F00),
  ([string][char]0x5F53 + [string][char]0x524D + [string][char]0x76EE + [string][char]0x6807),
  ([string][char]0x914D + [string][char]0x5BF9 + [string][char]0x5BF9 + [string][char]0x8C61)
)

$visual = @()
$flow = @()
foreach ($item in $q.items) {
    $isFlow = $false
    foreach ($p in $flowOnly) { if ($item.label.Contains($p)) { $isFlow = $true; break } }
    if ($isFlow) { $flow += $item } else { $visual += $item }
}

$out = [ordered]@{
    schema_version = 'game004-visual-queue-v1'
    baseline_version = 'GAME004-BASELINE-V1'
    model = 'google/nano-banana-pro/text-to-image'
    mode = 'single_object_per_image'
    visual_total = $visual.Count
    flow_total = $flow.Count
    estimated_cost = [math]::Round($visual.Count * 0.14, 2)
    items = $visual
    flow_only_items = ($flow | ForEach-Object { "$($_.kind)|$($_.label)" })
}
$out | ConvertTo-Json -Depth 8 | Set-Content (Join-Path $root 'assets\candidates\banana\visual_queue.json') -Encoding UTF8
Write-Host "VISUAL_QUEUE_PASS visual=$($visual.Count) flow=$($flow.Count) cost=$([math]::Round($visual.Count*0.14,2))"
