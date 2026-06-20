# Generates the SriAi white-label icon / favicon set using .NET System.Drawing.
# Run from the repo root:  powershell -ExecutionPolicy Bypass -File sriai/branding/generate-icons.ps1
Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path   # ...\sriai\branding
$addon = Split-Path -Parent $here                          # ...\sriai

# Brand palette
$c1 = [System.Drawing.ColorTranslator]::FromHtml('#14B8A6')  # teal
$c2 = [System.Drawing.ColorTranslator]::FromHtml('#6366F1')  # indigo

function New-RoundedPath([int]$size, [single]$radius) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $radius * 2
    $path.AddArc(0, 0, $d, $d, 180, 90)
    $path.AddArc($size - $d, 0, $d, $d, 270, 90)
    $path.AddArc($size - $d, $size - $d, $d, $d, 0, 90)
    $path.AddArc(0, $size - $d, $d, $d, 90, 90)
    $path.CloseFigure()
    return $path
}

function New-IconBitmap([int]$size, [string]$text) {
    $bmp = New-Object System.Drawing.Bitmap($size, $size)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias
    $g.Clear([System.Drawing.Color]::Transparent)

    $rect = New-Object System.Drawing.Rectangle(0, 0, $size, $size)
    $radius = [single]($size * 0.22)
    $path = New-RoundedPath $size $radius
    $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $c1, $c2, 45.0)
    $g.FillPath($brush, $path)

    # Monogram text
    $fontSize = [single]($size * 0.52)
    $font = New-Object System.Drawing.Font('Segoe UI', $fontSize, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
    $fmt = New-Object System.Drawing.StringFormat
    $fmt.Alignment = [System.Drawing.StringAlignment]::Center
    $fmt.LineAlignment = [System.Drawing.StringAlignment]::Center
    $white = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $layout = New-Object System.Drawing.RectangleF(0, [single]($size * -0.03), $size, $size)
    $g.DrawString($text, $font, $white, $layout, $fmt)

    $brush.Dispose(); $font.Dispose(); $white.Dispose(); $path.Dispose(); $g.Dispose()
    return $bmp
}

function Save-Png([System.Drawing.Bitmap]$bmp, [string]$path) {
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    Write-Host "wrote $path"
}

# --- favicon / logo set used by apply-branding.sh (monogram "S") ---
$monogram = 'S'
$sizes = @(512, 192, 180, 96, 32)
foreach ($s in $sizes) {
    $b = New-IconBitmap $s $monogram
    Save-Png $b (Join-Path $here ("icon-{0}.png" -f $s))
    if ($s -eq 512) { Save-Png $b (Join-Path $here 'splash.png') }
    $b.Dispose()
}

# --- favicon.ico (64px, 32-bit PNG-embedded ICO for full-color gradient) ---
$icoBmp = New-IconBitmap 64 $monogram
$ms = New-Object System.IO.MemoryStream
$icoBmp.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
$png = $ms.ToArray()
$ms.Dispose(); $icoBmp.Dispose()

$icoPath = Join-Path $here 'favicon.ico'
$out = New-Object System.IO.BinaryWriter([System.IO.File]::Open($icoPath, [System.IO.FileMode]::Create))
# ICONDIR
$out.Write([UInt16]0); $out.Write([UInt16]1); $out.Write([UInt16]1)
# ICONDIRENTRY
$out.Write([Byte]64); $out.Write([Byte]64); $out.Write([Byte]0); $out.Write([Byte]0)
$out.Write([UInt16]1); $out.Write([UInt16]32)
$out.Write([UInt32]$png.Length); $out.Write([UInt32]22)
# PNG payload
$out.Write($png)
$out.Close()
Write-Host "wrote $icoPath"

# --- Home Assistant add-on store icon (sriai/icon.png, 256px) ---
$store = New-IconBitmap 256 $monogram
Save-Png $store (Join-Path $addon 'icon.png')
$store.Dispose()

# --- Home Assistant add-on store logo (sriai/logo.png, 512px) ---
$logo = New-IconBitmap 512 $monogram
Save-Png $logo (Join-Path $addon 'logo.png')
$logo.Dispose()

Write-Host 'SriAi icon set generated.'
