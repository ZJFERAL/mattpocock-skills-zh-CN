#!/usr/bin/env bash
set -euo pipefail

# Links all public skills in the repository to ~/.agents/skills, so that
# Kimi Code picks them up from that directory. Because the links point at the
# repo's own skill directories, a `git pull` in this repo updates the installed
# skills without re-running this script.
#
# New skills added to the repo are not linked until this script runs again, and
# the Kimi Code skill list is scanned at session start, so a new session is
# needed before a newly linked skill shows up in the picker.
#
# On Windows, directory symlinks need Developer Mode or an elevated shell, so
# this script creates junctions instead via `cmd //c mklink /J`. A junction
# still resolves as a real directory for readers, which is what a skill loader
# needs.
#
# Re-running is safe: existing links are replaced, plain copies are removed.
# To undo, delete the link itself (never `rm -rf` its contents, which would
# follow the junction into this repo).

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$HOME/.agents/skills"

mkdir -p "$DEST"

find "$REPO/skills" -name SKILL.md -not -path '*/node_modules/*' -not -path '*/deprecated/*' -print0 |
while IFS= read -r -d '' skill_md; do
  src="$(dirname "$skill_md")"
  name="$(basename "$src")"
  target="$DEST/$name"

  # `mklink` fails if the target name is taken, so clear whatever is there
  # first. `[ -L ]` is true for both symlinks and junctions as Git Bash sees
  # them; a plain copy must be removed recursively because it is real content.
  if [ -L "$target" ]; then
    rm -f "$target"
  elif [ -d "$target" ]; then
    rm -rf "$target"
  elif [ -e "$target" ]; then
    rm -f "$target"
  fi

  # Junctions only accept native Windows paths, so convert the POSIX-style
  # paths Git Bash reports into backslash form. The paths are passed unquoted
  # because `cmd //c` under Git Bash mishandles quoted arguments here; this
  # repo's paths contain no spaces.
  win_src="$(cygpath -w "$src")"
  win_target="$(cygpath -w "$target")"

  if cmd //c "mklink /J $win_target $win_src" >/dev/null 2>&1; then
    echo "linked $name -> $src"
  else
    echo "error: failed to link $name -> $src" >&2
    exit 1
  fi
done
