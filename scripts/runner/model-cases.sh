#!/usr/bin/env bash
# model-cases — tests/model.json exists and carries at least one default
# trigger case, because a model chooses this agent the way it chooses a skill.
set -uo pipefail
repo="$1"; shift
fail=0
for name in "$@"; do
  model="$repo/agents/$name/tests/model.json"
  if [ ! -f "$model" ]; then
    echo "FAIL  $name — has no tests/model.json"
    fail=1
    continue
  fi
  if ! jq empty "$model" 2>/dev/null; then
    echo "FAIL  $name — tests/model.json is not valid JSON"
    fail=1
    continue
  fi
  count="$(jq '[.trigger[]? | select(.default)] | length' "$model")"
  [ "$count" -gt 0 ] ||
    { echo "FAIL  $name — tests/model.json has no default trigger case"; fail=1; }
  missing="$(jq -r '[.trigger[]? | select((.id // "") == "" or (.prompt // "") == "" or (.expect // "") == "")] | length' "$model")"
  [ "$missing" = "0" ] ||
    { echo "FAIL  $name — a trigger case is missing id, prompt or expect"; fail=1; }
done
exit $fail
