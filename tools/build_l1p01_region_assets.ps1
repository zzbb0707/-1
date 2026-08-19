param(
 [string]$OutputDir=(Join-Path (Split-Path -Parent $PSScriptRoot) 'assets\processed\regions_l1p01_v001')
)
Add-Type -AssemblyName System.Drawing
New-Item -ItemType Directory -Force $OutputDir|Out-Null
$spec=@(
 @{id='REG-GF03-L1-P01-R01';name='red_circle_zone';color='#BD5A56';symbol='circle';outcome='sprout'},
 @{id='REG-GF03-L1-P01-R02';name='blue_square_zone';color='#3F83AD';symbol='square';outcome='light'},
 @{id='REG-GF03-L1-P01-R03';name='yellow_star_zone';color='#B99135';symbol='star';outcome='leaf'},
 @{id='REG-GF03-L1-P01-R04';name='green_triangle_zone';color='#5B956E';symbol='triangle';outcome='stone'},
 @{id='REG-GF03-L1-P01-R05';name='white_drop_zone';color='#9DB5BF';symbol='drop';outcome='water'},
 @{id='REG-GF03-L1-P01-R06';name='purple_tool_zone';color='#8274AA';symbol='square';outcome='workbench'}
)
$manifest=[ordered]@{schema_version='game004-region-state-v1';baseline_version='GAME004-BASELINE-V1';status='processed_candidate';rights_status='unknown';items=@()}
foreach($s in $spec){$bmp=[Drawing.Bitmap]::new(256,256,[Drawing.Imaging.PixelFormat]::Format32bppArgb);$g=[Drawing.Graphics]::FromImage($bmp);$g.SmoothingMode='AntiAlias';$c=[Drawing.ColorTranslator]::FromHtml($s.color);$g.FillEllipse([Drawing.SolidBrush]::new($c),24,24,208,208);$g.DrawEllipse([Drawing.Pen]::new([Drawing.Color]::FromArgb(220,255,255,245),7),27,27,202,202);$g.FillEllipse([Drawing.SolidBrush]::new([Drawing.Color]::FromArgb(55,255,255,255)),60,55,100,55); switch($s.symbol){'circle'{$g.FillEllipse([Drawing.Brushes]::White,93,93,70,70)}'square'{$g.FillRectangle([Drawing.Brushes]::White,94,94,68,68)}'triangle'{$pts=@([Drawing.Point]::new(128,85),[Drawing.Point]::new(170,165),[Drawing.Point]::new(86,165));$g.FillPolygon([Drawing.Brushes]::White,$pts)}'star'{$pts=@();for($i=0;$i -lt 10;$i++){$a=(-90+$i*36)*[math]::PI/180;$r=20;if($i%2 -eq 0){$r=45};$pts += [Drawing.Point]::new(128+[int]($r*[math]::Cos($a)),128+[int]($r*[math]::Sin($a)))};$g.FillPolygon([Drawing.Brushes]::White,$pts)}'drop'{$g.FillEllipse([Drawing.Brushes]::White,92,106,72,70);$pts=@([Drawing.Point]::new(128,78),[Drawing.Point]::new(166,128),[Drawing.Point]::new(90,128));$g.FillPolygon([Drawing.Brushes]::White,$pts)}};$g.Dispose();$path=Join-Path $OutputDir ($s.name+'_idle_v001.png');$bmp.Save($path,[Drawing.Imaging.ImageFormat]::Png);$bmp.Dispose();$manifest.items += [ordered]@{region_asset_id=$s.id;file=[IO.Path]::GetFileName($path);outcome=$s.outcome;status='processed_candidate'}};$manifest|ConvertTo-Json -Depth 6|Set-Content (Join-Path $OutputDir 'manifest.json') -Encoding UTF8;Write-Host 'L1P01_REGION_ASSETS_BUILD_PASS count=6'
