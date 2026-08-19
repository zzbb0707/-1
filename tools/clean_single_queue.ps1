# GAME-004 single-queue cleaner: split combined labels into single-semantic items
$ErrorActionPreference = 'Stop'
$root = 'D:\deepseek\yunxiaoxing-game004'
$q = Get-Content -Raw (Join-Path $root 'assets\candidates\banana\single_queue.json') -Encoding UTF8 | ConvertFrom-Json
$clean = @()
$seen = @{}
$sep1 = [string][char]0xFF1B
$sep2 = ';'
foreach ($item in $q.items) {
    $parts = @($item.label -split $sep1)
    $tmp = @()
    foreach ($part in $parts) { $tmp += @($part -split $sep2) }
    foreach ($part in $tmp) {
        $p = $part.Trim()
        if ($p.Length -eq 0) { continue }
        $key = "$($item.kind)|$p"
        if ($seen.ContainsKey($key)) { continue }
        $seen[$key] = $true
        $assetId = "AS-GAME004-$($item.kind.ToUpper())-" + ($p -replace '[^\u4e00-\u9fa5A-Za-z0-9]', '')
        $clean += [ordered]@{
            asset_id = $assetId
            kind = $item.kind
            label = $p
            packs = $item.packs
            status = 'pending'
            prediction_id = ''
            review = ''
            file = ''
        }
    }
}
$out = [ordered]@{
    schema_version = 'game004-single-clean-queue-v1'
    baseline_version = 'GAME004-BASELINE-V1'
    model = 'google/nano-banana-pro/text-to-image'
    mode = 'single_object_per_image'
    total = $clean.Count
    estimated_cost = [math]::Round($clean.Count * 0.14, 2)
    items = $clean
}
$out | ConvertTo-Json -Depth 8 | Set-Content (Join-Path $root 'assets\candidates\banana\single_clean_queue.json') -Encoding UTF8
Write-Host "SINGLE_CLEAN_QUEUE_PASS total=$($clean.Count) cost=$([math]::Round($clean.Count*0.14,2))"
