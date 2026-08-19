# GAME-004 batch review queue generator
param(
    [string]$QueuePath = "D:\deepseek\yunxiaoxing-game004\assets\candidates\banana\single_queue.json",
    [string]$OutputRoot = "D:\deepseek\yunxiaoxing-game004\assets\candidates\banana"
)
$ErrorActionPreference = 'Stop'
$queue = Get-Content -Raw $QueuePath -Encoding UTF8 | ConvertFrom-Json
$reviews = @()
foreach ($item in $queue.items) {
    $question = ""
    switch ($item.kind) {
        "object" { $question = "Review this single-object asset: exactly one centered object? warm ivory background? no text/watermark/border/pseudo-UI? recognizable as '$($item.label)'? soft matte gloss? child-safe with no sharp elements? Answer item by item, then give PASS/FAIL." }
        "region" { $question = "Review this single region tile: exactly one tile? warm ivory background? no text/watermark/border/pseudo-UI? recognizable as '$($item.label)'? low visual density? child-safe? Answer item by item, then give PASS/FAIL." }
        "outcome" { $question = "Review this natural outcome icon: exactly one state icon? warm ivory background? no text/watermark/border/pseudo-UI? expresses natural outcome '$($item.label)'? no fireworks, no particles? child-safe? Answer item by item, then give PASS/FAIL." }
        default { $question = "Review this asset: one object, warm ivory background, no text/watermark, recognizable as '$($item.label)', child-safe. Give PASS/FAIL." }
    }
    $reviews += [ordered]@{
        asset_id = $item.asset_id
        kind = $item.kind
        label = $item.label
        game_pack_ids = $item.packs
        question = $question
        review_status = "pending"
        review_model = ""
        review_answer = ""
        review_verdict = ""
        reviewed_at = ""
    }
}
$out = [ordered]@{
    schema_version = "game004-review-queue-v1"
    baseline_version = "GAME004-BASELINE-V1"
    total = $reviews.Count
    items = $reviews
}
$out | ConvertTo-Json -Depth 8 | Set-Content (Join-Path $OutputRoot "review_queue.json") -Encoding UTF8
Write-Host "REVIEW_QUEUE_PASS total=$($reviews.Count)"
