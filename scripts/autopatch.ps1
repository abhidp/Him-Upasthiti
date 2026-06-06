<#
.SYNOPSIS
  One-button, offline Him Upasthiti patcher. Takes a downloaded XAPK and produces a
  signed, patched APK, then optionally installs it to a connected phone.

.DESCRIPTION
  Fully local. No internet required (you download the XAPK yourself). Reproduces the
  whole PATCHING_GUIDE.md pipeline:
    extract XAPK -> unpack -> merge native libs -> patch manifest ->
    apply smali+drawable patches (apply_patches.py) -> rebuild -> sign -> (optional) install.

  Safety gate: if apply_patches.py reports a missing/changed patch target (publisher
  restructured the app), the script STOPS before building so it never ships a broken APK.

.PARAMETER Version
  App version to patch, e.g. "2.1.9". If omitted, the script prompts for it.
  The matching XAPK must be in your Downloads folder, named:
      Him Upasthiti_<Version>_APKPure.xapk

.EXAMPLE
  .\autopatch.ps1                # prompts for version
  .\autopatch.ps1 -Version 2.1.9 # non-interactive version select

.NOTES
  Requires java, python, adb on PATH, plus apktool.jar + signer.jar in the project
  root (one level above this script's parent). apply_patches.py must sit next to this file.
  Run via the PATCH-NEW-VERSION.bat launcher for a double-click experience.
#>
param(
    [string]$Version
)

$ErrorActionPreference = "Stop"
# Under PowerShell 7+, don't let native exe non-zero exits auto-throw; we check
# $LASTEXITCODE explicitly where it matters (harmless no-op on Windows PowerShell 5.1).
$PSNativeCommandUseErrorActionPreference = $false

$ScriptDir = $PSScriptRoot
if (-not $ScriptDir) { $ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path }
$script:Transcribing = $false
$script:Log = $null

function Stop-Log {
    if ($script:Transcribing) { try { Stop-Transcript | Out-Null } catch {} ; $script:Transcribing = $false }
}
function Pause-Window {
    # Keep the console open until the user explicitly types 'exit'. A stray Enter (or
    # any other text) just re-prompts, so the window can't be closed by accident.
    # Flush first so a leftover keystroke from an earlier prompt can't pre-fill input.
    # No-op when there is no interactive console (Read-Host throws -> caught) so an
    # automated/headless run never hangs.
    Write-Host ""
    try {
        try { $Host.UI.RawUI.FlushInputBuffer() } catch {}
        do {
            $resp = Read-Host "Type 'exit' and press Enter to close this window"
        } while ($null -ne $resp -and $resp.Trim().ToLower() -ne 'exit')
    } catch {}
}
function Fail-Early($msg) {
    Write-Host ""
    Write-Host "  FAIL: $msg" -ForegroundColor Red
    Write-Host ""
    Stop-Log
    Pause-Window
    exit 1
}
function Get-DeviceName($serial) {
    # Friendly name for the final message. Emulators expose their AVD name via
    # `adb emu avd name`; physical devices use manufacturer + model.
    if ($serial -like "emulator-*") {
        try {
            $n = (adb -s $serial emu avd name 2>$null | Select-Object -First 1)
            if ($n) { $n = $n.Trim() }
            if ($n) { return "$n  [$serial, emulator]" }
        } catch {}
        return "$serial  [emulator]"
    }
    try {
        $man = (adb -s $serial shell getprop ro.product.manufacturer 2>$null | Out-String).Trim()
        $mod = (adb -s $serial shell getprop ro.product.model 2>$null | Out-String).Trim()
        $nm  = ("$man $mod").Trim()
        if ($nm) { return "$nm  [$serial, physical device]" }
    } catch {}
    return "$serial  [physical device]"
}

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "   Him Upasthiti - one-button offline patcher" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# ---- 1. Version ----------------------------------------------------------------
if (-not $Version) { $Version = (Read-Host "Enter the version to patch (e.g. 2.1.9)").Trim() }
if (-not $Version) { Fail-Early "No version entered." }

# ---- 2. Locate the XAPK in Downloads ------------------------------------------
$Downloads = Join-Path $env:USERPROFILE "Downloads"
$Xapk = Join-Path $Downloads "Him Upasthiti_${Version}_APKPure.xapk"
if (-not (Test-Path $Xapk)) {
    Fail-Early "XAPK not found:`n      $Xapk`n  Download 'Him Upasthiti_${Version}_APKPure.xapk' into your Downloads folder, then re-run."
}
Write-Host "XAPK   : $Xapk" -ForegroundColor Gray

# ---- 3. Pre-flight: tools + jars ----------------------------------------------
# Only java + python are needed to patch/build/sign. adb is required ONLY to install
# to a device, so it is checked lazily at the install step - a build-only machine
# (e.g. a fresh laptop) does not need adb at all.
foreach ($tool in @("java","python")) {
    if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
        Fail-Early "$tool is not on PATH. See STEP_BY_STEP_WALKTHROUGH.md section 0 (one-time setup)."
    }
}
# Project root holding the jars = two levels up from this script (scripts -> base_extracted -> <project>)
$RefProject = (Resolve-Path (Join-Path $ScriptDir "..\..")).Path
$ToolDir = $null
# Prefer the committed in-repo copy (base_extracted\tools) so a fresh clone is
# self-contained; fall back to the original out-of-repo project-root location.
foreach ($cand in @((Join-Path $ScriptDir "..\tools"), $RefProject, (Join-Path $ScriptDir ".."), $ScriptDir)) {
    if ((Test-Path (Join-Path $cand "apktool.jar")) -and (Test-Path (Join-Path $cand "signer.jar"))) {
        $ToolDir = (Resolve-Path $cand).Path; break
    }
}
if (-not $ToolDir) { Fail-Early "apktool.jar / signer.jar not found. Expected in: $(Join-Path $ScriptDir '..\tools') or $RefProject" }
$Apktool      = Join-Path $ToolDir "apktool.jar"
$Signer       = Join-Path $ToolDir "signer.jar"
$ApplyPatches = Join-Path $ScriptDir "apply_patches.py"
if (-not (Test-Path $ApplyPatches)) { Fail-Early "apply_patches.py not found next to this script ($ScriptDir)." }
Write-Host "Tools  : $ToolDir" -ForegroundColor Gray

# ---- 4. Work dir + transcript log ---------------------------------------------
$ProjectsDir = Split-Path -Parent $RefProject
$Work = Join-Path $ProjectsDir "Him Upasthiti_${Version}_APKPure"
New-Item -ItemType Directory -Force -Path $Work | Out-Null
$script:Log = Join-Path $Work "autopatch-$Version.log"
Start-Transcript -Path $script:Log -Force | Out-Null
$script:Transcribing = $true
Write-Host "Workdir: $Work" -ForegroundColor Gray
Write-Host ""

$exitCode = 1
$installedName = $null
$outSigned = $null
try {
    $Base = Join-Path $Work "base_extracted"
    $Arm  = Join-Path $Work "arm64_extracted"
    foreach ($d in @($Base, $Arm)) { if (Test-Path $d) { Remove-Item -Recurse -Force $d } }

    # ---- [1/6] Extract the two inner APKs from the XAPK (it's a zip) -----------
    Write-Host "[1/6] Extracting XAPK ..." -ForegroundColor Yellow
    $py = @"
import zipfile, sys
src = r'''$Xapk'''
out = r'''$Work'''
z = zipfile.ZipFile(src)
for name in ('com.attendancemanagementsystem.apk', 'config.arm64_v8a.apk'):
    if name not in z.namelist():
        sys.stderr.write('missing in XAPK: ' + name + '\n'); sys.exit(2)
    z.extract(name, out)
print('extracted OK')
"@
    $py | python -
    if ($LASTEXITCODE -ne 0) { throw "XAPK extraction failed (is the file a valid XAPK?)." }
    $baseApk = Join-Path $Work "com.attendancemanagementsystem.apk"
    $armApk  = Join-Path $Work "config.arm64_v8a.apk"
    if (-not (Test-Path $baseApk)) { throw "base APK missing after extract." }
    if (-not (Test-Path $armApk))  { throw "arm64 split APK missing after extract." }

    # ---- [2/6] Unpack both with apktool ---------------------------------------
    Write-Host "[2/6] Unpacking APKs (apktool) ..." -ForegroundColor Yellow
    java -jar $Apktool d $baseApk -o $Base -f
    if ($LASTEXITCODE -ne 0) { throw "apktool decode failed on base APK." }
    java -jar $Apktool d $armApk -o $Arm -f
    if ($LASTEXITCODE -ne 0) { throw "apktool decode failed on arm64 split." }

    # ---- [3/6] Merge native libs ----------------------------------------------
    Write-Host "[3/6] Merging arm64 native libs into base ..." -ForegroundColor Yellow
    Copy-Item -Recurse -Force (Join-Path $Arm "lib") $Base
    $abi = Join-Path $Base "lib\arm64-v8a"
    if (-not (Test-Path $abi) -or -not (Get-ChildItem $abi -Filter *.so -ErrorAction SilentlyContinue)) {
        throw "native .so libraries missing after merge ($abi)."
    }

    # ---- [4/6] Patch AndroidManifest.xml --------------------------------------
    Write-Host "[4/6] Patching AndroidManifest.xml ..." -ForegroundColor Yellow
    $mf = Join-Path $Base "AndroidManifest.xml"
    $content = Get-Content $mf -Raw
    $content = $content -replace 'android:extractNativeLibs="false"', 'android:extractNativeLibs="true"'
    $content = $content -replace ' android:requiredSplitTypes="[^"]*"', ''
    $content = $content -replace ' android:splitTypes=""', ''
    $lines = $content -split "`r?`n" | Where-Object {
        $_ -notmatch 'com\.android\.vending\.splits\.required' -and
        $_ -notmatch 'com\.android\.vending\.splits"'          -and
        $_ -notmatch 'com\.android\.vending\.derived\.apk\.id'
    }
    Set-Content $mf ($lines -join "`r`n") -NoNewline
    if ((Get-Content $mf -Raw) -notmatch 'android:extractNativeLibs="true"') {
        throw "manifest patch failed (extractNativeLibs not flipped)."
    }

    # ---- [5/6] Apply smali + drawable patches (the safety gate) ---------------
    Write-Host "[5/6] Applying smali + drawable patches ..." -ForegroundColor Yellow
    python $ApplyPatches $Base
    if ($LASTEXITCODE -ne 0) {
        throw "apply_patches.py reported missing/changed targets. The publisher likely restructured the app. See PATCHING_GUIDE.md section 15. NOT building - this would ship a broken APK."
    }

    # ---- [6/6] Rebuild + sign --------------------------------------------------
    Write-Host "[6/6] Rebuilding + signing ..." -ForegroundColor Yellow
    $outRaw    = Join-Path $Work "him-upasthiti-$Version-patched.apk"
    $outSigned = Join-Path $Work "him-upasthiti-$Version-patched-aligned-debugSigned.apk"
    java -jar $Apktool b $Base -o $outRaw -f
    if ($LASTEXITCODE -ne 0) { throw "apktool build failed." }
    java -jar $Signer --apks $outRaw
    if ($LASTEXITCODE -ne 0) { throw "signing failed." }
    if (-not (Test-Path $outSigned)) { throw "signed APK was not produced: $outSigned" }

    Write-Host ""
    Write-Host "  BUILD PASS" -ForegroundColor Green
    Write-Host "  Output: $outSigned" -ForegroundColor Green
    Write-Host ""
    # Build succeeded - the deliverable is done. The optional install below is a
    # convenience and must never downgrade this PASS, so we set success here and
    # handle install issues as warnings (not failures of the patch pipeline).
    $exitCode = 0

    # ---- Optional install ------------------------------------------------------
    $ans = "n"
    try { $ans = (Read-Host "Install to connected device now? (y/n)").Trim().ToLower() }
    catch { Write-Host "  (no interactive console - skipping install prompt)" -ForegroundColor Gray }

    if (($ans -eq 'y' -or $ans -eq 'yes') -and -not (Get-Command adb -ErrorAction SilentlyContinue)) {
        Write-Host "  adb is not installed on this machine - cannot auto-install." -ForegroundColor Yellow
        Write-Host "  Your signed APK is ready here:" -ForegroundColor Yellow
        Write-Host "      $outSigned" -ForegroundColor White
        Write-Host "  Copy it to your phone and install it there manually." -ForegroundColor Yellow
    }
    elseif ($ans -eq 'y' -or $ans -eq 'yes') {
        # Enumerate authorised adb targets. A physical phone and an Android Studio
        # emulator both appear here; emulators have serials like "emulator-5554".
        $serials = @(
            (adb devices) -split "`r?`n" |
                Where-Object { $_ -match "^\S+\s+device$" } |
                ForEach-Object { ($_ -split "\s+")[0] }
        )

        $target = $null
        if ($serials.Count -eq 0) {
            Write-Host "  No authorised device found." -ForegroundColor Yellow
            Write-Host "  Connect a phone (USB debugging on, accept the prompt) OR start an emulator" -ForegroundColor Yellow
            Write-Host "  in Android Studio (Device Manager), then install manually:" -ForegroundColor Yellow
            Write-Host "    adb install `"$outSigned`""
        }
        elseif ($serials.Count -eq 1) {
            $target = $serials[0]
        }
        else {
            # More than one target connected (e.g. phone + emulator): let the user pick.
            Write-Host "  Multiple devices connected - choose where to install:" -ForegroundColor Cyan
            for ($i = 0; $i -lt $serials.Count; $i++) {
                $s = $serials[$i]
                $kind = if ($s -like "emulator-*") { "emulator" } else { "physical" }
                $model = ""
                try { $model = (adb -s $s shell getprop ro.product.model 2>$null | Out-String).Trim() } catch {}
                $label = if ($model) { "$kind - $model" } else { $kind }
                Write-Host ("    [{0}] {1}  ({2})" -f ($i + 1), $s, $label)
            }
            $pick = ""
            try { $pick = (Read-Host "  Enter number (blank to skip)").Trim() }
            catch { Write-Host "  (no interactive console - skipping install)" -ForegroundColor Gray }
            if ($pick -match '^\d+$' -and [int]$pick -ge 1 -and [int]$pick -le $serials.Count) {
                $target = $serials[[int]$pick - 1]
            }
            else {
                Write-Host "  No valid selection - skipping install. Install manually:" -ForegroundColor Yellow
                Write-Host "    adb -s <serial> install `"$outSigned`""
            }
        }

        if ($target) {
            $kind = if ($target -like "emulator-*") { "emulator" } else { "physical device" }
            Write-Host "  Target: $target ($kind)" -ForegroundColor Gray
            Write-Host "  Uninstalling old build (a 'not installed' message here is harmless) ..." -ForegroundColor Gray
            adb -s $target uninstall com.attendancemanagementsystem
            Write-Host "  Installing patched build ..." -ForegroundColor Gray
            adb -s $target install $outSigned
            if ($LASTEXITCODE -ne 0) {
                Write-Host "  INSTALL FAILED (the signed APK is still valid)." -ForegroundColor Red
                if ($kind -eq "emulator") {
                    Write-Host "  If the error is NO_MATCHING_ABIS, the emulator image lacks ARM64 translation." -ForegroundColor Red
                    Write-Host "  Use a Google APIs / Google Play x86_64 image (API 30+). See EMULATOR_SETUP.md." -ForegroundColor Red
                }
                Write-Host "  Manual retry: adb -s $target install `"$outSigned`"" -ForegroundColor Red
            }
            else {
                $installedName = Get-DeviceName $target
                Write-Host ""
                Write-Host "  INSTALL PASS - open the app on the $kind to verify (no Pairip dialog expected)." -ForegroundColor Green
            }
        }
    }
    else {
        Write-Host "  Skipped install. To install later:" -ForegroundColor Gray
        Write-Host "    adb uninstall com.attendancemanagementsystem"
        Write-Host "    adb install `"$outSigned`""
    }

    Write-Host ""
    Write-Host "  DONE.  Log: $script:Log" -ForegroundColor Cyan
}
catch {
    Write-Host ""
    Write-Host "  FAIL: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "  Full log: $script:Log" -ForegroundColor Red
    $exitCode = 1
}
finally {
    Stop-Log
}

# ---- Final summary (stays on screen; window does not auto-close) ---------------
Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
if ($installedName) {
    Write-Host "  CONGRATULATIONS!" -ForegroundColor Green
    Write-Host "  Him Upasthiti $Version has been successfully installed on:" -ForegroundColor Green
    Write-Host "      $installedName" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Open the app there to verify (no Pairip dialog expected)." -ForegroundColor Green
}
elseif ($exitCode -eq 0 -and $outSigned) {
    Write-Host "  PATCHED APK IS READY (not installed to a device)" -ForegroundColor Yellow
    Write-Host "  No device was connected/selected. Your signed APK is here:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "      $outSigned" -ForegroundColor White
    Write-Host ""
    Write-Host "  Copy that file to your phone (USB cable or any file transfer) and" -ForegroundColor Yellow
    Write-Host "  install it there, OR start a device/emulator and run this again to" -ForegroundColor Yellow
    Write-Host "  auto-install." -ForegroundColor Yellow
}
else {
    Write-Host "  BUILD DID NOT COMPLETE" -ForegroundColor Red
    Write-Host "  Review the messages above. Full log:" -ForegroundColor Red
    Write-Host "      $script:Log" -ForegroundColor Red
}
Write-Host "==================================================" -ForegroundColor Cyan

Pause-Window
exit $exitCode
