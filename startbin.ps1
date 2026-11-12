# startbin.ps1 - downloads and starts the QB64 port of Wolfenstein 3-D (v1.4 shareware)
#
#   1. downloads WOLFS14.exe from the GitHub releases of the port
#   2. downloads the Wolfenstein 3-D v1.4 shareware from archive.org and unpacks its *.WL1 files
#   3. reports how it went and starts WOLFS14.exe
#
# Everything goes into the folder wolfs14\ next to this script. A step whose result is already
# there is skipped, so later runs just start the game. Run it with startbin.bat.
param(
    # The WOLFS14.exe asset of the latest release on https://github.com/iandevpro/wolf3dbas/releases
    # (GitHub redirects releases/latest/download/<file> to the newest release)
    [string]$ReleaseUrl = 'https://github.com/iandevpro/wolf3dbas/releases/latest/download/WOLFS14.exe'
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$ShareUrl = 'https://archive.org/download/wolf3dsw/wolf3dsw.zip'
$DataFiles = 'AUDIOHED.WL1', 'AUDIOT.WL1', 'GAMEMAPS.WL1', 'MAPHEAD.WL1',
             'VGADICT.WL1', 'VGAGRAPH.WL1', 'VGAHEAD.WL1', 'VSWAP.WL1'
$GameDir = Join-Path $PSScriptRoot 'wolfs14'
$Exe = Join-Path $GameDir 'WOLFS14.exe'
$Status = New-Object System.Collections.ArrayList

function Report([string]$step, [string]$result, [string]$detail = '') {
    $color = @{ 'OK' = 'Green'; 'skipped' = 'Gray'; 'FAILED' = 'Red' }[$result]
    Write-Host ('  {0,-34} {1,-8} {2}' -f $step, $result, $detail) -ForegroundColor $color
    [void]$Status.Add([pscustomobject]@{ Step = $step; Result = $result })
}

# Runs a native program. Its stderr (progress, warnings) must not stop the script, as it would
# in PowerShell 5.1 with $ErrorActionPreference = 'Stop'; the caller checks $LASTEXITCODE
function Invoke-Native([string]$exe) {
    $old = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try { & $exe @args } finally { $ErrorActionPreference = $old }
}

# Downloads url to file; curl.exe (Windows 10 and later) follows the redirects of archive.org
function Get-Download([string]$url, [string]$file) {
    if (Test-Path $file) { Remove-Item $file -Force }
    $curl = Get-Command curl.exe -ErrorAction SilentlyContinue
    if ($curl) {
        Invoke-Native $curl.Source -L -f -s -S --retry 2 -o $file $url
        if ($LASTEXITCODE -eq 0 -and (Test-Path $file)) { return }
        Write-Host "    curl failed (exit $LASTEXITCODE), trying Invoke-WebRequest"
    }
    Invoke-WebRequest -Uri $url -OutFile $file -UseBasicParsing -MaximumRedirection 10
}

function Test-Data { foreach ($f in $DataFiles) { if (-not (Test-Path (Join-Path $GameDir $f))) { return $false } }; $true }

# Unpacks only the *.WL1 files of the zip (not its DOS WOLF3D.EXE) into the game folder
function Expand-WL1([string]$zip) {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $archive = [System.IO.Compression.ZipFile]::OpenRead($zip)
    try {
        foreach ($entry in $archive.Entries) {
            if ($entry.Name -like '*.WL1') {
                [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, (Join-Path $GameDir $entry.Name.ToUpper()), $true)
            }
        }
    } finally { $archive.Dispose() }
}

function Start-Game {
    Write-Host "Starting $Exe"
    Start-Process -FilePath $Exe -WorkingDirectory $GameDir
}

# Later runs: everything is there
if ((Test-Path $Exe) -and (Test-Data)) {
    Write-Host 'Wolfenstein 3-D (v1.4 shareware) is installed in' $GameDir
    Start-Game
    exit 0
}

Write-Host "Installing Wolfenstein 3-D (v1.4 shareware) into $GameDir"
New-Item -ItemType Directory -Force -Path $GameDir | Out-Null

# 1. the port
if (Test-Path $Exe) {
    Report 'Download WOLFS14.exe' 'skipped' 'already there'
} elseif ($ReleaseUrl -match '<TAG>') {
    Report 'Download WOLFS14.exe' 'FAILED' 'the release URL in startbin.ps1 is still a placeholder'
} else {
    try {
        Get-Download $ReleaseUrl $Exe
        Report 'Download WOLFS14.exe' 'OK' $ReleaseUrl
    } catch {
        if (Test-Path $Exe) { Remove-Item $Exe -Force }
        Report 'Download WOLFS14.exe' 'FAILED' $_.Exception.Message
    }
}

# 2. the shareware data
if (Test-Data) {
    Report 'Download the shareware data' 'skipped' 'already there'
    Report 'Unpack the *.WL1 files' 'skipped' 'already there'
} else {
    $zip = Join-Path $GameDir 'wolf3dsw.zip'
    try {
        Get-Download $ShareUrl $zip
        Report 'Download the shareware data' 'OK' $ShareUrl
        try {
            Expand-WL1 $zip
            if (Test-Data) { Report 'Unpack the *.WL1 files' 'OK' } else { Report 'Unpack the *.WL1 files' 'FAILED' 'some *.WL1 files are missing in the zip' }
        } catch { Report 'Unpack the *.WL1 files' 'FAILED' $_.Exception.Message }
    } catch { Report 'Download the shareware data' 'FAILED' $_.Exception.Message }
    if (Test-Path $zip) { Remove-Item $zip -Force }
}

# 3. the result
$failed = @($Status | Where-Object { $_.Result -eq 'FAILED' }).Count
if ($failed -eq 0 -and (Test-Path $Exe) -and (Test-Data)) {
    Write-Host 'All steps went OK.' -ForegroundColor Green
    Start-Game
    exit 0
}
Write-Host "$failed step(s) failed; run startbin.bat again after fixing the cause." -ForegroundColor Red
exit 1
