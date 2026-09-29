#!/bin/zsh
# Builds "Focus Shield.app" into ./build. Pass --install to copy it to /Applications and launch it.
set -euo pipefail
cd "$(dirname "$0")"

APP="build/Focus Shield.app"
SPARKLE_VERSION=2.10.0
SPARKLE=vendor/Sparkle

if [[ ! -d "$SPARKLE/Sparkle.framework" ]]; then
    echo "→ Fetching Sparkle $SPARKLE_VERSION"
    mkdir -p "$SPARKLE"
    gh release download "$SPARKLE_VERSION" --repo sparkle-project/Sparkle \
        --pattern "Sparkle-$SPARKLE_VERSION.tar.xz" --dir vendor --clobber
    tar -xJf "vendor/Sparkle-$SPARKLE_VERSION.tar.xz" -C "$SPARKLE"
    rm "vendor/Sparkle-$SPARKLE_VERSION.tar.xz"
fi

rm -rf build && mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources" "$APP/Contents/Frameworks" build/tmp

echo "→ Compiling"
swiftc -O -swift-version 5 -target arm64-apple-macosx13.0 \
    -F "$SPARKLE" -framework Sparkle -Xlinker -rpath -Xlinker @executable_path/../Frameworks \
    -o build/tmp/FocusShield-arm64 Sources/*.swift
swiftc -O -swift-version 5 -target x86_64-apple-macosx13.0 \
    -F "$SPARKLE" -framework Sparkle -Xlinker -rpath -Xlinker @executable_path/../Frameworks \
    -o build/tmp/FocusShield-x86_64 Sources/*.swift
lipo -create build/tmp/FocusShield-arm64 build/tmp/FocusShield-x86_64 -output "$APP/Contents/MacOS/FocusShield"

echo "→ Icon"
swift Resources/make_icon.swift build/tmp/AppIcon.iconset
iconutil -c icns build/tmp/AppIcon.iconset -o "$APP/Contents/Resources/AppIcon.icns"

cp Resources/Info.plist "$APP/Contents/Info.plist"
ditto "$SPARKLE/Sparkle.framework" "$APP/Contents/Frameworks/Sparkle.framework"

# SIGN_IDENTITY defaults to ad-hoc; release.sh passes a Developer ID for distribution.
# Sparkle's helpers are signed inside-out, as its documentation describes.
if [[ -n "${SIGN_IDENTITY:-}" ]]; then
    SIGN=(codesign --force --options runtime --timestamp --sign "$SIGN_IDENTITY")
else
    SIGN=(codesign --force --sign -)
fi
FW="$APP/Contents/Frameworks/Sparkle.framework/Versions/B"
"${SIGN[@]}" "$FW/XPCServices/Installer.xpc"
"${SIGN[@]}" --preserve-metadata=entitlements "$FW/XPCServices/Downloader.xpc"
"${SIGN[@]}" "$FW/Autoupdate"
"${SIGN[@]}" "$FW/Updater.app"
"${SIGN[@]}" "$APP/Contents/Frameworks/Sparkle.framework"
if [[ -n "${SIGN_IDENTITY:-}" ]]; then
    "${SIGN[@]}" --entitlements Resources/FocusShield.entitlements "$APP"
else
    "${SIGN[@]}" "$APP"
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
