#!/usr/bin/env python3
"""Reapply the Android platform tweaks that `flutter create` does not write.

`android/` is intentionally not committed (Codemagic regenerates it with
`flutter create`), so anything done by hand in that folder is gone on the next
build. Two things the app needs are not in Flutter's templates:

1. `android.permission.INTERNET` in the *main* manifest. Flutter only puts it in
   `src/debug`, on the assumption that debug builds need it for the tooling and
   release builds do not. An app that talks to an API over the network does need
   it in release, so the release APK/AAB otherwise has no network access at all
   and every request fails as "تعذّر الاتصال بالخادم".

2. A brand-red launch window. The template paints the pre-Flutter window white
   (or the dark theme background), which flashes before the in-app splash.

This runs right after the `flutter create` step and before the build. It is
idempotent, so running it again is harmless.
"""

import os
import re
import sys

MAIN_MANIFEST = os.path.join("android", "app", "src", "main", "AndroidManifest.xml")
COLORS_XML = os.path.join(
    "android", "app", "src", "main", "res", "values", "colors.xml"
)
LAUNCH_DRAWABLES = [
    os.path.join("android", "app", "src", "main", "res", "drawable",
                 "launch_background.xml"),
    os.path.join("android", "app", "src", "main", "res", "drawable-v21",
                 "launch_background.xml"),
]

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
     frame. Painted brand red so it matches the in-app splash. -->
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@color/brand_red" />
</layer-list>
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
    ok = apply_launch_background() and ok
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
