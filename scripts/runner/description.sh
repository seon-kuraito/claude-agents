#!/usr/bin/env bash
# description — the routing text a model reads to pick this agent: present, and
# within the length the writing guide sets.
set -uo pipefail
repo="$1"; shift
. "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"
limit=1024
fail=0
for name in "$@"; do
  file="$(definition "$repo" "$name")"
  [ -f "$file" ] || continue
  value="$(frontmatter_value "$file" description | tr '\n' ' ')"
  value="${value%"${value##*[![:space:]]}"}"
  if [ -z "$value" ]; then
    echo "FAIL  $name — frontmatter has no description"
    fail=1
  elif [ "${#value}" -gt "$limit" ]; then
    echo "FAIL  $name — description is ${#value} characters, limit is $limit"
    fail=1
  fi
done
exit $fail
