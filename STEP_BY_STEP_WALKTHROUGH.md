# Him Upasthiti — Solo Patching Walkthrough (offline, no agent needed)

This is the **do-it-yourself** companion to `PATCHING_GUIDE.md`. Follow it top to
bottom for any new version. Every command is copy-paste for **Windows PowerShell**.
You do NOT need internet (except to download the XAPK, which you do yourself).

`PATCHING_GUIDE.md` = the *why* and the deep reference. **This file = the *how*, in order.**

---

## 0. One-time setup (already done on this PC — just confirm)

You need these installed. Check each (run in PowerShell):

```powershell
java -version      # expect: openjdk 17 (or 11+)
adb version        # expect: Android Debug Bridge version 1.0.41
python --version   # expect: Python 3.x
```

And these two tool files must exist (they live in the 2.1.7 project folder):

```
C:\Users\abhid\Documents\Projects\Him Upasthiti_2.1.7_APKPure\apktool.jar
C:\Users\abhid\Documents\Projects\Him Upasthiti_2.1.7_APKPure\signer.jar
```

The patch script lives at:

```
C:\Users\abhid\Documents\Projects\Him Upasthiti_2.1.7_APKPure\base_extracted\scripts\apply_patches.py
```

If all of that is present, you never touch setup again. If you ever move to a new PC,
re-install JDK + Android platform-tools (adb) + Python, and copy the two .jar files
and the `scripts\` folder over.

---

## Set the version once (used by every step below)

Download the new XAPK from APKPure into your **Downloads** folder. It will be named
like `Him Upasthiti_2.1.9_APKPure.xapk`. Then open PowerShell and set the version
number — **edit the one line below**, then paste the whole block:

```powershell
$ver  = "2.1.9"                                                   # <-- CHANGE THIS each time
$proj = "C:\Users\abhid\Documents\Projects"
$ref  = "$proj\Him Upasthiti_2.1.7_APKPure"                       # reference project (jars + script)
$dst  = "$proj\Him Upasthiti_${ver}_APKPure"                      # new working folder
$xapk = "C:\Users\abhid\Downloads\Him Upasthiti_${ver}_APKPure.xapk"
Write-Host "Version=$ver  Dest=$dst"
Test-Path $xapk        # must print True. If False, fix the XAPK name/location.
```

> Keep this PowerShell window open the whole time — `$ver`, `$dst`, etc. stay set.
> If you close it, re-paste this block before continuing.

---

## Step 1 — Create the work folder and copy in tools

```powershell
New-Item -ItemType Directory -Force -Path $dst | Out-Null
Copy-Item "$ref\apktool.jar" $dst
Copy-Item "$ref\signer.jar"  $dst
Copy-Item $xapk "$dst\Him Upasthiti_${ver}_APKPure.xapk"
Get-ChildItem $dst
```
**Expect:** the folder lists `apktool.jar`, `signer.jar`, and the `.xapk`.

---

## Step 2 — Extract the two APKs from the XAPK (it's just a zip)

```powershell
cd $dst
python -c "import zipfile; z=zipfile.ZipFile('Him Upasthiti_${ver}_APKPure.xapk'); z.extract('com.attendancemanagementsystem.apk'); z.extract('config.arm64_v8a.apk'); print('extracted OK')"
Get-ChildItem $dst -Filter *.apk
```
**Expect:** `extracted OK`, then two files — `com.attendancemanagementsystem.apk` (~17 MB)
and `config.arm64_v8a.apk` (~15 MB). (Ignore the en/fr/xxhdpi language packs.)

---

## Step 3 — Unpack both APKs with apktool

```powershell
cd $dst
java -jar apktool.jar d com.attendancemanagementsystem.apk -o base_extracted -f
java -jar apktool.jar d config.arm64_v8a.apk -o arm64_extracted -f
```
**Expect:** lots of `I:` lines, **no** `Exception`/`error`. Two new folders appear:
`base_extracted\` and `arm64_extracted\`. (Base decode takes a minute or two.)

⚠️ If you see an exception here, stop — the download may be corrupt; re-download the XAPK.

---

## Step 4 — Merge the native libraries into the base

```powershell
cd $dst
Copy-Item -Recurse -Force "arm64_extracted\lib" "base_extracted\lib"
Get-ChildItem "base_extracted\lib\arm64-v8a" | Select-Object Name
```
**Expect:** a list of `.so` files (`libhermes.so`, `libreactnative.so`, `libreanimated.so`, etc.).
If this folder is empty or missing, the app will crash on launch — re-do the copy.

---

## Step 5 — Verify all patch targets exist BEFORE editing (very important)

```powershell
cd "$dst\base_extracted"
Write-Host "=== 4 detector methods (expect 4 lines) ==="
Select-String -Path "smali\com\attendancemanagementsystem\DeveloperOptionsModule.smali" -Pattern "\.method public final (isAdbEnabled|isDeveloperOptionsEnabled|isMockLocationEnabled|isStayAwakeEnabled)\("
Write-Host "=== isFromMockProvider (expect 1 line) ==="
Select-String -Path "smali\com\attendancemanagementsystem\LocationModuleHU.smali" -Pattern "isFromMockProvider\(\)Z"
Write-Host "=== Pairip ContentProvider (expect the file path) ==="
Get-ChildItem -Recurse -Filter "LicenseContentProvider.smali" | Select-Object FullName
Write-Host "=== Pairip Application wrapper — the 2.1.9 trigger (may or may not exist) ==="
Get-ChildItem -Recurse -Filter "Application.smali" -Path "smali_classes2\com\pairip" -ErrorAction SilentlyContinue | Select-Object FullName
Write-Host "=== drawable @null (expect 2 lines) ==="
Select-String -Path "res\drawable\rn_edit_text_material.xml" -Pattern "@null"
```
**Expect:** 4 detector methods, 1 isFromMockProvider line, the ContentProvider path,
2 `@null` lines. The Pairip `Application.smali` line tells you whether the §7.4 trigger
is present (it was in 2.1.9). The patch script handles it either way.

⚠️ **If any of the first four targets is missing** (0 detector methods, no
isFromMockProvider, no ContentProvider, no drawable), **STOP**. The publisher
restructured something and the automated patch won't be safe. That's the one case
where you'd want an agent or to read `PATCHING_GUIDE.md` §15 and patch by hand.

---

## Step 6 — Patch the AndroidManifest.xml

```powershell
$mf = "$dst\base_extracted\AndroidManifest.xml"
(Get-Content $mf) `
    -replace 'android:extractNativeLibs="false"','android:extractNativeLibs="true"' `
    -replace ' android:requiredSplitTypes="[^"]*"','' `
    -replace ' android:splitTypes=""','' `
    | Where-Object {
        $_ -notmatch 'com\.android\.vending\.splits\.required' -and
        $_ -notmatch 'com\.android\.vending\.splits"' -and
        $_ -notmatch 'com\.android\.vending\.derived\.apk\.id'
    } | Set-Content $mf
Write-Host "--- verify: should print ONLY the extractNativeLibs=true line ---"
Select-String -Path $mf -Pattern 'extractNativeLibs|requiredSplitTypes|splitTypes=""|vending\.splits|derived\.apk\.id'
```
**Expect:** the verify line prints **only** the `extractNativeLibs="true"` match.
If `requiredSplitTypes`, `splitTypes=""`, or any `vending.splits`/`derived.apk.id`
still appear, the manifest didn't fully patch — re-run the block.

---

## Step 7 — Apply all the smali + drawable patches (one command)

```powershell
python "$ref\base_extracted\scripts\apply_patches.py" "$dst\base_extracted"
```
**Expect — all `[ok]`, ending in "All patches applied successfully.":**
```
[ok] DeveloperOptionsModule: stubbed 4/4 methods
[ok] LocationModuleHU: patched 1 call site(s)
[ok] Pairip: neutralised onCreate in smali_classes2
[ok] Pairip: neutralised checkLicense in smali_classes2     <-- the 2.1.9 trigger fix
[ok] rn_edit_text_material: @null -> @android:color/transparent
```
- `[info] ... skipping` lines are fine (a target legitimately not present in this version).
- ⚠️ If you see a **`PROBLEMS:`** section and the script exits with an error, **STOP** —
  a target didn't match. Re-read Step 5; the publisher changed something. Do not ship.

(Step 8 — the drawable fix — is included in this script, so there's no separate Step 8.)

---

## Step 9 — Rebuild, sign, and install

> Want to install to an **Android Studio emulator** instead of (or alongside) a physical
> phone? See **EMULATOR_SETUP.md**. The one-button `autopatch.ps1` lists all connected
> targets and lets you pick; everything below is the manual phone equivalent.

Plug your phone in (USB, File Transfer/MTP mode, USB debugging ON), then:

```powershell
cd $dst
java -jar apktool.jar b base_extracted -o "him-upasthiti-${ver}-patched.apk" -f
java -jar signer.jar --apks "him-upasthiti-${ver}-patched.apk"
adb devices
adb uninstall com.attendancemanagementsystem
adb install "$dst\him-upasthiti-${ver}-patched-aligned-debugSigned.apk"
```
**Expect:**
- apktool builds with **no exception**.
- signer prints `signature verified [v2, v3]`.
- `adb devices` lists your phone as `device` (if `unauthorized`, accept the popup on the phone).
- `adb uninstall` → `Success` (or a harmless "not installed" message the first time).
- `adb install` → `Success`.

> The `adb uninstall` is mandatory — installing over a differently-signed copy fails
> with `INSTALL_FAILED_UPDATE_INCOMPATIBLE`.

---

## Step 10 — Verify on the phone

1. Open the app. **It should open with no "app not recognised / get it from Play" dialog.**
2. Enable a fake-GPS app, set it as the mock-location app in Developer Options,
   drop the pin on the geofenced spot, start it.
3. Log in (OTP) → face verification → log attendance.

**Pass:** attendance records, with no "developer options / mock location / cannot verify
location" error and no Pairip dialog.

---

## Troubleshooting (offline quick table)

| What you see | Cause | Fix |
|---|---|---|
| `INSTALL_FAILED_MISSING_SPLIT` | Manifest split attrs still present | Re-run Step 6 |
| `INSTALL_FAILED_UPDATE_INCOMPATIBLE` | Didn't uninstall old build first | `adb uninstall com.attendancemanagementsystem`, install again |
| App opens then crashes; `Resources$NotFoundException` for a drawable | apktool @null artifact | Step 7 covers `rn_edit_text_material`; if a *different* drawable is named, open it under `res\drawable\` and replace its `@null` with `@android:color/transparent` |
| `dlopen failed` / `UnsatisfiedLinkError` on launch | Native libs not merged | Re-run Step 4, confirm `.so` files in `base_extracted\lib\arm64-v8a\` |
| Dialog "app not recognised / search on Google Play" | A Pairip trigger not neutralised | Confirm Step 7 printed BOTH Pairip `[ok]` lines (onCreate **and** checkLicense). If `com/pairip/application/Application.smali` exists but checkLicense wasn't patched, see `PATCHING_GUIDE.md` §7.4 |
| apktool build throws a smali error | A hand-edit broke a method | Re-extract (Step 3) and re-run the script (Step 7) instead of hand-editing |
| `adb` doesn't list the phone | USB/driver/auth | Set phone to MTP; `adb kill-server; adb start-server; adb devices`; accept RSA popup. Wireless fallback: `PATCHING_GUIDE.md` §12.4 |

---

## When you genuinely need help

You can do everything above solo. The **only** situation to pause and get an agent
(or carefully read `PATCHING_GUIDE.md` §7 and patch by hand) is:

- **Step 5 shows a missing target**, or
- **Step 7 prints `PROBLEMS:` and exits with an error.**

Both mean the publisher restructured the app and the safe automated path no longer
applies. Everything else in this list you can handle yourself.

---

*Reference: full rationale, per-patch before/after smali, and version-drift notes are in
`PATCHING_GUIDE.md` (same folder). The §7.4 Pairip trigger was discovered while patching 2.1.9.*
