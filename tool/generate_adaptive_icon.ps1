param(
    [Parameter(Mandatory = $true)][string]$SourcePath,
    [Parameter(Mandatory = $true)][string]$ResRoot,
    [double]$SafeRatio = 0.60
)

# Genere les calques `foreground` des icones adaptatives Android.
#
# Une icone adaptative fait 108 dp. Android masque jusqu'a 66 dp au centre
# (les 18 dp de chaque cote peuvent etre rognes selon la forme du masque) :
# le logo doit donc tenir dans les 72 dp centraux, ici $SafeRatio.

Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = 'Stop'

$sizes = [ordered]@{
    'mipmap-mdpi'    = 108
    'mipmap-hdpi'    = 162
    'mipmap-xhdpi'   = 216
    'mipmap-xxhdpi'  = 324
    'mipmap-xxxhdpi' = 432
}

$logo = [System.Drawing.Image]::FromFile($SourcePath)

foreach ($dir in $sizes.Keys) {
    $size = [int]$sizes[$dir]
    $target_dir = Join-Path $ResRoot $dir
    if (-not (Test-Path -LiteralPath $target_dir)) {
        New-Item -ItemType Directory -Path $target_dir | Out-Null
    }

    $inner = [int][Math]::Round($size * $SafeRatio)
    $offset = [int][Math]::Round(($size - $inner) / 2)

    # 32bppArgb : le calque avant doit rester transparent hors logo.
    $bitmap = New-Object System.Drawing.Bitmap(
        $size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
    $graphics.Clear([System.Drawing.Color]::Transparent)
    $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceOver
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphics.DrawImage($logo, $offset, $offset, $inner, $inner)
    $graphics.Dispose()

    $target = Join-Path $target_dir 'ic_launcher_foreground.png'
    $bitmap.Save($target, [System.Drawing.Imaging.ImageFormat]::Png)
    $bitmap.Dispose()

    Write-Output "$dir/ic_launcher_foreground.png ($size px, logo ${inner}px)"
}

$logo.Dispose()