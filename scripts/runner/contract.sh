#!/usr/bin/env bash
# contract — tools and model are the only hard constraints an agent has, so
# both are declared rather than left to a default or to prose in the body.
set -uo pipefail
repo="$1"; shift
. "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"
fail=0
for name in "$@"; do
  file="$(definition "$repo" "$name")"
  [ -f "$file" ] || continue
  for key in tools model; do
    [ -n "$(frontmatter_value "$file" "$key")" ] ||
      { echo "FAIL  $name — frontmatter declares no $key"; fail=1; }
  done
done
exit $fail
