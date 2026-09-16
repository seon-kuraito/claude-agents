#!/usr/bin/env bash
# Shared helpers for the rule scripts. The leading underscore keeps this file
# out of the rule loop and the drift comparison.

# frontmatter_value <file> <key> — the value of a top-level frontmatter key,
# including any continuation lines, or empty when the key is absent.
frontmatter_value() {
  awk -v key="$2" '
    NR == 1 && $0 != "---" { exit }
    NR > 1 && $0 == "---" { exit }
    {
      if ($0 ~ "^" key ":") { collecting = 1; sub("^" key ":[ \t]*", ""); print; next }
      if (collecting && $0 ~ /^[A-Za-z0-9_-]+:/) { collecting = 0 }
      if (collecting) { sub(/^[ \t]+/, ""); print }
    }' "$1"
}

# definition <repo> <name> — the agent's definition file.
definition() { printf '%s/agents/%s/%s.md' "$1" "$2" "$2"; }
