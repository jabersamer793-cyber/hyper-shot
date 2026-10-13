# Draws the app icons used by the install manifest (icons/*.png). Re-run after changing the design:
#   powershell -ExecutionPolicy Bypass -File tools/make-icons.ps1
Add-Type -AssemblyName System.Drawing
$root = Split-Path -Parent $PSScriptRoot
$out = Join-Path $root 'icons'
New-Item -ItemType Directory -Force $out | Out-Null

function Draw-Icon([int]$size, [string]$file, [double]$logoScale) {
  $bmp = New-Object System.Drawing.Bitmap $size, $size
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = 'AntiAlias'; $g.TextRenderingHint = 'AntiAliasGridFit'; $g.InterpolationMode = 'HighQualityBicubic'
  # full-bleed background (works as a maskable icon: the logo stays inside the safe zone)
  $rect = New-Object System.Drawing.Rectangle 0, 0, $size, $size
  $path = New-Object System.Drawing.Drawing2D.GraphicsPath; $path.AddEllipse(-$size * 0.35, -$size * 0.45, $size * 1.7, $size * 1.5)
  $bg = New-Object System.Drawing.Drawing2D.PathGradientBrush $path
  $bg.CenterColor = [System.Drawing.Color]::FromArgb(255, 32, 52, 140); $bg.SurroundColors = @([System.Drawing.Color]::FromArgb(255, 7, 10, 24))
  $g.FillRectangle((New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 7, 10, 24))), $rect); $g.FillRectangle($bg, $rect)
  $c = $size / 2.0; $L = $size * $logoScale
  # crosshair ring + ticks
  $cyan = [System.Drawing.Color]::FromArgb(255, 0, 229, 255)
  $glow = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(70, 0, 229, 255)), ($L * 0.09)
  $pen = New-Object System.Drawing.Pen $cyan, ($L * 0.035)
  $r = $L * 0.46
  $g.DrawEllipse($glow, [float]($c - $r), [float]($c - $r), [float](2 * $r), [float](2 * $r))
  $g.DrawEllipse($pen, [float]($c - $r), [float]($c - $r), [float](2 * $r), [float](2 * $r))
  $t1 = $r * 0.78; $t2 = $r * 1.18
  foreach ($a in 0, 90, 180, 270) { $rad = $a * [Math]::PI / 180
    $g.DrawLine($pen, [float]($c + [Math]::Cos($rad) * $t1), [float]($c + [Math]::Sin($rad) * $t1), [float]($c + [Math]::Cos($rad) * $t2), [float]($c + [Math]::Sin($rad) * $t2)) }
  # "HS" monogram: white H, cyan S
  $font = New-Object System.Drawing.Font 'Arial Black', ([float]($L * 0.36)), ([System.Drawing.FontStyle]::Bold), ([System.Drawing.GraphicsUnit]::Pixel)
  $sf = New-Object System.Drawing.StringFormat; $sf.Alignment = 'Center'; $sf.LineAlignment = 'Center'
  $wH = $g.MeasureString('H', $font).Width * 0.78; $wS = $g.MeasureString('S', $font).Width * 0.78
  $x0 = $c - ($wH + $wS) / 2; $y = $c + $L * 0.02
  $shadow = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(140, 0, 0, 0))
  $g.DrawString('H', $font, $shadow, [float]($x0 + $wH / 2 + $L * 0.012), [float]($y + $L * 0.018), $sf)
  $g.DrawString('S', $font, $shadow, [float]($x0 + $wH + $wS / 2 + $L * 0.012), [float]($y + $L * 0.018), $sf)
  $g.DrawString('H', $font, [System.Drawing.Brushes]::White, [float]($x0 + $wH / 2), [float]$y, $sf)
  $g.DrawString('S', $font, (New-Object System.Drawing.SolidBrush $cyan), [float]($x0 + $wH + $wS / 2), [float]$y, $sf)
  $bmp.Save((Join-Path $out $file), [System.Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose(); $bmp.Dispose()
  Write-Host "icons/$file ($size px)"
}
Draw-Icon 192 'icon-192.png' 0.86
Draw-Icon 512 'icon-512.png' 0.86
Draw-Icon 512 'icon-maskable-512.png' 0.62   # logo inside the 80% safe zone for Android adaptive masks
Draw-Icon 180 'apple-touch-icon.png' 0.80
Draw-Icon 32 'favicon-32.png' 0.95
