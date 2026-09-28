#!/usr/bin/env python3
"""Wire Codemagic's Android signing env vars into the generated Gradle file.

`flutter create` writes `android/app/build.gradle.kts` with

    signingConfig = signingConfigs.getByName("debug")

so a release build is signed with the debug key and cannot be uploaded to
Play Store. Declaring `android_signing` in codemagic.yaml only injects the
keystore and the CM_KEYSTORE_* variables; Gradle still has to consume them.

This script runs after `flutter create` and before the build. It only touches
the file when the signing variables are present, so local runs that never set
them are unaffected.
"""

import os
import sys

GRADLE = os.path.join("android", "app", "build.gradle.kts")

SIGNING_CONFIG = '''    signingConfigs {
        create("release") {
            val keystorePath = System.getenv("CM_KEYSTORE_PATH")
            if (keystorePath != null) {
                storeFile = file(keystorePath)
                storePassword = System.getenv("CM_KEYSTORE_PASSWORD")
                keyAlias = System.getenv("CM_KEY_ALIAS")
                keyPassword = System.getenv("CM_KEY_PASSWORD")
            }
        }
    }

'''

# Only switch to the release key when Codemagic actually injected a keystore;
# otherwise fall back to the debug key so local tooling keeps working.
RELEASE_SIGNING_LINE = '''            signingConfig = if (System.getenv("CM_KEYSTORE_PATH") != null) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }'''


def main() -> int:
    if not os.path.exists(GRADLE):
        print(f"{GRADLE} not found; run `flutter create` first", file=sys.stderr)
        return 1

    with open(GRADLE, encoding="utf-8") as fh:
        source = fh.read()

    if 'create("release")' in source:
        print("signing already configured; nothing to do")
        return 0

    if "    signingConfigs {" not in source:
        source = source.replace("android {\n", "android {\n" + SIGNING_CONFIG, 1)
    source = source.replace(
        '            signingConfig = signingConfigs.getByName("debug")',
        RELEASE_SIGNING_LINE,
    )

    if "signingConfigs.getByName(\"release\")" not in source:
        print("could not locate the release signingConfig line", file=sys.stderr)
        return 1

    with open(GRADLE, "w", encoding="utf-8") as fh:
        fh.write(source)

    print("configured release signing in", GRADLE)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
