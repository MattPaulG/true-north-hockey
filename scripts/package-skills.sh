#!/usr/bin/env bash
# Build one uploadable zip per skill into dist/.
# Each zip contains a single folder named after the skill, holding its SKILL.md,
# which is the layout Claude's "Upload skill" expects.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
dist="$root/dist"
rm -rf "$dist"
mkdir -p "$dist"

cd "$root/skills"
for dir in */; do
  name="${dir%/}"
  if [[ ! -f "$name/SKILL.md" ]]; then
    echo "skip $name: no SKILL.md" >&2
    continue
  fi
  declared="$(sed -n 's/^name:[[:space:]]*//p' "$name/SKILL.md" | head -n1 | tr -d '\r')"
  if [[ "$declared" != "$name" ]]; then
    echo "error: folder '$name' does not match name '$declared' in SKILL.md" >&2
    exit 1
  fi
  zip -rqX "$dist/$name.zip" "$name" -x '*.DS_Store' -x '*/._*'
  echo "built dist/$name.zip"
done
