#!/usr/bin/env bash
# naming — sk-<single-token>-<verber>, matched by the folder, the definition
# file inside it, and the frontmatter name. `author` is reserved for the skills
# that author Claude Code extensions.
set -uo pipefail
repo="$1"; shift
. "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"
fail=0
for name in "$@"; do
  printf '%s' "$name" | grep -Eq '^sk-[a-z0-9]+-[a-z]+$' ||
    { echo "FAIL  $name — directory name is not sk-<single-token>-<verber>"; fail=1; }
  case "$name" in
    *-author) echo "FAIL  $name — \`author\` is reserved for extension-authoring skills"; fail=1 ;;
  esac
  file="$(definition "$repo" "$name")"
  if [ ! -f "$file" ]; then
    echo "FAIL  $name — has no agents/$name/$name.md"
    fail=1
    continue
  fi
  declared="$(frontmatter_value "$file" name)"
  [ "$declared" = "$name" ] ||
    { echo "FAIL  $name — frontmatter name is '$declared', expected '$name'"; fail=1; }
done
exit $fail
