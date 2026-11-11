# startsrc.ps1 - builds the QB64 port of Wolfenstein 3-D from source and starts it (v1.4 shareware)
#
#   1. gets the source from https://github.com/iandevpro/wolf3dbas: git clone over HTTPS, then
#      over SSH (git@github.com, for an account with access while the repository is private),
#      then the zip of the main branch; run inside a checkout, it uses that checkout
#   2. downloads QB64 2.1 and unpacks it into qb64\
#   3. downloads the Wolfenstein 3-D v1.4 shareware from archive.org and unpacks its *.WL1 files
#   4. compiles basicsrc\WOLFS14.BAS into wolfs14\WOLFS14.exe
#   5. reports how it went and starts WOLFS14.exe
#
# Everything goes into folders next to this script: wolf3dbas\ (the source), qb64\ and
# wolfs14\ (the game). A step whose result is already there is skipped, so later runs just
# start the game. Run it with startsrc.bat.

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$RepoUrl = 'https://github.com/iandevpro/wolf3dbas.git'
$RepoSshUrl = 'git@github.com:iandevpro/wolf3dbas.git'
$RepoZipUrl = 'https://github.com/iandevpro/wolf3dbas/archive/refs/heads/main.zip'
$QB64Url = 'https://github.com/QB64Official/qb64/releases/download/v2.1/qb64_dev_2022-09-08-07-14-00_47f5044_win-x64.7z'
$SevenZrUrl = 'https://www.7-zip.org/a/7zr.exe'
$ShareUrl = 'https://archive.org/download/wolf3dsw/wolf3dsw.zip'
$DataFiles = 'AUDIOHED.WL1', 'AUDIOT.WL1', 'GAMEMAPS.WL1', 'MAPHEAD.WL1',
             'VGADICT.WL1', 'VGAGRAPH.WL1', 'VGAHEAD.WL1', 'VSWAP.WL1'

$Root = $PSScriptRoot
# run inside a checkout of the repository: use it
if (Test-Path (Join-Path $Root 'basicsrc\WOLF3D.BAS')) { $SrcDir = $Root } else { $SrcDir = Join-Path $Root 'wolf3dbas' }
$QB64Dir = Join-Path $Root 'qb64'
$QB64 = Join-Path $QB64Dir 'qb64.exe'
$GameDir = Join-Path $Root 'wolfs14'
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

# Downloads url to file; curl.exe (Windows 10 and later) follows the redirects of GitHub and archive.org
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

function Show-Result {
    $failed = @($Status | Where-Object { $_.Result -eq 'FAILED' }).Count
    if ($failed -eq 0 -and (Test-Path $Exe) -and (Test-Data)) {
        Write-Host 'All steps went OK.' -ForegroundColor Green
        Start-Game
        exit 0
    }
    Write-Host "$failed step(s) failed; run startsrc.bat again after fixing the cause." -ForegroundColor Red
    exit 1
}

# Later runs: everything is there
if ((Test-Path $Exe) -and (Test-Data)) {
    Write-Host 'Wolfenstein 3-D (v1.4 shareware, built from source) is installed in' $GameDir
    Start-Game
    exit 0
}

Write-Host "Building Wolfenstein 3-D (v1.4 shareware) from source in $Root"
New-Item -ItemType Directory -Force -Path $GameDir | Out-Null

# 1. the source
$main = Join-Path $SrcDir 'basicsrc\WOLFS14.BAS'
if (Test-Path (Join-Path $SrcDir 'basicsrc\WOLF3D.BAS')) {
    Report 'Get the source' 'skipped' $SrcDir
} else {
    $how = $null
    $git = Get-Command git -ErrorAction SilentlyContinue
    if ($git) {
        # no password prompts or sign-in windows: a clone that needs them fails at once
        $env:GIT_TERMINAL_PROMPT = '0'
        $env:GCM_INTERACTIVE = 'never'
        $env:GIT_SSH_COMMAND = 'ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new'
        foreach ($url in $RepoUrl, $RepoSshUrl) {
            Write-Host "  git clone $url"
            Invoke-Native $git.Source -c credential.helper= clone --depth 1 $url $SrcDir
            if ($LASTEXITCODE -eq 0 -and (Test-Path (Join-Path $SrcDir 'basicsrc\WOLF3D.BAS'))) { $how = "git clone $url"; break }
            if (Test-Path $SrcDir) { Remove-Item $SrcDir -Recurse -Force }
        }
    }
    if ($how) {
        Report 'Get the source' 'OK' $how
    } else {
        try {
            $zip = Join-Path $Root 'wolf3dbas-main.zip'
            Get-Download $RepoZipUrl $zip
            $tmp = Join-Path $Root 'wolf3dbas-unpack'
            if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
            Expand-Archive -Path $zip -DestinationPath $tmp
            # the zip has one folder, wolf3dbas-main
            Move-Item -Path (Get-ChildItem $tmp -Directory | Select-Object -First 1).FullName -Destination $SrcDir
            Remove-Item $tmp -Recurse -Force
            Remove-Item $zip -Force
            Report 'Get the source' 'OK' $RepoZipUrl
        } catch {
            if (Test-Path $SrcDir) { Remove-Item $SrcDir -Recurse -Force }
            Report 'Get the source' 'FAILED' ('no git clone, and the zip: ' + $_.Exception.Message + ' (is the repository private?)')
        }
    }
}

# 2. QB64 2.1
if (Test-Path $QB64) {
    Report 'Get QB64 2.1' 'skipped' $QB64Dir
} else {
    $archive = Join-Path $Root 'qb64.7z'
    try {
        Get-Download $QB64Url $archive
        # the .7z has the folder qb64\; Windows 10/11 tar.exe (libarchive) reads .7z,
        # else 7zr.exe from 7-zip.org unpacks it
        # (Windows' own tar.exe: the tar of Git or MSYS reads "C:" as a remote host)
        $tar = Join-Path $env:SystemRoot 'System32\tar.exe'
        if (Test-Path $tar) { Invoke-Native $tar -xf $archive -C $Root }
        if (-not (Test-Path $QB64)) {
            $sevenzr = Join-Path $Root '7zr.exe'
            Get-Download $SevenZrUrl $sevenzr
            Invoke-Native $sevenzr x -y "-o$Root" $archive | Out-Null
            Remove-Item $sevenzr -Force
        }
        if (Test-Path $QB64) { Report 'Get QB64 2.1' 'OK' $QB64Dir } else { Report 'Get QB64 2.1' 'FAILED' 'qb64\qb64.exe is not in the archive' }
    } catch { Report 'Get QB64 2.1' 'FAILED' $_.Exception.Message }
    if (Test-Path $archive) { Remove-Item $archive -Force }
}

# 3. the shareware data
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

# 4. compile
if (Test-Path $Exe) {
    Report 'Compile WOLFS14.BAS' 'skipped' 'already there'
} elseif (-not (Test-Path $QB64)) {
    Report 'Compile WOLFS14.BAS' 'FAILED' 'no QB64'
} elseif (-not (Test-Path $main)) {
    Report 'Compile WOLFS14.BAS' 'FAILED' "no $main"
} else {
    Write-Host '  Compiling WOLFS14.BAS (the first compile also builds the QB64 libraries: a few minutes)...'
    Invoke-Native $QB64 -x $main -o $Exe | Out-Null
    if (Test-Path $Exe) { Report 'Compile WOLFS14.BAS' 'OK' $Exe } else { Report 'Compile WOLFS14.BAS' 'FAILED' "qb64.exe exit $LASTEXITCODE, see $QB64Dir\internal\temp\compilelog.txt" }
}

# 5. the result
Show-Result
