# Focus Shield

A small macOS menu bar app that blocks YouTube, Netflix, X and Prime Video in Chrome and Safari.
To pause it, you first read three facts about attention (from Jonathan Haidt, Johann Hari, Cal Newport,
Gloria Mark and others), then choose 30 minutes or 1 hour. The shield turns itself back on afterwards.

**Download:** https://shieldfocus.app

## How it works

The app checks the web address of each open Chrome and Safari tab about once a second, using Apple Events.
Tabs on a blocked site are redirected to a local "Focus Shield is on" page. Nothing is stored or sent anywhere,
and the app makes no network connections.

## Building

Requires Xcode command-line tools (Swift 5.9+), macOS 13+.

```sh
./build.sh             # ad-hoc signed build in ./build
./build.sh --install   # also copies to /Applications and launches
./release.sh           # Developer ID signed, notarized .dmg in ./dist (see script header for setup)
```

- Blocked sites: `Sources/ShieldState.swift`
- Facts: `Sources/Facts.swift`
- Website: `docs/index.html` (served by GitHub Pages)
