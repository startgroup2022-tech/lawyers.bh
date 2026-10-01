#!/usr/bin/env python3
"""Reapply the Android platform tweaks that `flutter create` does not write.

`android/` is intentionally not committed (Codemagic regenerates it with
`flutter create`), so anything done by hand in that folder is gone on the next
build. What the app needs that Flutter's templates do not provide:

1. `android.permission.INTERNET` in the *main* manifest. Flutter only puts it in
   `src/debug`, on the assumption that debug builds need it for the tooling and
   release builds do not. An app that talks to an API over the network does need
   it in release, so the release APK/AAB otherwise has no network access at all
   and every request fails as "تعذّر الاتصال بالخادم".

2. The official app name. `flutter create` labels the launcher with the Dart
   package name (`lawyers_bh_client`); the app must read "محامون البحرين", the
   name the website and the in-app `MaterialApp.title` use.

3. The official launcher icon. The template ships Flutter's default icon; the
   pre-rendered official icons live in `tool/android_branding/` (the brand-red
   tile with the Lawyers.bh seal, plus the adaptive-icon foreground), so no
   image tooling is needed at build time. An adaptive icon is wired up for
   API 26+ (red background, seal foreground) and the legacy mipmaps are used
   below that.

4. A branded launch window: brand red with the official white wordmark, so the
   pre-Flutter window matches the in-app splash instead of flashing white.

This runs right after the `flutter create` step and before the build. It is
idempotent, so running it again is harmless.
"""

import os
import re
import shutil
import sys

MAIN_MANIFEST = os.path.join("android", "app", "src", "main", "AndroidManifest.xml")
RES_DIR = os.path.join("android", "app", "src", "main", "res")
COLORS_XML = os.path.join(RES_DIR, "values", "colors.xml")
LAUNCH_DRAWABLES = [
    os.path.join(RES_DIR, "drawable", "launch_background.xml"),
    os.path.join(RES_DIR, "drawable-v21", "launch_background.xml"),
]
ADAPTIVE_ICON = os.path.join(RES_DIR, "mipmap-anydpi-v26", "ic_launcher.xml")

BRANDING_SRC = os.path.join("tool", "android_branding")

# The name shown under the launcher icon. Matches `MaterialApp.title` and the
# website's Arabic site name.
APP_LABEL = "محامون البحرين"

INTERNET_PERMISSION = '    <uses-permission android:name="android.permission.INTERNET"/>'

COLORS_XML_BODY = """<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- Brand red (#B91D1C). The native launch window paints this, so the
         first frame matches the in-app splash instead of flashing white. -->
    <color name="brand_red">#FFB91D1C</color>
</resources>
"""

LAUNCH_DRAWABLE_BODY = """<?xml version="1.0" encoding="utf-8"?>
<!-- The window shown while the Android process starts, before Flutter's first
     frame. Painted brand red with the official wordmark so it matches the
     in-app splash. -->
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@color/brand_red" />
    <item>
        <bitmap
            android:gravity="center"
            android:src="@drawable/launch_logo" />
    </item>
</layer-list>
"""

ADAPTIVE_ICON_BODY = """<?xml version="1.0" encoding="utf-8"?>
<!-- Official Lawyers.bh adaptive icon: the brand-red field with the BH seal as
     the foreground. The foreground art is pre-centred inside the 66/108 safe
     zone, so no extra inset is applied here. -->
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/brand_red" />
    <foreground android:drawable="@mipmap/ic_launcher_foreground" />
</adaptive-icon>
"""


def add_internet_permission() -> bool:
    if not os.path.exists(MAIN_MANIFEST):
        print(f"{MAIN_MANIFEST} not found; run `flutter create` first", file=sys.stderr)
        return False

    with open(MAIN_MANIFEST, encoding="utf-8") as fh:
        source = fh.read()

    if "android.permission.INTERNET" in source:
        print("INTERNET permission already present")
        return True

    # Insert immediately after the opening <manifest ...> tag so the permission
    # is declared before <application>, which is the required ordering.
    match = re.search(r"<manifest[^>]*>", source)
    if not match:
        print("could not find the <manifest> tag", file=sys.stderr)
        return False

    source = (
        source[: match.end()]
        + "\n"
        + INTERNET_PERMISSION
        + source[match.end():]
    )

    with open(MAIN_MANIFEST, "w", encoding="utf-8") as fh:
        fh.write(source)
    print("added INTERNET permission to", MAIN_MANIFEST)
    return True


def set_app_label() -> bool:
    """Replace the `flutter create` package-name label with the official name."""
    if not os.path.exists(MAIN_MANIFEST):
        print(f"{MAIN_MANIFEST} not found; run `flutter create` first", file=sys.stderr)
        return False

    with open(MAIN_MANIFEST, encoding="utf-8") as fh:
        source = fh.read()

    updated, count = re.subn(
        r'android:label="[^"]*"',
        f'android:label="{APP_LABEL}"',
        source,
        count=1,
    )
    if count == 0:
        print("no android:label to set on <application>", file=sys.stderr)
        return False

    with open(MAIN_MANIFEST, "w", encoding="utf-8") as fh:
        fh.write(updated)
    print(f"set the application label to {APP_LABEL}")
    return True


def install_brand_icons() -> bool:
    """Copy the pre-rendered official launcher art over the template icons."""
    if not os.path.isdir(BRANDING_SRC):
        print(f"{BRANDING_SRC} not found", file=sys.stderr)
        return False

    copied = 0
    for folder, _, files in os.walk(BRANDING_SRC):
        for name in files:
            src = os.path.join(folder, name)
            dst = os.path.join(RES_DIR, os.path.relpath(src, BRANDING_SRC))
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            shutil.copyfile(src, dst)
            copied += 1

    if copied == 0:
        print(f"no icons found under {BRANDING_SRC}", file=sys.stderr)
        return False
    print(f"installed {copied} official brand assets")
    return True


def configure_adaptive_icon() -> bool:
    os.makedirs(os.path.dirname(ADAPTIVE_ICON), exist_ok=True)
    with open(ADAPTIVE_ICON, "w", encoding="utf-8") as fh:
        fh.write(ADAPTIVE_ICON_BODY)
    print("wired the adaptive launcher icon (API 26+)")
    return True


def apply_launch_background() -> bool:
    os.makedirs(os.path.dirname(COLORS_XML), exist_ok=True)
    with open(COLORS_XML, "w", encoding="utf-8") as fh:
        fh.write(COLORS_XML_BODY)

    for drawable in LAUNCH_DRAWABLES:
        os.makedirs(os.path.dirname(drawable), exist_ok=True)
        with open(drawable, "w", encoding="utf-8") as fh:
            fh.write(LAUNCH_DRAWABLE_BODY)

    print("set the brand-red launch window")
    return True


def main() -> int:
    ok = add_internet_permission()
    ok = set_app_label() and ok
    ok = install_brand_icons() and ok
    ok = configure_adaptive_icon() and ok
    ok = apply_launch_background() and ok
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
