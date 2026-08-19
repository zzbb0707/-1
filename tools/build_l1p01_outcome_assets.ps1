param(
 [string]$OutputDir=(Join-Path (Split-Path -Parent $PSScriptRoot) 'assets\processed\outcomes_l1p01_v001')
)
Add-Type -AssemblyName System.Drawing
New-Item -ItemType Directory -Force $OutputDir|Out-Null
$items=@(
 @{id='OUT-GF03-L1-P01-R01';name='sprout';label='sprout';color='#76a85f';shape='sprout'},
 @{id='OUT-GF03-L1-P01-R02';name='lamp';label='lamp';color='#dcae47';shape='lamp'},
 @{id='OUT-GF03-L1-P01-R03';name='leaf';label='leaf';color='#76a85f';shape='leaf'},
 @{id='OUT-GF03-L1-P01-R04';name='stone';label='stone';color='#7c8b7d';shape='stone'},
 @{id='OUT-GF03-L1-P01-R05';name='water';label='water';color='#5ba3c2';shape='water'},
 @{id='OUT-GF03-L1-P01-R06';name='workbench';label='workbench';color='#8a78a8';shape='tool'}
)
$manifest=[ordered]@{schema_version='game004-natural-outcome-v1';baseline_version='GAME004-BASELINE-V1';status='processed_candidate';rights_status='unknown';items=@()}
foreach($item in $items){$bmp=[Drawing.Bitmap]::new(192,192,[Drawing.Imaging.PixelFormat]::Format32bppArgb);$g=[Drawing.Graphics]::FromImage($bmp);$g.SmoothingMode='AntiAlias';$c=[Drawing.ColorTranslator]::FromHtml($item.color);$b=[Drawing.SolidBrush]::new($c);switch($item.shape){'sprout'{$g.FillEllipse($b,38,80,54,34);$g.FillEllipse($b,98,52,58,36);$g.FillRectangle($b,89,92,13,58);$g.FillEllipse($b,72,112,50,22)}'lamp'{$g.FillEllipse($b,48,37,96,96);$g.FillRectangle($b,76,128,40,18);$g.FillRectangle($b,66,148,60,16)}'leaf'{$g.FillEllipse($b,28,75,105,52);$g.FillEllipse($b,70,42,92,54);$g.FillRectangle($b,91,95,11,63)}'stone'{$g.FillEllipse($b,25,92,142,60);$g.FillEllipse([Drawing.Brushes]::White,75,108,24,12)}'water'{$g.FillEllipse($b,23,104,146,46);$g.FillEllipse($b,53,74,86,42);$g.FillEllipse([Drawing.Brushes]::White,78,87,20,12)}'tool'{$g.FillRectangle($b,28,118,136,30);$g.FillRectangle($b,78,52,34,72);$g.FillEllipse($b,58,34,74,40)}};$g.Dispose();$path=Join-Path $OutputDir ($item.name+'_result_v001.png');$bmp.Save($path,[Drawing.Imaging.ImageFormat]::Png);$bmp.Dispose();$manifest.items += [ordered]@{outcome_asset_id=$item.id;file=[IO.Path]::GetFileName($path);label=$item.label;status='processed_candidate'}};$manifest|ConvertTo-Json -Depth 5|Set-Content (Join-Path $OutputDir 'manifest.json') -Encoding UTF8;Write-Host 'L1P01_OUTCOME_ASSETS_BUILD_PASS count=6'
