param(
    [Parameter(Mandatory = $true)][string]$SourcePath,
    [Parameter(Mandatory = $true)][string]$WebRoot
)

# Regenere les icones web / PWA a partir du logo SARIBAO.
# Les icones maskable sont generees avec la meme marge de securite que les
# icones adaptatives Android, le launcher web rognant lui aussi les bords.

Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = 'Stop'

$logo = [System.Drawing.Image]::FromFile($SourcePath)

function Write-Icon {
    param(
        [string]$Path,
        [int]$Size,
        [double]$LogoRatio,
        [bool]$Opaque
    )

    $inner = [int][Math]::Round($Size * $LogoRatio)
    $offset = [int][Math]::Round(($Size - $inner) / 2)

    $bitmap = New-Object System.Drawing.Bitmap(
        $Size, $Size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

    if ($Opaque) {
        $graphics.Clear([System.Drawing.Color]::White)
    } else {
        $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
        $graphics.Clear([System.Drawing.Color]::Transparent)
        $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceOver
    }

    $graphics.DrawImage($logo, $offset, $offset, $inner, $inner)
    $graphics.Dispose()

    $parent = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent | Out-Null
    }

    $bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    $bitmap.Dispose()
    Write-Output "$([System.IO.Path]::GetFileName($Path)) ($Size px)"
}

$iconsDir = Join-Path $WebRoot 'icons'

Write-Icon -Path (Join-Path $iconsDir 'Icon-192.png') -Size 192 -LogoRatio 0.86 -Opaque $true
Write-Icon -Path (Join-Path $iconsDir 'Icon-512.png') -Size 512 -LogoRatio 0.86 -Opaque $true
Write-Icon -Path (Join-Path $iconsDir 'Icon-maskable-192.png') -Size 192 -LogoRatio 0.58 -Opaque $false
Write-Icon -Path (Join-Path $iconsDir 'Icon-maskable-512.png') -Size 512 -LogoRatio 0.58 -Opaque $false
Write-Icon -Path (Join-Path $WebRoot 'favicon.png') -Size 32 -LogoRatio 0.90 -Opaque $true

$logo.Dispose()