#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

CURRENT="$(tr -d '[:space:]' < icons/CURRENT)"
KIT="icons/v$CURRENT"

[[ -n "$CURRENT" ]] || { echo "icons/CURRENT is empty" >&2; exit 1; }
[[ -d "$KIT" ]] || { echo "Missing current kit: $KIT" >&2; exit 1; }

python3 - "$CURRENT" "$KIT/VERSION.json" <<'PY'
import json, pathlib, sys
expected, path = sys.argv[1], pathlib.Path(sys.argv[2])
data = json.loads(path.read_text())
assert data["iconVersion"] == expected
assert data["background"] == "transparent"
assert data["circleBackground"] is False
assert data["lightTheme"].startswith("black bird")
assert data["darkTheme"].startswith("white bird")
print(f"VERSION.json: v{expected} OK")
PY

python3 - bird-logo-black.svg bird-logo-white.svg <<'PY'
import re, pathlib, sys
paths = []
for name in sys.argv[1:]:
    text = pathlib.Path(name).read_text()
    match = re.search(r'<path[^>]*\sd="([^"]+)"', text)
    if not match:
        raise SystemExit(f"No SVG path found in {name}")
    paths.append(match.group(1))
assert paths[0] == paths[1], "Black and white SVG geometry differs"
print("SVG geometry: black/white identical")
PY

for json_file in \
  "$KIT/xcode/macos/light/WOSAideIcon.xcassets/AppIcon.appiconset/Contents.json" \
  "$KIT/xcode/macos/dark/WOSAideIcon.xcassets/AppIcon.appiconset/Contents.json" \
  "$KIT/xcode/WOSAideTheme.xcassets/BirdMark.imageset/Contents.json"; do
  python3 -m json.tool "$json_file" >/dev/null
done
echo "Xcode JSON: OK"

for png in \
  "$KIT/master/light/wosaide-bird-black-1024.png" \
  "$KIT/master/dark/wosaide-bird-white-1024.png"; do
  info="$(sips -g pixelWidth -g pixelHeight -g hasAlpha "$png")"
  grep -q 'pixelWidth: 1024' <<<"$info"
  grep -q 'pixelHeight: 1024' <<<"$info"
  grep -q 'hasAlpha: yes' <<<"$info"
done
echo "Master PNG: 1024x1024 + alpha OK"

python3 - \
  "$KIT/windows/light/app.ico" \
  "$KIT/windows/dark/app.ico" \
  "$KIT/electron/light/icon.ico" \
  "$KIT/electron/dark/icon.ico" <<'PY'
import pathlib, struct, sys
expected = [16, 20, 24, 32, 40, 48, 64, 128, 256]
for name in sys.argv[1:]:
    data = pathlib.Path(name).read_bytes()
    reserved, kind, count = struct.unpack_from('<HHH', data, 0)
    assert reserved == 0 and kind == 1
    sizes = []
    for i in range(count):
        width, _ = struct.unpack_from('<BB', data, 6 + i * 16)
        sizes.append(256 if width == 0 else width)
    assert sizes == expected, (name, sizes)
print("ICO matrices: OK")
PY

(
  cd "$KIT"
  shasum -a 256 -c SHA256SUMS.txt >/dev/null
)
echo "SHA256SUMS: OK"

for suffix in All Xcode Electron Windows Chrome; do
  [[ -f "icons/dist/WOSAide-IconKit-v${CURRENT}-${suffix}.zip" ]] || {
    echo "Missing dist bundle: $suffix" >&2
    exit 1
  }
done
echo "dist bundles: OK"

DEFAULT_VERSION="$(sed -n 's/^ICON_VERSION="${ICON_VERSION:-\([^}]*\)}"$/\1/p' scripts/build-icon-kit.sh)"
[[ "$DEFAULT_VERSION" == "$CURRENT" ]] || {
  echo "build default $DEFAULT_VERSION != CURRENT $CURRENT" >&2
  exit 1
}
echo "build default: v$DEFAULT_VERSION OK"

echo "WOS Aide Icon Kit v$CURRENT verification passed."
