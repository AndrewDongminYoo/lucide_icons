# lucide_icons_lite — package repositioning (Plan B)

Prepare a branch that repositions this fork for pub.dev publication as
`lucide_icons_lite`, a deliberately lightweight distribution of the Lucide icon
set. Prepared in advance; the actual `dart pub publish` happens later, by hand.

## Context

The upstream `lucide-icons/lucide-flutter` package is deprecated, and the
better-maintained community forks carry extra weight (6 stroke weights, RTL,
multi-variant APIs). This fork is the opposite trade-off: single-weight
`IconData` backed by one font, auto-synced with `lucide-static`. That niche is
worth publishing under a name that states it — `lucide_icons_lite`.

This is a separate track from the upstream revival PR (#9); the two do not share
a goal and must not be mixed.

## Decisions

- **Public API surface:** pub convention. Entry file `lib/lucide_icons_lite.dart`;
  class name stays `LucideIcons`. Import becomes
  `package:lucide_icons_lite/lucide_icons_lite.dart`.
- **Version:** keep `1.24.0`, tracking the upstream `lucide-static` version (the
  update automation depends on `version == lucide-static version`).
- **Scope:** publishable state only — verified with `dart pub publish --dry-run`.
  No OIDC auto-publish workflow; no actual publish; no `.trunk`/`.vscode`.
- **Branch:** `pkg/lucide-icons-lite`, off `main`.

## Changes

1. `pubspec.yaml`: `name: lucide_icons_lite`; lite-positioning `description`;
   `homepage`/`repository`/`issue_tracker` set to the fork; `topics`.
2. Rename `lib/lucide_icons.dart` → `lib/lucide_icons_lite.dart` (git mv).
3. **`fontPackage`:** every generated `IconData` carries
   `fontPackage: 'lucide_icons_lite'` — required, or Flutter resolves the font
   under the wrong package and icons do not render. Fixed in the generator
   (`tool/generate_fonts.dart`) and bulk-applied to the 1,991 existing entries.
4. Path references updated to the new entry file: generator output path,
   `tool/update_icons.sh`, `.github/workflows/update-icons.yml` (diff greps),
   `docs/icon-update-automation.md`, `README.md`.
5. `test/icon_test.dart`: import updated.
6. `README.md`: "why lite" positioning, pub.dev install snippet, import example.
7. `CHANGELOG.md`: note the rename under the existing `1.24.0` entry.

## Verification

- `flutter pub get` → `flutter analyze` → `dart pub publish --dry-run`.

## Out of scope

OIDC auto-publish workflow, the real `pub publish`, and any change to the
upstream PR track.
