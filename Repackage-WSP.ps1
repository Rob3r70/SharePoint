<#
.SYNOPSIS
  Repackages an extracted SharePoint solution folder back into a .wsp (CAB) file.

.EXAMPLE
  .\Repack-Wsp.ps1 -SourceFolder "C:\work\MySolution_extracted" -OutputWsp "C:\work\MySolution_fixed.wsp"
#>
param(
    [Parameter(Mandatory = $true)][string]$SourceFolder,
    [Parameter(Mandatory = $true)][string]$OutputWsp
)

$ErrorActionPreference = 'Stop'

$src = (Resolve-Path $SourceFolder).Path.TrimEnd('\')
$manifest = Join-Path $src 'manifest.xml'
if (-not (Test-Path $manifest)) {
    throw "manifest.xml not found in $src - the WSP root must contain manifest.xml."
}

$outFull = [System.IO.Path]::GetFullPath($OutputWsp)
$outDir  = Split-Path $outFull -Parent
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }
if (Test-Path $outFull) { Remove-Item $outFull -Force }

# Build in a scratch folder so the DDF never needs paths with spaces/quotes for output
$work = Join-Path $env:TEMP ("wspbuild_" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $work | Out-Null
$ddf = Join-Path $work 'build.ddf'

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('.OPTION EXPLICIT')
$lines.Add('.Set Cabinet=on')
$lines.Add('.Set Compress=on')
$lines.Add('.Set CompressionType=MSZIP')
$lines.Add('.Set MaxDiskSize=0')
$lines.Add('.Set CabinetNameTemplate=package.wsp')
$lines.Add('.Set DiskDirectory1=.')
$lines.Add('.Set InfFileName=nul')
$lines.Add('.Set RptFileName=nul')

# manifest.xml first, then everything else; relative paths are preserved inside the cab
$files = Get-ChildItem -LiteralPath $src -Recurse -File -Force
$ordered = @($files | Where-Object { $_.FullName -eq $manifest }) +
           @($files | Where-Object { $_.FullName -ne $manifest })

foreach ($f in $ordered) {
    $rel = $f.FullName.Substring($src.Length + 1)
    $lines.Add(('"{0}" "{1}"' -f $f.FullName, $rel))
}

# makecab reads the DDF in the system ANSI code page: no BOM, no UTF-16, CRLF line endings
try { [System.Text.Encoding]::RegisterProvider([System.Text.CodePagesEncodingProvider]::Instance) } catch {}
$enc = [System.Text.Encoding]::GetEncoding([System.Globalization.CultureInfo]::CurrentCulture.TextInfo.ANSICodePage)
[System.IO.File]::WriteAllText($ddf, (($lines -join "`r`n") + "`r`n"), $enc)

Push-Location $work
try {
    & makecab.exe /F $ddf | Out-Host
    if ($LASTEXITCODE -ne 0) { throw "makecab failed with exit code $LASTEXITCODE (DDF kept at $ddf)" }
    Move-Item -LiteralPath (Join-Path $work 'package.wsp') -Destination $outFull -Force
}
finally {
    Pop-Location
}

Remove-Item $work -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "Created: $outFull" -ForegroundColor Green
