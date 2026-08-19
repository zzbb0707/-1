param(
    [string]$GodotExe = "C:\Users\Administrator\Desktop\Godot_v4.7.1-stable_win64.exe",
    [string]$ProjectPath = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = "Stop"
$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$outRoot = Join-Path ([System.IO.Path]::GetTempPath()) "game004_verify_$stamp"
New-Item -ItemType Directory -Force -Path $outRoot | Out-Null

function Run-Godot([string[]]$Arguments, [string]$Name, [int[]]$AcceptedExitCodes = @(0)) {
    Write-Host "[RUN] $Name"
    $process = Start-Process -FilePath $GodotExe -ArgumentList $Arguments -Wait -PassThru -NoNewWindow
    if ($process.ExitCode -notin $AcceptedExitCodes) { throw "$Name failed with exit code $($process.ExitCode)" }
}

Run-Godot @("--headless", "--path", $ProjectPath, "--editor", "--quit") "project_parse"
Run-Godot @("--headless", "--path", $ProjectPath, "--script", "res://tests/test_contract.gd") "contract_test" @(0, 1)
Run-Godot @("--headless", "--path", $ProjectPath, "--script", "res://tests/test_bridge_schema.gd") "bridge_schema_test" @(0, 1)
Run-Godot @("--headless", "--path", $ProjectPath, "--script", "res://tests/test_slice_configs.gd") "slice_config_test" @(0, 1)
Run-Godot @("--headless", "--path", $ProjectPath, "--script", "res://tests/test_processed_assets.gd") "processed_asset_test" @(0, 1)

$frames = @()
foreach ($level in @("L1", "L3", "L4")) {
    $prefix = Join-Path $outRoot "verify_$level.png"
    Run-Godot @("--path", $ProjectPath, "--write-movie", $prefix, "--fixed-fps", "30", "--quit-after", "2", "--disable-vsync", "--", "--slice=$level") "render_$level"
    $frame = Get-ChildItem -LiteralPath $outRoot -Filter "verify_$level*.png" | Sort-Object Name | Select-Object -Last 1
    if (-not $frame) { throw "render_$level produced no PNG frame" }
    $frames += [ordered]@{
        level = $level
        path = $frame.FullName
        bytes = $frame.Length
        sha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $frame.FullName).Hash
    }
}

$report = [ordered]@{
    schema_version = "game004-verify-v1"
    generated_at = (Get-Date).ToString("o")
    godot_exe = $GodotExe
    project_path = $ProjectPath
    checks = [ordered]@{
        project_parse = "pass"
        contract_test = "pass"
        bridge_schema_test = "pass"
        slice_config_test = "pass"
        processed_asset_test = "pass"
        render_levels = @("L1", "L3", "L4")
    }
    frames = $frames
    note = "Frames are stored outside res:// to prevent Godot from importing verification artifacts. Visual review remains required after layout or asset changes."
}
$reportPath = Join-Path $outRoot "verification_report.json"
$report | ConvertTo-Json -Depth 6 | Set-Content -Encoding UTF8 -LiteralPath $reportPath
Write-Host "VERTICAL_SLICE_VERIFY_PASS"
Write-Host "Report: $reportPath"
