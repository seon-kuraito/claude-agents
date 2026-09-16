#!/usr/bin/env bash
#
# run-checks.sh — the structure and script tiers for this repo, per the family
# contract in claude-skills/skills/sk-skill-author/references/verification.md.
#
#   scripts/run-checks.sh            every agent
#   scripts/run-checks.sh <agent>    one agent
#
# Exit 0 passes, exit 1 fails. A model chooses an agent the way it chooses a
# skill, so this repo implements the routed-item rules as well as the shared ones.
set -uo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
runner="$repo/scripts/runner"

if [ $# -gt 0 ]; then
  items=("$@")
else
  items=()
  for dir in "$repo"/agents/*/; do
    name="$(basename "$dir")"
    [ -f "$dir/$name.md" ] && items+=("$name")
  done
fi

fail=0


# Drift check — the shared rules and the routed-item rules both apply here.
spec="$repo/../claude-skills/skills/sk-skill-author/references/verification.md"
if [ -f "$spec" ]; then
  expected=$(awk '/^## Shared rules/{f=1; next} /^## Routed-item rules/{f=1; next} /^## /{f=0} f' "$spec" |
    grep -oE '^\| `[a-z][a-z-]*`' | tr -d '|` ')
  for rule in $expected; do
    if ! compgen -G "$runner/$rule.*" > /dev/null; then
      echo "FAIL  runner — rule '$rule' has no file in scripts/runner/"
      fail=1
    fi
  done
else
  echo "SKIP  drift check — no verification.md beside this repo"
fi

# An empty repo is a valid state — the drift check above still applies to its
# runner, and bash 3.2 errors on "${items[@]}" under set -u.
if [ ${#items[@]} -eq 0 ]; then
  echo "---"
  if [ $fail -eq 0 ]; then echo "no items to check"; else echo "checks failed"; fi
  exit $fail
fi

# Structure tier.
for rule_file in "$runner"/*; do
  [ -f "$rule_file" ] || continue
  rule="$(basename "${rule_file%.*}")"
  case "$rule" in _*) continue ;; esac
  if bash "$rule_file" "$repo" "${items[@]}"; then
    echo "PASS  $rule"
  else
    fail=1
  fi
done

# Script tier.
for item in "${items[@]}"; do
  item_tests="$repo/agents/$item/tests/run.sh"
  if [ -f "$item_tests" ]; then
    echo "---   $item tests/run.sh"
    if bash "$item_tests"; then
      echo "PASS  $item script tier"
    else
      echo "FAIL  $item script tier"
      fail=1
    fi
  fi
done

echo "---"
if [ $fail -eq 0 ]; then echo "all checks passed"; else echo "checks failed"; fi
exit $fail
