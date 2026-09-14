# WOS Aide Icon Kit

This package is generated from the current canonical `wosaide-bird.png` bird artwork. Do not redraw per-platform icons independently; rebuild this kit from the canonical source so Xcode, Electron, Windows, and Chrome stay visually identical.

## Xcode

- macOS: drag `xcode/macos/WOSAideIcon.xcassets` into the Xcode project and select `AppIcon` as the App Icon set.
- iOS/iPadOS: use `xcode/ios/WOSAideIcon.xcassets`.
- `xcode/macos/WOSAideBird.icns` is also included for projects that still reference an ICNS file directly.

## Electron

Use:
- macOS: `electron/icon.icns`
- Windows: `electron/icon.ico`
- Linux/general: `electron/icon.png` or the size matrix under `electron/icons/`

Typical `electron-builder` paths:

```json
{
  "build": {
    "mac": {"icon": "path/to/icon.icns"},
    "win": {"icon": "path/to/icon.ico"},
    "linux": {"icon": "path/to/icons"}
  }
}
```

## Windows

`windows/app.ico` contains 16, 20, 24, 32, 40, 48, 64, 128 and 256 px PNG-compressed icon entries. Additional PNG sizes are under `windows/png/`.

## Chrome Extension / Chrome Web Store

- Extension manifest icons: `chrome/extension/icons/` (16, 32, 48, 128 px)
- Copy/paste manifest mapping: `chrome/extension/manifest-icons.json`
- Store artwork: `chrome/web-store/`; the required item icon is `icon-128.png`, with larger source sizes included for reuse.
