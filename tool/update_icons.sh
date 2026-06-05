#!/usr/bin/env bash
#
# Upgrade the lucide-static dependency and regenerate the Flutter icon set.
#
# Shared by the `merry update-icons` developer script and the
# `.github/workflows/update-icons.yml` automation so the regeneration steps
# live in exactly one place.
#
# Usage:
#   tool/update_icons.sh            # upgrade to the latest lucide-static release
#   tool/update_icons.sh 1.17.0     # pin a specific lucide-static version
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

version_spec="${1:-latest}"

# 1. Upgrade the lucide-static npm dependency.
pnpm add "lucide-static@${version_spec}"

# 2. Copy the generated font assets out of node_modules.
cp node_modules/lucide-static/font/lucide.css assets/lucide.css
cp node_modules/lucide-static/font/lucide.ttf assets/lucide.ttf

# 3. Regenerate lib/lucide_icons.dart with inline SVG dartdoc previews.
dart run tool/generate_fonts.dart assets/lucide.css \
  --inline-svg \
  --svg-dir=./node_modules/lucide-static/icons
