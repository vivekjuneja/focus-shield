#!/bin/zsh
# Ships what release.sh built: creates the GitHub release first, then pushes the update feed,
# so apps are never told about an update whose download doesn't exist yet.
set -euo pipefail
cd "$(dirname "$0")"

VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" Resources/Info.plist)
NOTES="release-notes/$VERSION.md"
grep -q "<sparkle:shortVersionString>$VERSION<" docs/appcast.xml || { echo "✗ Run ./release.sh first" >&2; exit 1; }

SHA=$(shasum -a 256 dist/FocusShield.dmg | cut -d' ' -f1)
gh release create "v$VERSION" dist/FocusShield.dmg --repo vivekjuneja/focus-shield \
    --title "Focus Shield $VERSION" \
    --notes "$(cat "$NOTES")

Signed with Developer ID and notarized by Apple. Requires macOS 13 or newer (Apple silicon and Intel).

SHA-256: \`$SHA\`"

git add docs/appcast.xml
git commit -m "Update feed: v$VERSION"
git push origin main
echo "✓ Shipped v$VERSION. Installed copies will pick it up within a day."
