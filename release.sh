#!/bin/zsh
# Builds a Developer ID–signed, notarized, stapled FocusShield.dmg in ./dist, ready to upload.
#
# One-time setup:
#   1. Xcode → Settings → Accounts → Manage Certificates → + → "Developer ID Application"
#   2. Store notarization credentials (use an app-specific password from account.apple.com):
#        xcrun notarytool store-credentials FocusShield --apple-id YOU@example.com --team-id QB5TT8MRYA
set -euo pipefail
cd "$(dirname "$0")"

PROFILE="${NOTARY_PROFILE:-FocusShield}"
IDENTITY="${SIGN_IDENTITY:-$(security find-identity -v -p codesigning | grep -o '"Developer ID Application:[^"]*"' | head -1 | tr -d '"')}"
if [[ -z "$IDENTITY" ]]; then
    echo "✗ No 'Developer ID Application' certificate found. See the setup notes at the top of this script." >&2
    exit 1
fi
echo "→ Signing as: $IDENTITY"

SIGN_IDENTITY="$IDENTITY" ./build.sh

VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" Resources/Info.plist)
DMG="dist/FocusShield-$VERSION.dmg"
STAGE=$(mktemp -d)
mkdir -p dist && rm -f "$DMG"

echo "→ Creating disk image"
cp -R "build/Focus Shield.app" "$STAGE/"
ln -s /Applications "$STAGE/Applications"
hdiutil create -volname "Focus Shield" -srcfolder "$STAGE" -ov -format UDZO "$DMG" >/dev/null
rm -rf "$STAGE"
codesign --force --timestamp --sign "$IDENTITY" "$DMG"

echo "→ Notarizing (usually 1–5 minutes)"
xcrun notarytool submit "$DMG" --keychain-profile "$PROFILE" --wait
xcrun stapler staple "$DMG"

echo "→ Verifying Gatekeeper acceptance"
spctl --assess --type open --context context:primary-signature -v "$DMG"
cp "$DMG" dist/FocusShield.dmg
shasum -a 256 dist/FocusShield.dmg
echo "✓ Ready to upload: dist/FocusShield.dmg"
