#!/bin/zsh
# Builds a Developer ID–signed, notarized, stapled FocusShield.dmg in ./dist and writes the
# Sparkle update feed (docs/appcast.xml). Release notes come from release-notes/<version>.md,
# one "- " bullet per line. Run ./publish.sh afterwards to ship it.
#
# One-time setup:
#   1. Xcode → Settings → Accounts → Manage Certificates → + → "Developer ID Application"
#   2. Store notarization credentials (use an app-specific password from account.apple.com):
#        xcrun notarytool store-credentials FocusShield --apple-id YOU@example.com --team-id QB5TT8MRYA
#   3. The Sparkle update-signing key must be in the Keychain (vendor/Sparkle/bin/generate_keys --account focus-shield).
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
BUILD=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" Resources/Info.plist)
NOTES="release-notes/$VERSION.md"
[[ -f "$NOTES" ]] || { echo "✗ Missing $NOTES" >&2; exit 1; }
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

echo "→ Writing update feed"
SIGNATURE=$(vendor/Sparkle/bin/sign_update --account focus-shield dist/FocusShield.dmg)
NOTES_HTML=$(sed -n 's/^- \(.*\)/<li>\1<\/li>/p' "$NOTES")
cat > docs/appcast.xml <<XML
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
  <channel>
    <title>Focus Shield</title>
    <link>https://shieldfocus.app/appcast.xml</link>
    <item>
      <title>Version $VERSION</title>
      <pubDate>$(LC_ALL=C date -u "+%a, %d %b %Y %H:%M:%S +0000")</pubDate>
      <sparkle:version>$BUILD</sparkle:version>
      <sparkle:shortVersionString>$VERSION</sparkle:shortVersionString>
      <sparkle:minimumSystemVersion>13.0</sparkle:minimumSystemVersion>
      <description><![CDATA[<ul>$NOTES_HTML</ul>]]></description>
      <enclosure url="https://github.com/vivekjuneja/focus-shield/releases/download/v$VERSION/FocusShield.dmg"
                 type="application/octet-stream" $SIGNATURE />
    </item>
  </channel>
</rss>
XML
echo "✓ Ready: dist/FocusShield.dmg and docs/appcast.xml. Run ./publish.sh to ship v$VERSION."
