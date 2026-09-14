# WOS Aide Icon Kit

Brand rule for this kit:

- **No circle or plate behind the bird.**
- **Light appearance:** black bird (`#242424`) on a transparent background.
- **Dark appearance:** white bird (`#ffffff`) on a transparent background.
- Every platform is generated from the same black/white SVG bird geometry.

## Xcode / macOS

- `xcode/macos/light/` — black bird AppIcon + ICNS.
- `xcode/macos/dark/` — white bird AppIcon + ICNS.
- `xcode/WOSAideTheme.xcassets/BirdMark.imageset` — appearance-aware in-app image asset: black by default, white for Dark appearance.

## Electron

- `electron/light/` — black transparent icon set.
- `electron/dark/` — white transparent icon set.
- Choose the theme-specific assets from `nativeTheme.shouldUseDarkColors` when runtime switching is desired.

## Windows

- `windows/light/app.ico` — black transparent bird.
- `windows/dark/app.ico` — white transparent bird.
- Both ICO files contain 16, 20, 24, 32, 40, 48, 64, 128 and 256 px entries.

## Chrome Extension / Chrome Web Store

- `chrome/extension/light/` and `chrome/extension/dark/` contain 16/32/48/128 px extension icons.
- `manifest-icons-light.json` and `manifest-icons-dark.json` are ready-to-copy mappings.
- Store artwork is under `chrome/web-store/light/` and `chrome/web-store/dark/`.
