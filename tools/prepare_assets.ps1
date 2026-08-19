param([string]$ProjectPath = (Split-Path -Parent $PSScriptRoot))
$ErrorActionPreference = 'Stop'
$root = Join-Path $ProjectPath 'assets/candidates/image2/assets_v001'
$out = Join-Path $ProjectPath 'assets/processed/v001'
New-Item -ItemType Directory -Force $out | Out-Null
Add-Type -AssemblyName System.Drawing
$files = Get-ChildItem $root -Filter '*.png' | Sort-Object Name
foreach($file in $files){
  $src=[Drawing.Bitmap]::new($file.FullName)
  $dst=[Drawing.Bitmap]::new($src.Width,$src.Height,[Drawing.Imaging.PixelFormat]::Format32bppArgb)
  for($y=0;$y -lt $src.Height;$y++){ for($x=0;$x -lt $src.Width;$x++){
    $p=$src.GetPixel($x,$y)
    $nearBlack=($p.R -lt 12 -and $p.G -lt 12 -and $p.B -lt 12)
    if($nearBlack){ $dst.SetPixel($x,$y,[Drawing.Color]::FromArgb(0,$p.R,$p.G,$p.B)) }
    else { $dst.SetPixel($x,$y,$p) }
  }}
  $path=Join-Path $out $file.Name
  $dst.Save($path,[Drawing.Imaging.ImageFormat]::Png); $dst.Dispose(); $src.Dispose()
}
Write-Host "ASSET_PREPARE_PASS $out"
