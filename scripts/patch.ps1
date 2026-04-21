<#
.SYNOPSIS
  Automates the Him Upasthiti patch pipeline end-to-end.

.DESCRIPTION
  Given a base APK and the arm64 split APK, produces a signed, patched APK
  ready to install with adb. Reproduces every step in PATCHING_GUIDE.md
  sections 5-9.

.PARAMETER Version
  Label used for the work directory and output filename (e.g. "2.1.8").

.PARAMETER Base
  Path to the base APK (com.attendancemanagementsystem.apk).

.PARAMETER Arm64
  Path to the arm64 split APK (config.arm64_v8a.apk).

.EXAMPLE
  .\patch.ps1 -Version 2.1.8 -Base .\base.apk -Arm64 .\config.arm64_v8a.apk

.NOTES
  Requires: apktool.jar, signer.jar (uber-apk-signer), python, java, adb in PATH.
  Expects apply_patches.py next to this script.
#>
param(
    [string]$Version = "2.1.8",
    [string]$Base    = "com.attendancemanagementsystem.apk",
    [string]$Arm64   = "config.arm64_v8a.apk"
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Work = "work_$Version"

Write-Host "=== Him Upasthiti patch pipeline ===" -ForegroundColor Cyan
Write-Host "Version:  $Version"
Write-Host "Base APK: $Base"
Write-Host "Arm64:    $Arm64"
Write-Host ""

# 0. Pre-flight: verify required tools exist
foreach ($tool in @("java","python","adb")) {
    if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
        Write-Error "$tool not found in PATH"
    }
}
foreach ($jar in @("apktool.jar","signer.jar")) {
    if (-not (Test-Path $jar)) {
        Write-Error "$jar not found in current directory"
    }
}

# 1. Clean work dir
if (Test-Path $Work) {
    Write-Host "[1/6] Removing existing $Work ..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force $Work
}
New-Item -ItemType Directory -Path $Work | Out-Null

# 2. Unpack both APKs
Write-Host "[2/6] Unpacking APKs ..." -ForegroundColor Yellow
java -jar apktool.jar d $Base  -o "$Work\base"  -f
java -jar apktool.jar d $Arm64 -o "$Work\arm64" -f

# 3. Merge native libs
Write-Host "[3/6] Merging arm64 native libs into base ..." -ForegroundColor Yellow
Copy-Item -Recurse -Force "$Work\arm64\lib" "$Work\base\"

# 4. Patch AndroidManifest.xml
Write-Host "[4/6] Patching AndroidManifest.xml ..." -ForegroundColor Yellow
$mf = "$Work\base\AndroidManifest.xml"
$content = Get-Content $mf -Raw

# 4a. Flip extractNativeLibs
$content = $content -replace 'android:extractNativeLibs="false"','android:extractNativeLibs="true"'

# 4b. Strip split attributes from <manifest> tag
$content = $content -replace ' android:requiredSplitTypes="[^"]*"',''
$content = $content -replace ' android:splitTypes=""',''

# 4c. Strip split meta-data lines from <application> block
$lines = $content -split "`r?`n" | Where-Object {
    $_ -notmatch 'com\.android\.vending\.splits\.required' -and
    $_ -notmatch 'com\.android\.vending\.splits"'          -and
    $_ -notmatch 'com\.android\.vending\.derived\.apk\.id'
}
Set-Content $mf ($lines -join "`r`n") -NoNewline

# 5. Apply smali + drawable patches
Write-Host "[5/6] Applying smali patches ..." -ForegroundColor Yellow
python "$ScriptDir\apply_patches.py" "$Work\base"
if ($LASTEXITCODE -ne 0) {
    Write-Error "apply_patches.py exited with code $LASTEXITCODE"
}

# 6. Rebuild and sign
Write-Host "[6/6] Rebuilding + signing ..." -ForegroundColor Yellow
$outRaw    = "him-upasthiti-$Version-patched.apk"
$outSigned = "him-upasthiti-$Version-patched-aligned-debugSigned.apk"

java -jar apktool.jar b "$Work\base" -o $outRaw -f
java -jar signer.jar --apks $outRaw

Write-Host ""
Write-Host "Done." -ForegroundColor Green
Write-Host "Output: $outSigned"
Write-Host ""
Write-Host "To install:"
Write-Host "  adb uninstall com.attendancemanagementsystem"
Write-Host "  adb install $outSigned"
