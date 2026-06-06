# Build tools — versions & sources

The patch pipeline depends on a few external tools. The two Java JARs are
**committed into this repo** (`tools/`) so a fresh clone is self-contained and
works offline. The rest (JDK, adb, Python) are standard installs on the host.

> `autopatch.ps1` looks for the JARs in `base_extracted/tools/` first, then falls
> back to the project-root copy. So the committed copies in `tools/` are the
> canonical, version-controlled ones.

## Committed in this repo (`base_extracted/tools/`)

| Tool | Version | File | Purpose |
|------|---------|------|---------|
| Apktool | **3.0.1** | `tools/apktool.jar` | Decode/rebuild the APK (smali + resources) |
| uber-apk-signer | **1.3.0** | `tools/signer.jar` | Zipalign + v2/v3 sign the rebuilt APK |

uber-apk-signer 1.3.0 bundles its own `zipalign` (33.0.2) — no separate
Android build-tools install needed for signing.

### Where these came from (if you ever need to re-download the exact versions)

- **Apktool 3.0.1** — https://apktool.org/ → "downloads", or
  https://github.com/iBotPeaches/Apktool/releases/tag/v3.0.1
  (rename the downloaded `apktool_3.0.1.jar` to `apktool.jar`).
- **uber-apk-signer 1.3.0** — https://github.com/patrickfav/uber-apk-signer/releases/tag/v1.3.0
  (`uber-apk-signer-1.3.0.jar` → rename to `signer.jar`).

Using a different major version may change apktool's resource decoding or the
signer's output filename; if you upgrade, re-test the full pipeline once.

## Host tools (installed on the machine, not in the repo)

| Tool | Version used | How to get it |
|------|--------------|---------------|
| JDK (Java) | 17 (11+ works) | **Required.** Zulu/Temurin/Oracle JDK; must be on `PATH` (`java -version`) |
| Python | 3.11 (3.x) | **Required.** python.org; must be on `PATH` (`python --version`) — used to unzip the XAPK and run `apply_patches.py` |
| adb (platform-tools) | 1.0.41 | **Optional — only needed to auto-install to a device.** Android SDK Platform-Tools on `PATH`. A build-only machine (just produce the signed APK, copy it to the phone manually) does NOT need adb; the script skips it. |

### Minimum to just patch + build + sign (no device install)

A fresh Windows machine needs only: **JDK** + **Python** on PATH, plus this repo
(which already contains `tools/apktool.jar` + `tools/signer.jar`). Clone it, drop the
XAPK in `Downloads`, double-click `PATCH-NEW-VERSION.bat`, answer `n` at the install
prompt — the signed APK lands in `Projects\Him Upasthiti_<ver>_APKPure\`. No adb, no
Android Studio, no USB needed.

## Note on git and large files

The two JARs (~18 MB total) are intentionally tracked so nothing is lost. If you
ever want to keep the repo lean instead, remove them from `tools/`, add
`tools/*.jar` to a `.gitignore`, and rely on this file to re-download the exact
versions above. Generated build artifacts (the per-version work folders and signed
APKs) live **outside** this repo under `Projects\Him Upasthiti_<ver>_APKPure\`, so
they never bloat git.
