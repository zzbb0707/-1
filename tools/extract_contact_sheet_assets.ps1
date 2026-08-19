param(
 [string]$Source=(Join-Path (Split-Path -Parent $PSScriptRoot) 'assets\candidates\atlas\GAME004_L1_objects_contact_sheet_candidate_v001.png'),
 [string]$OutputDir=(Join-Path (Split-Path -Parent $PSScriptRoot) 'assets\processed\candidate_objects_v001')
)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
New-Item -ItemType Directory -Force $OutputDir|Out-Null
$items=@(
 @{id='AS-GAME004-L1-RED-CIRCLE-SEED';name='red_circle_seed';box=@(24,130,170,305)},
 @{id='AS-GAME004-L1-BLUE-SQUARE-CRYSTAL';name='blue_square_crystal';box=@(182,125,360,310)},
 @{id='AS-GAME004-L1-YELLOW-STAR-LEAF';name='yellow_star_leaf';box=@(350,120,535,310)},
 @{id='AS-GAME004-L1-GREEN-TRIANGLE-STONE';name='green_triangle_stone';box=@(530,135,690,310)},
 @{id='AS-GAME004-L1-WHITE-ROUND-DROP';name='white_round_drop';box=@(690,150,845,310)},
 @{id='AS-GAME004-L1-PURPLE-SQUARE-TOOL';name='purple_square_tool';box=@(845,135,1018,320)},
 @{id='AS-GAME004-L1-FISH';name='fish';box=@(8,395,185,590)},
 @{id='AS-GAME004-L1-BIRD';name='bird';box=@(195,395,370,590)},
 @{id='AS-GAME004-L1-FLOWER';name='flower';box=@(370,395,540,590)},
 @{id='AS-GAME004-L1-HAMMER';name='hammer';box=@(530,380,730,610)},
 @{id='AS-GAME004-L1-APPLE';name='apple';box=@(680,395,840,590)},
 @{id='AS-GAME004-L1-TOY-CAR';name='toy_car';box=@(835,390,1020,610)},
 @{id='AS-GAME004-L1-CUP';name='cup';box=@(12,675,195,860)},
 @{id='AS-GAME004-L1-SHOE';name='shoe';box=@(185,675,370,860)},
 @{id='AS-GAME004-L1-LARGE-STONE';name='large_stone';box=@(350,650,550,870)},
 @{id='AS-GAME004-L1-SMALL-STONE';name='small_stone';box=@(545,720,670,860)},
 @{id='AS-GAME004-L1-ROUND-ICON';name='round_icon';box=@(680,675,840,860)},
 @{id='AS-GAME004-L1-SQUARE-ICON';name='square_icon';box=@(850,675,1018,875)}
)
$src=[Drawing.Bitmap]::new($Source)
$manifest=[ordered]@{schema_version='game004-asset-manifest-v1';baseline_version='GAME004-BASELINE-V1';source='GAME004_L1_objects_contact_sheet_candidate_v001.png';status='processed_candidate';rights_status='unknown';items=@()}
foreach($item in $items){$x=$item.box[0];$y=$item.box[1];$w=$item.box[2]-$x;$h=$item.box[3]-$y;$crop=[Drawing.Bitmap]::new($w,$h,[Drawing.Imaging.PixelFormat]::Format32bppArgb);$g=[Drawing.Graphics]::FromImage($crop);$g.DrawImage($src,(New-Object Drawing.Rectangle(0,0,$w,$h)),(New-Object Drawing.Rectangle($x,$y,$w,$h)),[Drawing.GraphicsUnit]::Pixel);$g.Dispose();for($px=0;$px -lt $crop.Width;$px++){for($py=0;$py -lt $crop.Height;$py++){$c=$crop.GetPixel($px,$py);if($c.R -lt 35 -and $c.G -lt 35 -and $c.B -lt 35){$crop.SetPixel($px,$py,[Drawing.Color]::FromArgb(0,$c.R,$c.G,$c.B))}}};$path=Join-Path $OutputDir ($item.name+'_v001.png');$crop.Save($path,[Drawing.Imaging.ImageFormat]::Png);$crop.Dispose();$manifest.items += [ordered]@{asset_id=$item.id;file=[IO.Path]::GetFileName($path);source_box=$item.box;status='processed_candidate';rights_status='unknown';alpha_cleanup='near-black-to-transparent'}};$src.Dispose();$manifest|ConvertTo-Json -Depth 8|Set-Content (Join-Path $OutputDir 'manifest.json') -Encoding UTF8;Write-Host "CONTACT_SHEET_EXTRACT_PASS items=$($items.Count)"
