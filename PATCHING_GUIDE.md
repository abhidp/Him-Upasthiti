# Him Upasthiti — Patching Guide for New Releases

This document captures everything needed to reproduce the 2.1.7 patch on any future
version of the Him Upasthiti attendance app. It is written to be consumed either by
a human following the steps manually, or by an AI coding agent (Claude Code, Codex,
Gemini, Cursor, etc.) that has been handed the new version's unpacked directory.

> **If you are an AI agent reading this:** treat every section under "Patch targets"
> as a spec. The file paths, method names, and smali snippets given are the load-bearing
> details. Class names of obfuscated Kotlin helpers (e.g. `Lh4/k;`) may drift between
> builds — never match on those; always match on the `@ReactMethod`-annotated method
> names, on stable Android framework classes (`Landroid/location/Location;`), or on
> third-party package names (`Lcom/pairip/licensecheck/...`). Those are stable.

---

## 1. Context: what this app is and what we changed

Him Upasthiti is a React Native Android attendance app. Students must log attendance
from inside a pre-defined geofenced area (the school), verified with GPS + face
recognition. The app has anti-spoofing layers that block attendance if it detects:

- GPS coming from a fake-location app (`Location.isFromMockProvider()` == true)
- Developer Options enabled
- USB debugging enabled
- Legacy mock-location setting enabled
- Stay-awake (charging) enabled

It also ships with **Pairip**, a signature-integrity check that blocks the app if
the APK was re-signed with a non-original keystore.

Our patch set neutralises all of the above so the app can be run outside the
geofence for a classroom demonstration, using any standard fake-GPS app.
Face recognition is intentionally left untouched. Backend auth (OTP + phone
number whitelist) is intentionally left untouched.

---

## 2. Tools and assumptions

| Tool | Purpose | Notes |
|------|---------|-------|
| apktool (`apktool.jar`) | Unpack + repack APK | Version 2.9.x or newer |
| uber-apk-signer (`signer.jar`) | Zipalign + v2/v3 sign | Any recent build |
| JDK 11+ | Runs the above JARs | |
| adb | Install, debug, wireless connect | Part of platform-tools |
| A debug keystore | Signing | uber-apk-signer auto-generates one |

Host assumption: Windows 11 (paths below use Windows conventions). On macOS/Linux,
translate `\` to `/`, `java -jar` still works identically.

---

## 3. Input you need for each new release

The app ships as an **XAPK** (split APK bundle). For a new version you need:

1. `com.attendancemanagementsystem.apk` — the base APK (~17MB)
2. `config.arm64_v8a.apk` — native libraries for arm64 phones (~15MB)
3. (Ignore) `config.en.apk`, `config.fr.apk`, `config.xxhdpi.apk` — language/density
   packs, not required for a working build on most phones.

Get both from APKPure / APKMirror, or extract from an XAPK (which is a zip).

---

## 4. End-to-end workflow

These are the steps in order. Sections 5-9 give the detailed instructions for each.

1. Unpack base APK and arm64 split.
2. Merge the arm64 native libs into the base directory.
3. Patch `AndroidManifest.xml` to remove split-APK constraints.
4. Apply smali patches (anti-spoofing bypass + Pairip bypass).
5. Apply the drawable fix (apktool-rebuild artifact).
6. Rebuild, zipalign, sign, install.
7. Verify end-to-end with a fake-GPS app.

A script skeleton that automates 1-6 is provided in Section 11.

---

## 5. Unpack and merge

```bat
java -jar apktool.jar d com.attendancemanagementsystem.apk -o base_extracted -f
java -jar apktool.jar d config.arm64_v8a.apk -o arm64_extracted -f

xcopy /E /I /Y arm64_extracted\lib base_extracted\lib
```

After this, `base_extracted/lib/arm64-v8a/` should contain `.so` files (Hermes,
React Native, Reanimated, etc.).

---

## 6. Patch AndroidManifest.xml

Open `base_extracted/AndroidManifest.xml` and make the following edits.

### 6.1 Flip native-lib extraction

In the `<application ...>` tag:

- Change `android:extractNativeLibs="false"` to `android:extractNativeLibs="true"`.

Reason: the arm64 split stores .so files uncompressed and expects Android's split
loader to page them directly. Merging them into base requires the loader to extract
at install time.

### 6.2 Remove split-APK constraints

In the `<manifest ...>` tag, delete these two attributes if present:

```xml
android:requiredSplitTypes="base__abi,base__density"
android:splitTypes=""
```

In the `<application ...>` block, delete these three meta-data lines if present:

```xml
<meta-data android:name="com.android.vending.splits.required" android:value="true"/>
<meta-data android:name="com.android.vending.splits" android:resource="@xml/splits0"/>
<meta-data android:name="com.android.vending.derived.apk.id" android:value="3"/>
```

Reason: these tell Android "I require companion split APKs to be installed." Since
we merged everything into one APK, leaving these in will make Android refuse the
install with `INSTALL_FAILED_MISSING_SPLIT`.

---

## 7. Patch targets (smali)

All patch targets live under `base_extracted/smali/` or `base_extracted/smali_classes2/`.
If the project has more `smali_classes*` directories in a new build, grep across all of
them — DEX shards can shift the classes around.

### 7.1 DeveloperOptionsModule — stub all four detector methods

**File:** `smali/com/attendancemanagementsystem/DeveloperOptionsModule.smali`

This class exposes four `@ReactMethod`-annotated detector methods to the JS side.
Each reads an Android system setting and returns a Boolean. We replace each method
body with a hard-coded `resolve(Boolean.FALSE)`.

**Method names to patch (all four):**

- `isAdbEnabled`
- `isDeveloperOptionsEnabled`
- `isMockLocationEnabled`
- `isStayAwakeEnabled`

**Canonical replacement body** — apply to all four, only the method name changes:

```smali
.method public final <METHOD_NAME>(Lcom/facebook/react/bridge/Promise;)V
    .locals 1
    .annotation runtime Lcom/facebook/react/bridge/ReactMethod;
    .end annotation

    sget-object v0, Ljava/lang/Boolean;->FALSE:Ljava/lang/Boolean;
    invoke-interface {p1, v0}, Lcom/facebook/react/bridge/Promise;->resolve(Ljava/lang/Object;)V
    return-void
.end method
```

**How to match in a new build:** search for `.method public final isAdbEnabled` etc.
The method names are load-bearing (JS calls them by string), so the publisher cannot
rename them without also updating the JS bundle — very unlikely in minor releases.

**Register contract:** `.locals 1` is correct for this body. `p0` is `this`, `p1` is
the Promise. We only need `v0` for the Boolean constant.

**Do NOT keep the original `:try_start_0 ... :catch_0` blocks.** The stub cannot
throw, so the catch handler is unreachable and the label would dangle. Remove the
entire original method body wholesale.

### 7.2 LocationModuleHU — force isFromMockProvider to false

**File:** `smali/com/attendancemanagementsystem/LocationModuleHU.smali`

Somewhere in this file is a block that calls `Location.isFromMockProvider()` and
stores the result into a WritableMap under the key `"isFromMockProvider"`. In 2.1.7
it lives around line 767. In a new build the line number will differ — find it by
grepping for the exact strings.

**Grep target:**

```
invoke-virtual {p1}, Landroid/location/Location;->isFromMockProvider()Z
```

**Find the block:**

```smali
    const-string v1, "isFromMockProvider"

    invoke-virtual {p1}, Landroid/location/Location;->isFromMockProvider()Z

    move-result v<REG>

    invoke-interface {v0, v1, v<REG>}, Lcom/facebook/react/bridge/WritableMap;->putBoolean(Ljava/lang/String;Z)V
```

**Patch:** insert a single line `const/4 v<REG>, 0x0` immediately after `move-result
v<REG>`. The register number (`v2` in 2.1.7) must match whatever the `move-result`
uses — do not hardcode `v2`.

Result:

```smali
    invoke-virtual {p1}, Landroid/location/Location;->isFromMockProvider()Z

    move-result v<REG>

    const/4 v<REG>, 0x0

    invoke-interface {v0, v1, v<REG>}, Lcom/facebook/react/bridge/WritableMap;->putBoolean(Ljava/lang/String;Z)V
```

**Why keep the original invoke-virtual call?** It has no observable side effects,
but leaving it preserves register layout and `.locals` count. If you remove it and
get `.locals` wrong, the verifier will reject the DEX.

**If there are multiple `isFromMockProvider` call sites** (unlikely but possible
with new builds), patch all of them with the same trick.

### 7.3 Pairip — neutralise the license check

**File:** `smali_classes2/com/pairip/licensecheck/LicenseContentProvider.smali`

Pairip is a widely used Google Play integrity library. It installs a
`<provider>` in the manifest that Android instantiates before `Application.onCreate()`.
The provider's `onCreate()` kicks off the signature check, which on a re-signed APK
shows the dialog:

> *"The app installed on your device is not recognised and could harm your device.
> To continue using this app, search for it on Google Play."*

**Original `onCreate()`:**

```smali
.method public onCreate()Z
    .locals 2

    new-instance v0, Lcom/pairip/licensecheck/LicenseClient;
    invoke-virtual {p0}, Lcom/pairip/licensecheck/LicenseContentProvider;->getContext()Landroid/content/Context;
    move-result-object v1
    invoke-direct {v0, v1}, Lcom/pairip/licensecheck/LicenseClient;-><init>(Landroid/content/Context;)V
    invoke-virtual {v0}, Lcom/pairip/licensecheck/LicenseClient;->initializeLicenseCheck()V

    const/4 v0, 0x1
    return v0
.end method
```

**Replacement:**

```smali
.method public onCreate()Z
    .locals 1

    const/4 v0, 0x1
    return v0
.end method
```

The provider still instantiates (required by Android because the manifest declares
it), but it skips the LicenseClient entirely. `LicenseActivity` is never launched.

**Sanity check for new builds:** grep the entire decompiled tree for
`Lcom/pairip/licensecheck/LicenseClient;` and `Lcom/pairip/licensecheck/LicenseActivity;`.
If references exist only within the `com/pairip/licensecheck/` package (self-references),
you are safe — nothing in the app code triggers the check independently. If the main
app code (`com/attendancemanagementsystem/...`) also calls into Pairip, those call
sites need stubbing too.

**If Pairip is replaced with a native library** (a `libpairip.so` appears under
`lib/`), this smali patch is insufficient. You will need binary analysis
(Ghidra/IDA) — out of scope for this guide.

**If Pairip is removed entirely** in a new build, no patch needed for this
section. Still check the manifest and remove the `LicenseActivity` and
`LicenseContentProvider` declarations if they remain orphaned.

---

## 8. Patch targets (resources)

### 8.1 Drawable @null fix

**File:** `res/drawable/rn_edit_text_material.xml`

apktool sometimes decodes React Native's drawable in a way that Android 13/14
rejects at runtime with:

```
Resources$NotFoundException: Drawable ...:drawable/rn_edit_text_material
Caused by: XmlPullParserException: Binary XML file line #5:
    <item> tag requires a 'drawable' attribute or child tag defining a drawable
```

**Original (broken after rebuild):**

```xml
<item android:state_enabled="false" android:drawable="@null" />
<item android:drawable="@null" />
```

**Fixed:**

```xml
<item android:state_enabled="false" android:drawable="@android:color/transparent" />
<item android:drawable="@android:color/transparent" />
```

**Do not preemptively fix other `@null` drawables in the tree.** Many are
`<transition>` tags or unused code paths where `@null` is semantically correct.
Only fix one when an actual crash points at it. Symptom to watch for: a
`Resources$NotFoundException` naming a drawable, immediately after login or on
a new screen.

---

## 9. Rebuild, sign, install

```bat
java -jar apktool.jar b base_extracted -o him-upasthiti-patched.apk -f
java -jar signer.jar --apks him-upasthiti-patched.apk
adb uninstall com.attendancemanagementsystem
adb install him-upasthiti-patched-aligned-debugSigned.apk
```

Notes:

- `-f` on apktool forces overwrite of the output APK.
- uber-apk-signer auto-generates a debug keystore if none is given. It produces
  `<name>-aligned-debugSigned.apk`.
- Always `adb uninstall` first. Reinstalling a differently-signed APK on top of
  an existing install will fail with `INSTALL_FAILED_UPDATE_INCOMPATIBLE`.
- Google Play Protect will show a warning on first install. This is safe to
  dismiss for the patched build. If you want to avoid the warning entirely,
  add the signing cert to Play Protect allowlist or disable Play Protect for
  the test device.

---

## 10. Verification procedure

On a registered student's phone (backend auth is out of scope; we can't log in
without a whitelisted phone number):

1. Enable **Developer Options**.
2. Install a fake-GPS app (e.g. *Fake GPS Location* by Lexa).
3. Developer Options → **Select mock location app** → pick the fake-GPS app.
4. Open the fake-GPS app, drop the pin on the school's geofenced spot, start.
5. Open the patched Him Upasthiti app.
6. Enter the registered phone number → receive OTP → log in.
7. Complete face verification (real face — unchanged).
8. Attempt to log attendance.

**Pass criteria:** attendance is recorded. No "developer options detected",
"mock location detected", or "cannot verify location" error appears.

**If a check still fires:** it means there is a detector we did not patch.
Capture a fresh logcat (section 12.2) and grep for the exact error string.
Likely suspects in 3rd-party RN libraries:

- `smali/com/learnium/RNDeviceInfo/` — has `isLocationEnabled`, root detection, etc.
- `smali/com/reactnativecommunity/geolocation/` — wraps platform APIs.
- `smali/com/github/douglasjunior/reactNativeGetLocation/` — alternate geolocation
  bridge.

---

## 11. Automation script skeleton

Save as `patch.ps1` in the folder containing `apktool.jar`, `signer.jar`, and the
input APKs. Adjust paths as needed.

```powershell
param(
    [string]$Version = "2.1.8",
    [string]$Base    = "com.attendancemanagementsystem.apk",
    [string]$Arm64   = "config.arm64_v8a.apk"
)

$Work = "work_$Version"
if (Test-Path $Work) { Remove-Item -Recurse -Force $Work }
New-Item -ItemType Directory -Path $Work | Out-Null

# 1. Unpack
java -jar apktool.jar d $Base  -o "$Work\base"  -f
java -jar apktool.jar d $Arm64 -o "$Work\arm64" -f

# 2. Merge native libs
Copy-Item -Recurse -Force "$Work\arm64\lib" "$Work\base\"

# 3. Manifest edits
$mf = "$Work\base\AndroidManifest.xml"
(Get-Content $mf) `
    -replace 'android:extractNativeLibs="false"','android:extractNativeLibs="true"' `
    -replace ' android:requiredSplitTypes="[^"]*"','' `
    -replace ' android:splitTypes=""','' `
    | Where-Object {
        $_ -notmatch 'com\.android\.vending\.splits\.required' -and
        $_ -notmatch 'com\.android\.vending\.splits"' -and
        $_ -notmatch 'com\.android\.vending\.derived\.apk\.id'
    } | Set-Content $mf

# 4. Smali patches (hand off to python or a second script)
python apply_patches.py "$Work\base"

# 5. Drawable fix
$drw = "$Work\base\res\drawable\rn_edit_text_material.xml"
(Get-Content $drw) -replace 'android:drawable="@null"','android:drawable="@android:color/transparent"' `
    | Set-Content $drw

# 6. Rebuild + sign
java -jar apktool.jar b "$Work\base" -o "him-upasthiti-$Version-patched.apk" -f
java -jar signer.jar --apks "him-upasthiti-$Version-patched.apk"

Write-Host "Done. Output: him-upasthiti-$Version-patched-aligned-debugSigned.apk"
```

Companion `apply_patches.py`:

```python
#!/usr/bin/env python3
"""Apply smali patches for Him Upasthiti. Usage: python apply_patches.py <unpacked_dir>"""
import re, sys, pathlib

ROOT = pathlib.Path(sys.argv[1])

# 7.1 — DeveloperOptionsModule: stub all four detector methods
DEV_OPTS = ROOT / "smali/com/attendancemanagementsystem/DeveloperOptionsModule.smali"
STUB = """.method public final {name}(Lcom/facebook/react/bridge/Promise;)V
    .locals 1
    .annotation runtime Lcom/facebook/react/bridge/ReactMethod;
    .end annotation

    sget-object v0, Ljava/lang/Boolean;->FALSE:Ljava/lang/Boolean;
    invoke-interface {{p1, v0}}, Lcom/facebook/react/bridge/Promise;->resolve(Ljava/lang/Object;)V
    return-void
.end method"""

if DEV_OPTS.exists():
    text = DEV_OPTS.read_text()
    for name in ("isAdbEnabled", "isDeveloperOptionsEnabled",
                 "isMockLocationEnabled", "isStayAwakeEnabled"):
        pattern = rf"\.method public final {name}\(Lcom/facebook/react/bridge/Promise;\)V.*?\.end method"
        text = re.sub(pattern, STUB.format(name=name), text, flags=re.DOTALL)
    DEV_OPTS.write_text(text)
    print(f"Patched {DEV_OPTS.name}")
else:
    print(f"WARN: {DEV_OPTS} not found — check class relocation")

# 7.2 — LocationModuleHU: force isFromMockProvider result to 0
LOC_MOD = ROOT / "smali/com/attendancemanagementsystem/LocationModuleHU.smali"
if LOC_MOD.exists():
    text = LOC_MOD.read_text()
    # Match: invoke-virtual ...isFromMockProvider()Z ... move-result v<N>
    # Insert: const/4 v<N>, 0x0 after move-result
    pattern = re.compile(
        r"(invoke-virtual \{p1\}, Landroid/location/Location;->isFromMockProvider\(\)Z\s*"
        r"(?:\.line \d+\s*)*"
        r"move-result (v\d+))",
        re.MULTILINE,
    )
    def repl(m):
        return f"{m.group(1)}\n\n    const/4 {m.group(2)}, 0x0"
    new_text, n = pattern.subn(repl, text)
    if n == 0:
        print(f"WARN: no isFromMockProvider call site found in {LOC_MOD.name}")
    else:
        LOC_MOD.write_text(new_text)
        print(f"Patched {LOC_MOD.name} ({n} site(s))")

# 7.3 — Pairip: neutralise LicenseContentProvider.onCreate
# Try both smali roots — DEX sharding may move this class
for root_name in ("smali_classes2", "smali_classes3", "smali_classes4", "smali"):
    PAIRIP = ROOT / f"{root_name}/com/pairip/licensecheck/LicenseContentProvider.smali"
    if PAIRIP.exists():
        NEUTRAL = """.method public onCreate()Z
    .locals 1

    const/4 v0, 0x1

    return v0
.end method"""
        text = PAIRIP.read_text()
        text = re.sub(
            r"\.method public onCreate\(\)Z.*?\.end method",
            NEUTRAL, text, flags=re.DOTALL,
        )
        PAIRIP.write_text(text)
        print(f"Patched {PAIRIP}")
        break
else:
    print("INFO: Pairip LicenseContentProvider not found — may have been removed")
```

On first use, adjust grep paths / smali-class paths if obfuscation moved anything.
The script will print WARN/INFO lines to help spot drift.

---

## 12. Troubleshooting

### 12.1 App installs but crashes on launch

Run logcat (see 12.2). Match the top of the stack trace to one of:

| Symptom | Cause | Fix |
|---|---|---|
| `Resources$NotFoundException` for a drawable | apktool @null artifact | Section 8.1, extend to the named drawable |
| `FATAL EXCEPTION` with `pairip` in the trace | Pairip not fully stubbed | Re-check Section 7.3; consider also stubbing `LicenseActivity.onCreate` to call `finish()` |
| `dlopen failed` / `UnsatisfiedLinkError` | Missing .so file | Section 5 merge was incomplete — re-copy `arm64/lib/` into `base/lib/` |
| `INSTALL_FAILED_MISSING_SPLIT` | Manifest split attributes still present | Section 6.2 |
| Dialog: *"not recognised, search on Google Play"* | Pairip active | Section 7.3 |

### 12.2 Capture logcat

Wireless adb connection (after pair + connect — see 12.4):

```bat
adb logcat -c
adb logcat -v time > crash.log
```

Launch the app, reproduce the crash, then Ctrl+C. Filter with:

```bat
findstr /I /C:"FATAL" /C:"AndroidRuntime" /C:"pairip" /C:"attendancemanagementsystem" /C:"Caused by" crash.log
```

### 12.3 adb device not listed (USB)

1. Phone USB mode set to **File Transfer (MTP)**, not charging-only.
2. Samsung USB driver installed on Windows (samsung.com).
3. `adb kill-server && adb start-server && adb devices`.
4. RSA authorization prompt accepted on phone (may need to revoke existing
   authorizations in Developer Options first).
5. Fall back to wireless (12.4) if USB keeps failing.

### 12.4 Wireless adb connection

On phone: **Developer Options → Wireless debugging** → toggle on.

**Crucial:** the *pairing* port and the *connect* port are different and both
rotate when Wireless Debugging is toggled or the screen is left.

```bat
adb pair <phone-ip>:<PAIRING-PORT>        # from "Pair with pairing code" screen
# enter 6-digit code
adb connect <phone-ip>:<CONNECT-PORT>     # from main Wireless Debugging screen
adb devices
```

To lock the connect port at 5555 (survives until phone reboot), plug in USB once
and run `adb tcpip 5555`, then `adb connect <phone-ip>:5555` forever after.

---

## 13. Complete list of files modified (2.1.7 reference)

This is the delta vs. a freshly unpacked 2.1.7. Use it as a checklist when
diffing against a new version.

| File | Change |
|------|--------|
| `AndroidManifest.xml` | `extractNativeLibs` flip; remove `requiredSplitTypes`, `splitTypes`, 3 split meta-data lines |
| `lib/arm64-v8a/*` | All .so files copied in from arm64 split |
| `smali/com/attendancemanagementsystem/DeveloperOptionsModule.smali` | 4 methods stubbed to resolve Boolean.FALSE |
| `smali/com/attendancemanagementsystem/LocationModuleHU.smali` | `const/4 v<REG>, 0x0` inserted after `isFromMockProvider` move-result |
| `smali_classes2/com/pairip/licensecheck/LicenseContentProvider.smali` | `onCreate()` replaced with no-op returning `true` |
| `res/drawable/rn_edit_text_material.xml` | Two `@null` drawables replaced with `@android:color/transparent` |

---

## 14. What is explicitly NOT patched, and why

- **Face recognition (`FaceAuthModule.smali`)** — kept intact to preserve the
  identity-verification layer of the demo. The point is to show the geofence
  falls, not to bypass biometrics.
- **Backend OTP / phone whitelist** — server-side, cannot be patched from the
  APK, and tampering with auth crosses from "reverse engineering for learning"
  into "account takeover." Out of scope.
- **Geofence radius calculation in the JS bundle** — not needed. Neutralising
  the mock-location detectors is sufficient: any fake-GPS app now feeds coords
  the geofence happily accepts.

---

## 15. Quick reference for an agent given a new version

If you are an AI coding agent pointed at an unpacked `<new_version>/` directory
and asked to reproduce this patch, the minimum you need to do is:

1. Read this file end-to-end.
2. Verify the five patch targets exist by grepping:
   - `isAdbEnabled`, `isDeveloperOptionsEnabled`, `isMockLocationEnabled`,
     `isStayAwakeEnabled` in `smali/com/attendancemanagementsystem/DeveloperOptionsModule.smali`
   - `Landroid/location/Location;->isFromMockProvider()Z` somewhere under
     `smali/com/attendancemanagementsystem/`
   - `Lcom/pairip/licensecheck/LicenseContentProvider;` somewhere under
     `smali_classes*/`
   - `res/drawable/rn_edit_text_material.xml`
3. If any target is missing, **stop and report** — do not guess. Missing targets
   mean the publisher has restructured something and a human should look.
4. If all targets are found, apply the patches per Sections 6-8.
5. Run Section 9 to rebuild and sign.
6. Report the output APK path and flag any WARN lines from `apply_patches.py`.

If the user asks you to add new bypasses (e.g., a new detector surfaced), follow
the same grep-first-then-patch discipline and update this guide with a new
subsection under Section 7.
