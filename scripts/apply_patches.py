#!/usr/bin/env python3
"""
Apply smali + drawable patches for Him Upasthiti.

Usage:
    python apply_patches.py <unpacked_apk_dir>

Corresponds to PATCHING_GUIDE.md sections 7 and 8. Matches targets by
stable identifiers (framework classes, @ReactMethod names, third-party
package paths) so it survives obfuscation drift between versions.

Exits non-zero if any expected target is missing, so the calling
pipeline can halt rather than ship a broken APK.
"""
import re
import sys
import pathlib

if len(sys.argv) != 2:
    sys.exit("usage: apply_patches.py <unpacked_apk_dir>")

ROOT = pathlib.Path(sys.argv[1])
if not ROOT.is_dir():
    sys.exit(f"not a directory: {ROOT}")

problems = []


# ---------------------------------------------------------------------------
# 7.1 DeveloperOptionsModule: stub all four detector methods
# ---------------------------------------------------------------------------
DEV_OPTS = ROOT / "smali/com/attendancemanagementsystem/DeveloperOptionsModule.smali"

STUB = """.method public final {name}(Lcom/facebook/react/bridge/Promise;)V
    .locals 1
    .annotation runtime Lcom/facebook/react/bridge/ReactMethod;
    .end annotation

    sget-object v0, Ljava/lang/Boolean;->FALSE:Ljava/lang/Boolean;
    invoke-interface {{p1, v0}}, Lcom/facebook/react/bridge/Promise;->resolve(Ljava/lang/Object;)V
    return-void
.end method"""

DETECTOR_METHODS = (
    "isAdbEnabled",
    "isDeveloperOptionsEnabled",
    "isMockLocationEnabled",
    "isStayAwakeEnabled",
)

if DEV_OPTS.exists():
    text = DEV_OPTS.read_text()
    replaced = 0
    for name in DETECTOR_METHODS:
        pattern = (
            rf"\.method public final {name}\(Lcom/facebook/react/bridge/Promise;\)V"
            r".*?\.end method"
        )
        new_text, n = re.subn(pattern, STUB.format(name=name), text, flags=re.DOTALL)
        if n == 0:
            problems.append(f"  missing method: {name} in DeveloperOptionsModule")
        else:
            replaced += n
            text = new_text
    DEV_OPTS.write_text(text)
    print(f"[ok] DeveloperOptionsModule: stubbed {replaced}/{len(DETECTOR_METHODS)} methods")
else:
    problems.append(f"  file missing: {DEV_OPTS}")


# ---------------------------------------------------------------------------
# 7.2 LocationModuleHU: force isFromMockProvider result to 0
# ---------------------------------------------------------------------------
LOC_MOD = ROOT / "smali/com/attendancemanagementsystem/LocationModuleHU.smali"

# Match: invoke-virtual ...isFromMockProvider()Z, then (possibly .line lines),
# then move-result vN. Insert const/4 vN, 0x0 immediately after move-result.
MOCK_PATTERN = re.compile(
    r"(invoke-virtual \{p1\}, Landroid/location/Location;->isFromMockProvider\(\)Z\s*"
    r"(?:\.line \d+\s*)*"
    r"move-result (v\d+))",
    re.MULTILINE,
)

def _mock_repl(m):
    block, reg = m.group(1), m.group(2)
    # Don't double-patch if the overwrite already exists
    return f"{block}\n\n    const/4 {reg}, 0x0"

if LOC_MOD.exists():
    text = LOC_MOD.read_text()
    if re.search(r"move-result (v\d+)\s+const/4 \1, 0x0", text):
        print("[ok] LocationModuleHU: already patched, skipping")
    else:
        new_text, n = MOCK_PATTERN.subn(_mock_repl, text)
        if n == 0:
            problems.append("  no isFromMockProvider call site found in LocationModuleHU")
        else:
            LOC_MOD.write_text(new_text)
            print(f"[ok] LocationModuleHU: patched {n} call site(s)")
else:
    problems.append(f"  file missing: {LOC_MOD}")


# ---------------------------------------------------------------------------
# 7.3 Pairip: neutralise LicenseContentProvider.onCreate
# ---------------------------------------------------------------------------
NEUTRAL_ONCREATE = """.method public onCreate()Z
    .locals 1

    const/4 v0, 0x1

    return v0
.end method"""

pairip_found = False
for smali_root in ("smali_classes2", "smali_classes3", "smali_classes4", "smali"):
    pairip = ROOT / smali_root / "com/pairip/licensecheck/LicenseContentProvider.smali"
    if pairip.exists():
        text = pairip.read_text()
        new_text, n = re.subn(
            r"\.method public onCreate\(\)Z.*?\.end method",
            NEUTRAL_ONCREATE, text, flags=re.DOTALL,
        )
        if n == 0:
            problems.append(f"  onCreate() not found in {pairip}")
        else:
            pairip.write_text(new_text)
            print(f"[ok] Pairip: neutralised onCreate in {smali_root}")
        pairip_found = True
        break

if not pairip_found:
    print("[info] Pairip LicenseContentProvider not present — may have been removed")


# ---------------------------------------------------------------------------
# 7.4 Pairip: neutralise LicenseClient.checkLicense (2.1.9+ trigger)
#
# 2.1.9 introduced com/pairip/application/Application, whose attachBaseContext()
# calls LicenseClient.checkLicense(context) on the very first line of app startup.
# This is a SECOND Pairip trigger that the 7.3 ContentProvider patch does NOT
# cover, and it fires the "app not recognised / get it from Play" dialog at
# launch even when 7.3 is applied. Stub checkLicense to a no-op so the
# LicenseClient is never constructed, regardless of which caller invokes it.
# (Pre-2.1.9 builds may not have this method — treated as info, not an error.)
# ---------------------------------------------------------------------------
NEUTRAL_CHECKLICENSE = """.method public static checkLicense(Landroid/content/Context;)V
    .locals 0

    return-void
.end method"""

checklicense_found = False
for smali_root in ("smali_classes2", "smali_classes3", "smali_classes4", "smali"):
    license_client = ROOT / smali_root / "com/pairip/licensecheck/LicenseClient.smali"
    if license_client.exists():
        text = license_client.read_text()
        new_text, n = re.subn(
            r"\.method public static checkLicense\(Landroid/content/Context;\)V.*?\.end method",
            NEUTRAL_CHECKLICENSE, text, flags=re.DOTALL,
        )
        if n == 0:
            print("[info] Pairip: checkLicense() absent in LicenseClient "
                  "(pre-2.1.9 layout) — skipping")
        else:
            license_client.write_text(new_text)
            print(f"[ok] Pairip: neutralised checkLicense in {smali_root}")
        checklicense_found = True
        break

if not checklicense_found:
    print("[info] Pairip LicenseClient not present — may have been removed")


# ---------------------------------------------------------------------------
# 8.1 Drawable @null fix for rn_edit_text_material
# ---------------------------------------------------------------------------
DRW = ROOT / "res/drawable/rn_edit_text_material.xml"
if DRW.exists():
    text = DRW.read_text()
    new_text = text.replace(
        'android:drawable="@null"',
        'android:drawable="@android:color/transparent"',
    )
    if new_text == text:
        print("[ok] rn_edit_text_material: already fixed or no @null present")
    else:
        DRW.write_text(new_text)
        print("[ok] rn_edit_text_material: @null -> @android:color/transparent")
else:
    problems.append(f"  file missing: {DRW}")


# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
if problems:
    print()
    print("PROBLEMS:")
    for p in problems:
        print(p)
    print()
    print("One or more patch targets were missing or unmatched.")
    print("The publisher likely restructured something in this version.")
    print("See PATCHING_GUIDE.md section 15 for the manual triage steps.")
    sys.exit(1)

print()
print("All patches applied successfully.")
