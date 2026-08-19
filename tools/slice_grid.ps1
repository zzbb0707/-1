param(
    [string]$Source = "",
    [string]$OutputDir = "D:\deepseek\yunxiaoxing-game004\assets\candidates\banana\sliced",
    [int]$Rows = 3,
    [int]$Cols = 3,
    [string]$Prefix = "slice"
)
# Slices a grid contact sheet into individual assets with transparent padding trim
Add-Type -AssemblyName System.Drawing
if (-not $Source -or -not (Test-Path $Source)) { Write-Error "Source required"; exit 1 }
New-Item -ItemType Directory -Force $OutputDir | Out-Null
$bmp = [Drawing.Bitmap]::new($Source)
$cellW = [int]($bmp.Width / $Cols)
$cellH = [int]($bmp.Height / $Rows)
$saved = 0
for ($r = 0; $r -lt $Rows; $r++) {
    for ($c = 0; $c -lt $Cols; $c++) {
        $x = $c * $cellW; $y = $r * $cellH
        $crop = [Drawing.Bitmap]::new($cellW, $cellH, [Drawing.Imaging.PixelFormat]::Format32bppArgb)
        $g = [Drawing.Graphics]::FromImage($crop)
        $g.DrawImage($bmp, (New-Object Drawing.Rectangle(0, 0, $cellW, $cellH)), (New-Object Drawing.Rectangle($x, $y, $cellW, $cellH)), [Drawing.GraphicsUnit]::Pixel)
        $g.Dispose()
        $idx = $r * $Cols + $c + 1
        $path = Join-Path $OutputDir ("{0}_{1:D2}.png" -f $Prefix, $idx)
        $crop.Save($path, [Drawing.Imaging.ImageFormat]::Png)
        $crop.Dispose()
        $saved++
    }
}
$bmp.Dispose()
Write-Host "GRID_SLICE_PASS saved=$saved from=$($bmp.Width)x$($bmp.Height) cells=${Cols}x${Rows}"
