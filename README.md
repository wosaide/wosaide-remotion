# WOS Aide Remotion Brand Assets

This repository contains the WOS Aide bird brand assets, Remotion animation, and cross-platform icon kits.

## Versions

- Remotion project version: `package.json` (`1.0.0`).
- Icon Kit version: `icons/CURRENT` (`1.0.1`).
- Icon release tag format: `icons-v<version>`.

The Remotion project and Icon Kit use independent version lines. Animation-only changes do not require an Icon Kit bump.

## Icon contract

- No circle, plate, or solid background behind the bird.
- Background is always transparent.
- Light appearance: black bird `#242424`.
- Dark appearance: white bird `#FFFFFF`.
- Light and dark assets must have identical geometry, scale, alignment, and padding.
- `bird-logo-black.svg` and `bird-logo-white.svg` are the raster-generation sources.
- `wosaide-bird.png` is visual reference only and must not be resized directly into platform icons.

See `docs/ICON-SYSTEM.md`, `icons/VERSIONING.md`, and `icons/CHANGELOG.md`.

## Commands

```bash
npm run typecheck
npm run icons:build
npm run icons:verify
npm run icons:version
```

