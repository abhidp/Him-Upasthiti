# Installing the patched app on an Android Studio emulator (AVD)

The patcher (`autopatch.ps1` / `PATCH-NEW-VERSION.bat`) can install to a virtual device
exactly like a physical phone — an emulator is just another adb target. This guide covers
the one-time AVD setup and the gotcha specific to this app.

## The one important constraint (read this first)

This app ships **ARM64-only** native libraries (Hermes, Reanimated, etc.), but your PC is
**Intel x86_64**. An x86_64 emulator can only run an ARM64-only app through Google's
**ARM-to-x86 translation**, which exists **only** on:

- **Google Play** or **Google APIs** system images (NOT plain "AOSP" images), and
- **API 30 (Android 11) or newer**.

Pick the wrong image and the install fails with `INSTALL_FAILED_NO_MATCHING_ABIS`.

> **What works / what doesn't on an emulator:**
> Good for confirming the app **installs and launches with no Pairip "not recognised" dialog**.
> It is NOT a full attendance test: emulators can't receive real SMS (no OTP login), and the
> camera is a simulated feed (face verification won't pass). Your **physical phone remains the
> end-to-end path.** Heavy React Native native code under ARM translation can also occasionally
> crash — if it does, that's the emulator, not the patch.

## Option A — reuse your existing AVD (fastest)

You already have an AVD named **`Medium_Phone_API_36`** built on a
**`google_apis_playstore` x86_64** image — that's the correct image family. Just use it:

1. Android Studio → **Device Manager** (the phone icon in the right sidebar, or
   *Tools → Device Manager*).
2. Click the **▶ (Play)** button next to `Medium_Phone_API_36`. Wait for it to fully boot to
   the home screen.
3. Confirm it's visible to adb (in a terminal):
   ```powershell
   adb devices
   ```
   You should see a line like `emulator-5554   device`.

## Option B — create a new AVD (if Option A misbehaves)

1. Device Manager → **Create Device** (the **+**).
2. Hardware: pick **Pixel** (e.g. Pixel 6/7) → **Next**.
3. System image: choose **x86_64**, tag **Google Play** or **Google APIs**, **API 34**
   (Android 14) is a solid default; **API 30** is the most battle-tested for ARM translation.
   Download it if needed → **Next** → **Finish**.
   - ⚠️ Do NOT pick a plain "AOSP" image — those lack ARM translation.
4. Launch it (▶) and confirm with `adb devices` as above.

## Running the patcher against the emulator

Nothing special — use the normal flow:

1. Make sure the emulator is **booted** (Option A/B) and shows in `adb devices`.
2. Double-click **`PATCH-NEW-VERSION.bat`**, enter the version, let it build + sign.
3. At **`Install to connected device now? (y/n)`** type `y`.
   - If only the emulator is connected, it installs there automatically.
   - If both your phone **and** the emulator are connected, the patcher prints a numbered
     menu — pick the emulator (it's the `emulator-XXXX` entry).
4. Expect `INSTALL PASS`. Open the app in the emulator → no Pairip dialog.

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `INSTALL_FAILED_NO_MATCHING_ABIS` | Emulator image has no ARM64 translation | Use a **Google Play / Google APIs x86_64** image, **API 30+** (Option B). Plain AOSP images won't work. |
| App installs but crashes instantly; logcat shows `dlopen failed` / `UnsatisfiedLinkError` | ARM translation couldn't load a native `.so` | Try an **API 30** or **API 34** Google APIs image. If it still crashes, this app's native code doesn't translate cleanly — use the **physical phone**. |
| `adb devices` doesn't show the emulator | Two adb versions (WinGet platform-tools vs the SDK's adb) fighting over the adb server | `adb kill-server; adb start-server; adb devices`. If it persists, run the SDK's adb (`%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe`) once to align versions. |
| Emulator very slow | Full ARM emulation instead of translation, or no hardware acceleration | Confirm the image is x86_64 (not arm64), and that Intel HAXM / Windows Hypervisor Platform is enabled. |
| Pairip dialog still appears | Patch didn't apply / old build | Rebuild via the `.bat`; the run must show both Pairip `[ok]` lines from `apply_patches.py`. |

## How this works in the script (for reference)

The install step in `scripts/autopatch.ps1` enumerates `adb devices`, then:
- 0 devices → prints a hint, skips install.
- 1 device → installs to it automatically (phone or emulator — same code path).
- 2+ devices → numbered menu; installs to your pick via `adb -s <serial> install`.

So physical and virtual targets are handled by the **same single script** — no separate
emulator script to maintain.
