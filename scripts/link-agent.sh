#!/usr/bin/env bash
#
# link-agent.sh — symlink an agent definition from this repo into
# ~/.claude/agents so Claude Code discovers it while the files live here.
# Links the .md definition only: sibling files in the agent's folder
# (README, LICENSE) stay out of the discovery directory.
#
# Usage: scripts/link-agent.sh <agent-name>
#
# Idempotent: re-running is safe. Refuses to overwrite anything it doesn't own
# (e.g. a third-party agent of the same name).
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_agents="$(cd "$script_dir/.." && pwd)/agents"
runtime_agents="$HOME/.claude/agents"

name="${1:-}"
if [ -z "$name" ]; then
  echo "usage: link-agent.sh <agent-name>" >&2
  exit 1
fi

src="$repo_agents/$name/$name.md"
dest="$runtime_agents/$name.md"

if [ ! -f "$src" ]; then
  echo "error: agent definition not found in repo: $src" >&2
  exit 1
fi

if [ -L "$dest" ]; then
  if [ "$(readlink "$dest")" = "$src" ]; then
    echo "ok: already linked — $name"
  else
    echo "error: $dest already links elsewhere ($(readlink "$dest"))" >&2
    exit 1
  fi
elif [ -e "$dest" ]; then
  # A real file is in the way → refuse to clobber it.
  echo "error: $dest exists and is not a symlink — refusing to overwrite" >&2
  exit 1
else
  mkdir -p "$runtime_agents"
  ln -s "$src" "$dest"
  echo "linked: $dest -> $src"
fi
