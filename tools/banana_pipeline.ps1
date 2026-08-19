# GAME-004 Banana 素材批量生产流水线
# 流程：提交任务 -> 轮询 -> 下载 -> Atlas视觉审核 -> 登记manifest -> 拆分为processed
param(
    [string]$SpecPath = "D:\deepseek\yunxiaoxing-game004\handoff\asset_production_v001\20pack_batch_spec.json",
    [string]$OutputRoot = "D:\deepseek\yunxiaoxing-game004\assets\candidates\banana"
)
$ErrorActionPreference = 'Stop'
$spec = Get-Content -Raw $SpecPath -Encoding UTF8 | ConvertFrom-Json
$pending = @()
foreach ($pack in $spec.packs) {
    $dir = Join-Path $OutputRoot $pack.game_pack_id
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    foreach ($target in $pack.targets) {
        $pending += [ordered]@{
            game_pack_id = $pack.game_pack_id
            kind = "object"
            label = $target
            prompt = "GAME-004 approved art direction, warm ivory and sage-green habitat pod, rounded toy-like 3D animated-film render, soft diffuse lighting, gentle child-friendly forms, clear semantic silhouette, no text, no pseudo-UI, no watermark. Isolated runtime object asset for '$target', single centered object, front three-quarter view, soft shadow, same material language as the master set (vivid matte colors, rounded toy forms), warm ivory background, no labels, no borders."
        }
    }
    foreach ($region in $pack.regions) {
        $pending += [ordered]@{
            game_pack_id = $pack.game_pack_id
            kind = "region"
            label = $region
            prompt = "GAME-004 approved art direction, warm ivory and sage-green habitat pod, rounded toy-like 3D animated-film render, soft diffuse lighting, gentle child-friendly forms, clear semantic silhouette, no text, no pseudo-UI, no watermark. Isolated rounded diorama habitat region tile for '$region', front three-quarter view, same material language as the master set, low visual density, warm ivory background, no labels, no borders."
        }
    }
    foreach ($outcome in $pack.outcomes) {
        $pending += [ordered]@{
            game_pack_id = $pack.game_pack_id
            kind = "outcome"
            label = $outcome
            prompt = "GAME-004 approved art direction, warm ivory and sage-green habitat pod, rounded toy-like 3D animated-film render, soft diffuse lighting, gentle child-friendly forms, clear semantic silhouette, no text, no pseudo-UI, no watermark. Compact natural ecosystem result state icon for '$outcome', same material language as the master set, no fireworks, no particles, warm ivory background, no labels, no borders."
        }
    }
}
$out = [ordered]@{
    schema_version = "game004-banana-submission-queue-v1"
    baseline_version = "GAME004-BASELINE-V1"
    model = "google/nano-banana-pro/text-to-image"
    estimated_cost = [math]::Round($pending.Count * 0.14, 2)
    items = $pending
}
$out | ConvertTo-Json -Depth 6 | Set-Content (Join-Path $OutputRoot "submission_queue.json") -Encoding UTF8
Write-Host "BANANA_SUBMISSION_QUEUE_PASS items=$($pending.Count) estimated_cost=$([math]::Round($pending.Count*0.14,2))"
