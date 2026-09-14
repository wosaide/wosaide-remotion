#!/usr/bin/env bash
set -euo pipefail

ICON_VERSION="${ICON_VERSION:-1.0.1}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BLACK_SVG="$ROOT/bird-logo-black.svg"
WHITE_SVG="$ROOT/bird-logo-white.svg"
RENDERER="$ROOT/scripts/render-svg-icon.swift"
ICON_ROOT="$ROOT/icons"
KIT="$ICON_ROOT/v$ICON_VERSION"
DIST="$ICON_ROOT/dist"
FILL_RATIO="${ICON_FILL_RATIO:-0.84}"

for tool in sips iconutil zip python3 swift; do
  command -v "$tool" >/dev/null || { echo "Missing required tool: $tool" >&2; exit 1; }
done
for file in "$BLACK_SVG" "$WHITE_SVG" "$RENDERER"; do
  [[ -f "$file" ]] || { echo "Missing source: $file" >&2; exit 1; }
done

rm -rf "$KIT" "$DIST"
mkdir -p \
  "$KIT/master/light" "$KIT/master/dark" \
  "$KIT/xcode/macos/light/WOSAideIcon.xcassets/AppIcon.appiconset" \
  "$KIT/xcode/macos/dark/WOSAideIcon.xcassets/AppIcon.appiconset" \
  "$KIT/xcode/WOSAideTheme.xcassets/BirdMark.imageset" \
  "$KIT/electron/light/icons" "$KIT/electron/dark/icons" \
  "$KIT/windows/light/png" "$KIT/windows/dark/png" \
  "$KIT/chrome/extension/light/icons" "$KIT/chrome/extension/dark/icons" \
  "$KIT/chrome/web-store/light" "$KIT/chrome/web-store/dark" \
  "$DIST"

render_svg() {
  local source="$1" size="$2" output="$3"
  /usr/bin/swift "$RENDERER" "$source" "$output" "$size" "$FILL_RATIO"
}

resize_png() {
  local source="$1" size="$2" output="$3"
  sips -z "$size" "$size" "$source" --out "$output" >/dev/null
}

make_ico() {
  local output="$1" root="$2"
  python3 - "$output" "$root" <<'PY'
import pathlib, struct, sys
out = pathlib.Path(sys.argv[1])
root = pathlib.Path(sys.argv[2])
sizes = [16, 20, 24, 32, 40, 48, 64, 128, 256]
images = [(s, (root / f"icon-{s}.png").read_bytes()) for s in sizes]
header = struct.pack('<HHH', 0, 1, len(images))
offset = 6 + 16 * len(images)
entries, payload = [], []
for size, data in images:
    wh = 0 if size == 256 else size
    entries.append(struct.pack('<BBBBHHII', wh, wh, 0, 0, 1, 32, len(data), offset))
    payload.append(data)
    offset += len(data)
out.write_bytes(header + b''.join(entries) + b''.join(payload))
PY
}

write_macos_contents() {
  local set="$1"
  cat > "$set/Contents.json" <<'JSON'
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
}

make_icns() {
  local set="$1" output="$2"
  local temp="$KIT/.iconset-$RANDOM.iconset"
  mkdir -p "$temp"
  cp "$set"/*.png "$temp/"
  iconutil -c icns "$temp" -o "$output"
  rm -rf "$temp"
}

# -----------------------------------------------------------------------------
# Canonical theme sources: NO circle/background artwork is ever used here.
# Light appearance = black bird on transparent canvas.
# Dark appearance  = white bird on transparent canvas.
# -----------------------------------------------------------------------------
cp "$BLACK_SVG" "$KIT/master/light/wosaide-bird-black-v$ICON_VERSION.svg"
cp "$WHITE_SVG" "$KIT/master/dark/wosaide-bird-white-v$ICON_VERSION.svg"
render_svg "$BLACK_SVG" 1024 "$KIT/master/light/wosaide-bird-black-1024.png"
render_svg "$WHITE_SVG" 1024 "$KIT/master/dark/wosaide-bird-white-1024.png"
resize_png "$KIT/master/light/wosaide-bird-black-1024.png" 512 "$KIT/master/light/wosaide-bird-black-512.png"
resize_png "$KIT/master/dark/wosaide-bird-white-1024.png" 512 "$KIT/master/dark/wosaide-bird-white-512.png"

LIGHT_MASTER="$KIT/master/light/wosaide-bird-black-1024.png"
DARK_MASTER="$KIT/master/dark/wosaide-bird-white-1024.png"

# Xcode macOS: separate AppIcon sets plus one appearance-aware BirdMark.imageset.
for theme in light dark; do
  if [[ "$theme" == "light" ]]; then MASTER="$LIGHT_MASTER"; else MASTER="$DARK_MASTER"; fi
  SET="$KIT/xcode/macos/$theme/WOSAideIcon.xcassets/AppIcon.appiconset"
  resize_png "$MASTER" 16   "$SET/icon_16x16.png"
  resize_png "$MASTER" 32   "$SET/icon_16x16@2x.png"
  resize_png "$MASTER" 32   "$SET/icon_32x32.png"
  resize_png "$MASTER" 64   "$SET/icon_32x32@2x.png"
  resize_png "$MASTER" 128  "$SET/icon_128x128.png"
  resize_png "$MASTER" 256  "$SET/icon_128x128@2x.png"
  resize_png "$MASTER" 256  "$SET/icon_256x256.png"
  resize_png "$MASTER" 512  "$SET/icon_256x256@2x.png"
  resize_png "$MASTER" 512  "$SET/icon_512x512.png"
  cp "$MASTER" "$SET/icon_512x512@2x.png"
  write_macos_contents "$SET"
  make_icns "$SET" "$KIT/xcode/macos/$theme/WOSAideBird.icns"
done

THEME_SET="$KIT/xcode/WOSAideTheme.xcassets/BirdMark.imageset"
cp "$LIGHT_MASTER" "$THEME_SET/bird-black.png"
cp "$DARK_MASTER" "$THEME_SET/bird-white.png"
cat > "$THEME_SET/Contents.json" <<'JSON'
{
  "images" : [
    {"filename":"bird-black.png","idiom":"universal","scale":"1x"},
    {"appearances":[{"appearance":"luminosity","value":"dark"}],"filename":"bird-white.png","idiom":"universal","scale":"1x"}
  ],
  "info" : {"author":"xcode","version":1},
  "properties" : {"preserves-vector-representation":false}
}
JSON

# Windows + Electron theme variants.
WIN_SIZES=(16 20 24 32 40 48 64 128 256 512)
for theme in light dark; do
  if [[ "$theme" == "light" ]]; then MASTER="$LIGHT_MASTER"; else MASTER="$DARK_MASTER"; fi
  WIN="$KIT/windows/$theme/png"
  EL="$KIT/electron/$theme"
  for size in "${WIN_SIZES[@]}"; do
    resize_png "$MASTER" "$size" "$WIN/icon-${size}.png"
  done
  make_ico "$KIT/windows/$theme/app.ico" "$WIN"
  cp "$KIT/windows/$theme/app.ico" "$EL/icon.ico"
  cp "$MASTER" "$EL/icon@2x.png"
  resize_png "$MASTER" 512 "$EL/icon.png"
  for size in 16 32 48 64 128 256 512; do
    cp "$WIN/icon-${size}.png" "$EL/icons/${size}x${size}.png"
  done
  make_icns "$KIT/xcode/macos/$theme/WOSAideIcon.xcassets/AppIcon.appiconset" "$EL/icon.icns"
done

# Chrome Extension + Chrome Web Store theme variants.
for theme in light dark; do
  if [[ "$theme" == "light" ]]; then MASTER="$LIGHT_MASTER"; else MASTER="$DARK_MASTER"; fi
  EXT="$KIT/chrome/extension/$theme/icons"
  STORE="$KIT/chrome/web-store/$theme"
  for size in 16 32 48 128; do
    resize_png "$MASTER" "$size" "$EXT/icon${size}.png"
  done
  for size in 128 256 512 1024; do
    resize_png "$MASTER" "$size" "$STORE/icon-${size}.png"
  done
done
cat > "$KIT/chrome/extension/manifest-icons-light.json" <<'JSON'
{"icons":{"16":"light/icons/icon16.png","32":"light/icons/icon32.png","48":"light/icons/icon48.png","128":"light/icons/icon128.png"}}
JSON
cat > "$KIT/chrome/extension/manifest-icons-dark.json" <<'JSON'
{"icons":{"16":"dark/icons/icon16.png","32":"dark/icons/icon32.png","48":"dark/icons/icon48.png","128":"dark/icons/icon128.png"}}
JSON

# Keep project-level macOS assets aligned to the same source. Default is light
# appearance (black bird), with explicit dark white-bird counterparts.
rm -rf "$ROOT/assets/macos"
mkdir -p "$ROOT/assets/macos/light" "$ROOT/assets/macos/dark" \
  "$ROOT/assets/macos/WOSAideBird.iconset" "$ROOT/assets/macos/WOSAideBird-Dark.iconset"
cp "$LIGHT_MASTER" "$ROOT/assets/macos/WOSAideBird-1024.png"
cp "$DARK_MASTER" "$ROOT/assets/macos/WOSAideBird-Dark-1024.png"
cp "$KIT/xcode/macos/light/WOSAideBird.icns" "$ROOT/assets/macos/WOSAideBird.icns"
cp "$KIT/xcode/macos/dark/WOSAideBird.icns" "$ROOT/assets/macos/WOSAideBird-Dark.icns"
cp -R "$KIT/xcode/macos/light/WOSAideIcon.xcassets" "$ROOT/assets/macos/light/"
cp -R "$KIT/xcode/macos/dark/WOSAideIcon.xcassets" "$ROOT/assets/macos/dark/"
cp "$KIT/xcode/macos/light/WOSAideIcon.xcassets/AppIcon.appiconset"/*.png "$ROOT/assets/macos/WOSAideBird.iconset/"
cp "$KIT/xcode/macos/dark/WOSAideIcon.xcassets/AppIcon.appiconset"/*.png "$ROOT/assets/macos/WOSAideBird-Dark.iconset/"

cat > "$KIT/VERSION.json" <<JSON
{
  "iconVersion": "$ICON_VERSION",
  "geometrySource": "bird-logo-black.svg / bird-logo-white.svg",
  "originalReference": "wosaide-bird.png",
  "background": "transparent",
  "lightTheme": "black bird (#242424), transparent background",
  "darkTheme": "white bird (#ffffff), transparent background",
  "circleBackground": false,
  "fillRatio": $FILL_RATIO,
  "generatedAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "packages": ["xcode-macos", "electron", "windows", "chrome-extension", "chrome-web-store"]
}
JSON
printf '%s\n' "$ICON_VERSION" > "$ICON_ROOT/CURRENT"

cat > "$KIT/README.md" <<'MD'
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
MD

(
  cd "$KIT"
  find . -type f ! -name SHA256SUMS.txt -print0 | sort -z | xargs -0 shasum -a 256 > SHA256SUMS.txt
)

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

Theme contract:

- Light: black bird, transparent background.
- Dark: white bird, transparent background.
- No circular background.

Canonical raster generation comes from \`../bird-logo-black.svg\` and \`../bird-logo-white.svg\`.
The original \`../wosaide-bird.png\` is visual reference only and is **not** used as a raster source.

Rebuild with \`npm run icons:build\`.
MD

echo "Built WOS Aide Icon Kit v$ICON_VERSION (circleless, transparent, light/dark aligned)"
