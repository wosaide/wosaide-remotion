# WOS Aide Icon System

## Source of truth

Only these files may generate platform icons:

- `bird-logo-black.svg` — Light appearance, `#242424`.
- `bird-logo-white.svg` — Dark appearance, `#FFFFFF`.

The two SVG files must use the same viewBox and path geometry. Only the fill color may differ. `wosaide-bird.png` is a visual reference and is not a raster source.

## Non-negotiable visual rules

| Appearance | Bird | Background |
| --- | --- | --- |
| Light | black `#242424` | transparent |
| Dark | white `#FFFFFF` | transparent |

Do not add a circle, plate, badge background, solid canvas, default shadow, gradient, or alternate padding. Light and dark variants must be geometrically identical. The current fill ratio is `0.84`; changing it is an Icon Kit visual change and requires a version bump.

## Platform layout

### Xcode / macOS

- `icons/v<version>/xcode/macos/light/` — black AppIcon and ICNS.
- `icons/v<version>/xcode/macos/dark/` — white AppIcon and ICNS.
- `icons/v<version>/xcode/WOSAideTheme.xcassets/BirdMark.imageset` — appearance-aware in-app asset.

The Xcode imageset can switch automatically for in-app UI. A packaged macOS application icon does not automatically change just because both AppIcon sets exist; host code must explicitly choose a runtime icon if that behavior is required.

Project-level compatibility assets live under `assets/macos/`:

- `WOSAideBird.icns` / `WOSAideBird-1024.png` — Light default.
- `WOSAideBird-Dark.icns` / `WOSAideBird-Dark-1024.png` — Dark.
- `WOSAideBird.iconset/` and `WOSAideBird-Dark.iconset/` — full matrices.

### Electron

- `electron/light/` — black transparent assets.
- `electron/dark/` — white transparent assets.
- macOS packaging uses `.icns`; Windows uses `.ico`; Linux/general surfaces use PNG.

For runtime surfaces such as tray or window icons, the host can select a theme variant using `nativeTheme.shouldUseDarkColors`. Do not assume the packaged application icon will switch automatically with the OS theme.

### Windows

- `windows/light/app.ico` — black transparent bird.
- `windows/dark/app.ico` — white transparent bird.

Each ICO contains `16, 20, 24, 32, 40, 48, 64, 128, 256` px entries. Additional PNG files are included beside each ICO.

### Chrome Extension

- `chrome/extension/light/icons/` — 16/32/48/128 px black icons.
- `chrome/extension/dark/icons/` — 16/32/48/128 px white icons.
- `manifest-icons-light.json` and `manifest-icons-dark.json` contain ready-to-copy mappings.

Manifest icons are static. If a toolbar/action icon should follow theme changes, extension code must switch to the appropriate resource at runtime.

### Chrome Web Store

Store artwork is available in `chrome/web-store/light/` and `chrome/web-store/dark/` at 128/256/512/1024 px. Select the variant that gives sufficient contrast against the store presentation background.

## Build pipeline

```bash
npm run icons:build
```

`scripts/build-icon-kit.sh` rasterizes the canonical SVG files through `scripts/render-svg-icon.swift`, generates all platform formats, creates checksums, updates `icons/CURRENT`, and writes release ZIPs to `icons/dist/`.

To build a new version explicitly:

```bash
ICON_VERSION=1.0.2 npm run icons:build
npm run icons:verify
```

## Verification

Run before every icon release:

```bash
npm run typecheck
npm run icons:verify
```

Verification checks the current version, SVG geometry parity, transparency metadata, Xcode JSON, ICO size matrices, release checksums, and expected ZIP bundles.

## Animation boundary

`brand-logo-animated.svg` and Remotion compositions may include the filament effect, laurels, and stars. Those decorative elements are not part of the static App Icon contract. Platform Icon Kits contain the bird only.
