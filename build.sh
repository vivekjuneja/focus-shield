#!/bin/zsh
# Builds "Focus Shield.app" into ./build. Pass --install to copy it to /Applications and launch it.
set -euo pipefail
cd "$(dirname "$0")"

APP="build/Focus Shield.app"
rm -rf build && mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources" build/tmp

echo "→ Compiling"
swiftc -O -swift-version 5 -target arm64-apple-macosx13.0 \
    -o build/tmp/FocusShield-arm64 Sources/*.swift
swiftc -O -swift-version 5 -target x86_64-apple-macosx13.0 \
    -o build/tmp/FocusShield-x86_64 Sources/*.swift
lipo -create build/tmp/FocusShield-arm64 build/tmp/FocusShield-x86_64 -output "$APP/Contents/MacOS/FocusShield"

echo "→ Icon"
swift Resources/make_icon.swift build/tmp/AppIcon.iconset
iconutil -c icns build/tmp/AppIcon.iconset -o "$APP/Contents/Resources/AppIcon.icns"

cp Resources/Info.plist "$APP/Contents/Info.plist"
# SIGN_IDENTITY defaults to ad-hoc; release.sh passes a Developer ID for distribution.
if [[ -n "${SIGN_IDENTITY:-}" ]]; then
    codesign --force --options runtime --timestamp \
        --entitlements Resources/FocusShield.entitlements --sign "$SIGN_IDENTITY" "$APP"
else
    codesign --force --sign - "$APP"
fi
rm -rf build/tmp
echo "✓ Built $APP"

if [[ "${1:-}" == "--install" ]]; then
    pkill -x FocusShield 2>/dev/null || true
    rm -rf "/Applications/Focus Shield.app"
    cp -R "$APP" /Applications/
    open "/Applications/Focus Shield.app"
    echo "✓ Installed and launched /Applications/Focus Shield.app"
fi
