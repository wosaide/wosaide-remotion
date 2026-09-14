#!/usr/bin/env bash
set -euo pipefail

ICON_VERSION="${ICON_VERSION:-1.0.0}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE="$ROOT/wosaide-bird.png"
BLACK_SVG="$ROOT/bird-logo-black.svg"
WHITE_SVG="$ROOT/bird-logo-white.svg"
ICON_ROOT="$ROOT/icons"
KIT="$ICON_ROOT/v$ICON_VERSION"
DIST="$ICON_ROOT/dist"

for tool in sips iconutil zip python3; do
  command -v "$tool" >/dev/null || { echo "Missing required tool: $tool" >&2; exit 1; }
done
[[ -f "$SOURCE" ]] || { echo "Missing source: $SOURCE" >&2; exit 1; }
[[ -f "$BLACK_SVG" ]] || { echo "Missing source: $BLACK_SVG" >&2; exit 1; }
[[ -f "$WHITE_SVG" ]] || { echo "Missing source: $WHITE_SVG" >&2; exit 1; }

rm -rf "$KIT" "$DIST"
mkdir -p "$KIT/master" "$KIT/xcode/macos/WOSAideIcon.xcassets/AppIcon.appiconset" \
  "$KIT/xcode/ios/WOSAideIcon.xcassets/AppIcon.appiconset" \
  "$KIT/electron/icons" "$KIT/windows/png" \
  "$KIT/chrome/extension/icons" "$KIT/chrome/web-store" "$DIST"

resize_png() {
  local size="$1" out="$2"
  sips -z "$size" "$size" "$SOURCE" --out "$out" >/dev/null
}

# Canonical sources
cp "$SOURCE" "$KIT/master/wosaide-bird-v$ICON_VERSION.png"
cp "$BLACK_SVG" "$KIT/master/wosaide-bird-black-v$ICON_VERSION.svg"
cp "$WHITE_SVG" "$KIT/master/wosaide-bird-white-v$ICON_VERSION.svg"
resize_png 1024 "$KIT/master/wosaide-bird-1024.png"
resize_png 512 "$KIT/master/wosaide-bird-512.png"

# Xcode / macOS AppIcon.appiconset
MAC_SET="$KIT/xcode/macos/WOSAideIcon.xcassets/AppIcon.appiconset"
resize_png 16   "$MAC_SET/icon_16x16.png"
resize_png 32   "$MAC_SET/icon_16x16@2x.png"
resize_png 32   "$MAC_SET/icon_32x32.png"
resize_png 64   "$MAC_SET/icon_32x32@2x.png"
resize_png 128  "$MAC_SET/icon_128x128.png"
resize_png 256  "$MAC_SET/icon_128x128@2x.png"
resize_png 256  "$MAC_SET/icon_256x256.png"
resize_png 512  "$MAC_SET/icon_256x256@2x.png"
resize_png 512  "$MAC_SET/icon_512x512.png"
resize_png 1024 "$MAC_SET/icon_512x512@2x.png"
cat > "$MAC_SET/Contents.json" <<'JSON'
{
  "images" : [
    {"filename":"icon_16x16.png","idiom":"mac","scale":"1x","size":"16x16"},
    {"filename":"icon_16x16@2x.png","idiom":"mac","scale":"2x","size":"16x16"},
    {"filename":"icon_32x32.png","idiom":"mac","scale":"1x","size":"32x32"},
    {"filename":"icon_32x32@2x.png","idiom":"mac","scale":"2x","size":"32x32"},
    {"filename":"icon_128x128.png","idiom":"mac","scale":"1x","size":"128x128"},
    {"filename":"icon_128x128@2x.png","idiom":"mac","scale":"2x","size":"128x128"},
    {"filename":"icon_256x256.png","idiom":"mac","scale":"1x","size":"256x256"},
    {"filename":"icon_256x256@2x.png","idiom":"mac","scale":"2x","size":"256x256"},
    {"filename":"icon_512x512.png","idiom":"mac","scale":"1x","size":"512x512"},
    {"filename":"icon_512x512@2x.png","idiom":"mac","scale":"2x","size":"512x512"}
  ],
  "info" : {"author":"xcode","version":1}
}
JSON

# Xcode / iOS AppIcon.appiconset (classic complete matrix + App Store icon)
IOS_SET="$KIT/xcode/ios/WOSAideIcon.xcassets/AppIcon.appiconset"
for spec in \
  "20 2 40 iphone" "20 3 60 iphone" \
  "29 2 58 iphone" "29 3 87 iphone" \
  "40 2 80 iphone" "40 3 120 iphone" \
  "60 2 120 iphone" "60 3 180 iphone" \
  "20 1 20 ipad" "20 2 40 ipad" \
  "29 1 29 ipad" "29 2 58 ipad" \
  "40 1 40 ipad" "40 2 80 ipad" \
  "76 1 76 ipad" "76 2 152 ipad" \
  "83.5 2 167 ipad"; do
  read -r points scale pixels idiom <<< "$spec"
  filename="icon-${points}@${scale}x.png"
  resize_png "$pixels" "$IOS_SET/$filename"
done
resize_png 1024 "$IOS_SET/icon-1024.png"
cat > "$IOS_SET/Contents.json" <<'JSON'
{
  "images" : [
    {"filename":"icon-20@2x.png","idiom":"iphone","scale":"2x","size":"20x20"},
    {"filename":"icon-20@3x.png","idiom":"iphone","scale":"3x","size":"20x20"},
    {"filename":"icon-29@2x.png","idiom":"iphone","scale":"2x","size":"29x29"},
    {"filename":"icon-29@3x.png","idiom":"iphone","scale":"3x","size":"29x29"},
    {"filename":"icon-40@2x.png","idiom":"iphone","scale":"2x","size":"40x40"},
    {"filename":"icon-40@3x.png","idiom":"iphone","scale":"3x","size":"40x40"},
    {"filename":"icon-60@2x.png","idiom":"iphone","scale":"2x","size":"60x60"},
    {"filename":"icon-60@3x.png","idiom":"iphone","scale":"3x","size":"60x60"},
    {"filename":"icon-20@1x.png","idiom":"ipad","scale":"1x","size":"20x20"},
    {"filename":"icon-20@2x.png","idiom":"ipad","scale":"2x","size":"20x20"},
    {"filename":"icon-29@1x.png","idiom":"ipad","scale":"1x","size":"29x29"},
    {"filename":"icon-29@2x.png","idiom":"ipad","scale":"2x","size":"29x29"},
    {"filename":"icon-40@1x.png","idiom":"ipad","scale":"1x","size":"40x40"},
    {"filename":"icon-40@2x.png","idiom":"ipad","scale":"2x","size":"40x40"},
    {"filename":"icon-76@1x.png","idiom":"ipad","scale":"1x","size":"76x76"},
    {"filename":"icon-76@2x.png","idiom":"ipad","scale":"2x","size":"76x76"},
    {"filename":"icon-83.5@2x.png","idiom":"ipad","scale":"2x","size":"83.5x83.5"},
    {"filename":"icon-1024.png","idiom":"ios-marketing","scale":"1x","size":"1024x1024"}
  ],
  "info" : {"author":"xcode","version":1}
}
JSON

# macOS ICNS from the canonical source
ICONSET_TMP="$KIT/.WOSAideBird.iconset"
mkdir -p "$ICONSET_TMP"
cp "$MAC_SET/icon_16x16.png"       "$ICONSET_TMP/icon_16x16.png"
cp "$MAC_SET/icon_16x16@2x.png"    "$ICONSET_TMP/icon_16x16@2x.png"
cp "$MAC_SET/icon_32x32.png"       "$ICONSET_TMP/icon_32x32.png"
cp "$MAC_SET/icon_32x32@2x.png"    "$ICONSET_TMP/icon_32x32@2x.png"
cp "$MAC_SET/icon_128x128.png"     "$ICONSET_TMP/icon_128x128.png"
cp "$MAC_SET/icon_128x128@2x.png"  "$ICONSET_TMP/icon_128x128@2x.png"
cp "$MAC_SET/icon_256x256.png"     "$ICONSET_TMP/icon_256x256.png"
cp "$MAC_SET/icon_256x256@2x.png"  "$ICONSET_TMP/icon_256x256@2x.png"
cp "$MAC_SET/icon_512x512.png"     "$ICONSET_TMP/icon_512x512.png"
cp "$MAC_SET/icon_512x512@2x.png"  "$ICONSET_TMP/icon_512x512@2x.png"
iconutil -c icns "$ICONSET_TMP" -o "$KIT/electron/icon.icns"
cp "$KIT/electron/icon.icns" "$KIT/xcode/macos/WOSAideBird.icns"

# Keep the Remotion project macOS assets in lockstep with the versioned kit.
rm -rf "$ROOT/assets/macos/WOSAideBird.iconset"
mkdir -p "$ROOT/assets/macos/WOSAideBird.iconset"
cp "$KIT/master/wosaide-bird-1024.png" "$ROOT/assets/macos/WOSAideBird-1024.png"
cp "$KIT/electron/icon.icns" "$ROOT/assets/macos/WOSAideBird.icns"
cp "$ICONSET_TMP"/*.png "$ROOT/assets/macos/WOSAideBird.iconset/"
rm -rf "$ICONSET_TMP"

# Windows PNG matrix and a real multi-resolution ICO (PNG-compressed entries)
WIN_SIZES=(16 20 24 32 40 48 64 128 256 512)
for size in "${WIN_SIZES[@]}"; do
  resize_png "$size" "$KIT/windows/png/icon-${size}.png"
done
python3 - "$KIT/windows/app.ico" "$KIT/windows/png" <<'PY'
import pathlib, struct, sys
out = pathlib.Path(sys.argv[1])
root = pathlib.Path(sys.argv[2])
sizes = [16, 20, 24, 32, 40, 48, 64, 128, 256]
images = [(s, (root / f"icon-{s}.png").read_bytes()) for s in sizes]
header = struct.pack('<HHH', 0, 1, len(images))
offset = 6 + 16 * len(images)
entries = []
payload = []
for size, data in images:
    wh = 0 if size == 256 else size
    entries.append(struct.pack('<BBBBHHII', wh, wh, 0, 0, 1, 32, len(data), offset))
    payload.append(data)
    offset += len(data)
out.write_bytes(header + b''.join(entries) + b''.join(payload))
PY
cp "$KIT/windows/app.ico" "$KIT/electron/icon.ico"
cp "$KIT/windows/png/icon-512.png" "$KIT/electron/icon.png"
resize_png 1024 "$KIT/electron/icon@2x.png"
for size in 16 32 48 64 128 256 512; do
  cp "$KIT/windows/png/icon-${size}.png" "$KIT/electron/icons/${size}x${size}.png"
done

# Chrome Extension + Chrome Web Store
for size in 16 32 48 128; do
  resize_png "$size" "$KIT/chrome/extension/icons/icon${size}.png"
done
resize_png 128  "$KIT/chrome/web-store/icon-128.png"
resize_png 256  "$KIT/chrome/web-store/icon-256.png"
resize_png 512  "$KIT/chrome/web-store/icon-512.png"
resize_png 1024 "$KIT/chrome/web-store/icon-1024.png"
cat > "$KIT/chrome/extension/manifest-icons.json" <<'JSON'
{
  "icons": {
    "16": "icons/icon16.png",
    "32": "icons/icon32.png",
    "48": "icons/icon48.png",
    "128": "icons/icon128.png"
  }
}
JSON

cat > "$KIT/VERSION.json" <<JSON
{
  "iconVersion": "$ICON_VERSION",
  "source": "wosaide-bird.png",
  "sourcePolicy": "All platform icons are derived from the current canonical WOS Aide bird image and matching black/white SVG geometry.",
  "generatedAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "packages": ["xcode-macos", "xcode-ios", "electron", "windows", "chrome-extension", "chrome-web-store"]
}
JSON
printf '%s\n' "$ICON_VERSION" > "$ICON_ROOT/CURRENT"

cat > "$KIT/README.md" <<'MD'
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
MD

# Checksums
(
  cd "$KIT"
  find . -type f ! -name SHA256SUMS.txt -print0 | sort -z | xargs -0 shasum -a 256 > SHA256SUMS.txt
)

# Platform zip bundles + all-in-one bundle
(
  cd "$KIT"
  zip -qry "$DIST/WOSAide-IconKit-v${ICON_VERSION}-Xcode.zip" xcode master VERSION.json README.md SHA256SUMS.txt
  zip -qry "$DIST/WOSAide-IconKit-v${ICON_VERSION}-Electron.zip" electron master VERSION.json README.md SHA256SUMS.txt
  zip -qry "$DIST/WOSAide-IconKit-v${ICON_VERSION}-Windows.zip" windows master VERSION.json README.md SHA256SUMS.txt
  zip -qry "$DIST/WOSAide-IconKit-v${ICON_VERSION}-Chrome.zip" chrome master VERSION.json README.md SHA256SUMS.txt
)
(
  cd "$ICON_ROOT"
  zip -qry "$DIST/WOSAide-IconKit-v${ICON_VERSION}-All.zip" "v${ICON_VERSION}"
)

cat > "$ICON_ROOT/README.md" <<MD
# WOS Aide Icons

Current icon kit: **v$ICON_VERSION**

Canonical source: \`../wosaide-bird.png\`

Rebuild with:

\`npm run icons:build\`

Generated packages are under \`dist/\` and the versioned source tree is under \`v$ICON_VERSION/\`.
MD

echo "Built WOS Aide Icon Kit v$ICON_VERSION"
