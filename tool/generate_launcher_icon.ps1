param(
    [Parameter(Mandatory = $true)][string]$SourcePath,
    [Parameter(Mandatory = $true)][string]$ResRoot,
    [int]$PadRatio = 0.10
)

# Genere les icones de lanceur Android a partir d'un PNG transparent.
# Les icones legacy sont carrees et ne doivent pas avoir de transparence :
# le logo est donc centre, reduit pour respirer, et pose sur un fond blanc.

Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = 'Stop'

$sizes = [ordered]@{
    'mipmap-mdpi'    = 48
    'mipmap-hdpi'    = 72
    'mipmap-xhdpi'   = 96
    'mipmap-xxhdpi'  = 144
    'mipmap-xxxhdpi' = 192
}

$logo = [System.Drawing.Image]::FromFile($SourcePath)

foreach ($dir in $sizes.Keys) {
    $size = [int]$sizes[$dir]
    $target_dir = Join-Path $ResRoot $dir
    if (-not (Test-Path -LiteralPath $target_dir)) {
        New-Item -ItemType Directory -Path $target_dir | Out-Null
    }

    $inner = [int][Math]::Round($size * (1 - $PadRatio))
    $offset = [int][Math]::Round(($size - $inner) / 2)

    $bitmap = New-Object System.Drawing.Bitmap($size, $size)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $graphics.Clear([System.Drawing.Color]::White)
    $graphics.DrawImage($logo, $offset, $offset, $inner, $inner)
    $graphics.Dispose()

    $target = Join-Path $target_dir 'ic_launcher.png'
    $bitmap.Save($target, [System.Drawing.Imaging.ImageFormat]::Png)
    $bitmap.Dispose()

    Write-Output "$dir/ic_launcher.png ($size px)"
}

$logo.Dispose()