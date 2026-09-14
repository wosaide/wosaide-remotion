# Icon Kit Versioning

WOS Aide Icon Kit uses its own Semantic Versioning line: `MAJOR.MINOR.PATCH`. It is independent from the Remotion project version in `package.json`.

## Version invariants

For a released Icon Kit, these values must agree:

1. `icons/CURRENT`.
2. `icons/v<version>/VERSION.json` → `iconVersion`.
3. The default `ICON_VERSION` in `scripts/build-icon-kit.sh`.
4. Version numbers in `icons/dist/WOSAide-IconKit-v<version>-*.zip`.
5. Release Git tag `icons-v<version>`.

`npm run icons:verify` checks the current generated release state.

## Semantic version rules

### MAJOR

Use a major bump for an incompatible brand or package contract change, for example a new primary mark, a different Light/Dark color policy, removal of the transparent-background rule, or a directory/API redesign that existing consumers cannot use unchanged.

### MINOR

Use a minor bump when the existing visual contract stays compatible but a new supported platform, resource family, theme variant, or non-breaking format is added.

### PATCH

Use a patch bump for corrections to existing released assets, including geometry, color, alpha, padding, rasterization, ICO/ICNS metadata, Xcode metadata, or a corrected published ZIP.

Repository-only documentation edits do not require a new Icon Kit version when the already-published Icon Kit files and ZIP payloads are unchanged.

## Release procedure

Example for `1.0.2`:

```bash
ICON_VERSION=1.0.2 npm run icons:build
npm run icons:verify
npm run typecheck
```

Then update `icons/CHANGELOG.md`, inspect the diff, commit the release, and create an immutable tag:

```bash
git add -A
git commit -m "fix(icons): release WOS Aide icon kit v1.0.2"
git tag -a icons-v1.0.2 -m "WOS Aide Icon Kit v1.0.2"
```

If a release tag has already been published, do not move or reuse it. Fix the problem in a new PATCH release.

## Rollback and audit

List releases:

```bash
git tag --list 'icons-v*'
```

Inspect a release:

```bash
git show icons-v1.0.1
```

Restore a versioned directory for inspection without moving the tag:

```bash
git checkout icons-v1.0.1 -- icons/v1.0.1
```

Invalid or superseded generated assets may be removed from the current branch, while Git history and old tags remain as the audit trail. Version `1.0.0` is superseded because it incorrectly included the reference image's circular background; `1.0.1` is the corrected baseline.
