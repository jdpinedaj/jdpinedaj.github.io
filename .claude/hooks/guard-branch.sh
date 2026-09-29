#!/usr/bin/env bash
# PreToolUse guard for the branch flow:
#   main  = what GitHub Pages serves. Only receives a fast-forward merge of dev, after Juan says yes.
#   dev   = integration branch. Only receives merges of working branches.
#   work  = feature/, bugfix/, docs/, chore/ (or any other topic name) created from dev.
# Edits and commits are refused on main and dev; a merge on main is refused unless it is
# "git merge --ff-only dev". Files outside the project (scratchpad, /tmp) and gitignored files
# (TODO.md, shots/*.png) are not affected. Reading is always allowed.
# The branch may be passed as $1 (the test suite does that); otherwise it is read from git.
set -u
branch="${1:-}"
if [ -z "$branch" ]; then
  branch="$(cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null && git branch --show-current 2>/dev/null)"
fi
case "$branch" in
  main | master | dev) ;;
  *) exit 0 ;;
esac

payload="$(cat)"
read -r path command <<EOF2
$(printf '%s' "$payload" | python3 -c 'import json,sys
try:
    t = json.load(sys.stdin).get("tool_input", {})
    print(t.get("file_path", "-"), t.get("command", "-").replace("\n", " "))
except Exception:
    print("- -")' 2>/dev/null)
EOF2

refuse() {
  printf 'BLOCKED by .claude/hooks/guard-branch.sh: %s\n' "$1" >&2
  printf 'Create a working branch from dev first: git switch -c <feature|bugfix|docs|chore>/<topic> dev\n' >&2
  exit 2
}

case "$branch" in
  main | master) why="$branch is what GitHub Pages serves; it only receives a fast-forward merge of dev, after Juan says yes." ;;
  dev) why="dev is the integration branch; it only receives merges of working branches." ;;
esac

case "${command:-}" in
  *"git "*commit*) refuse "no commits on $branch. $why" ;;
esac

case "$branch" in
  main | master)
    case "${command:-}" in
      *"git "*merge*)
        printf '%s' "$command" | grep -qE '(^|[[:space:];&|])git[[:space:]]+merge[[:space:]]+--ff-only[[:space:]]+dev([[:space:]]|$)' \
          || refuse "main only receives 'git merge --ff-only dev' (ask Juan first). $why"
        ;;
    esac
    ;;
esac

root="${CLAUDE_PROJECT_DIR:-$(pwd)}"
case "${path:-}" in
  "$root"/*)
    git -C "$root" check-ignore -q "$path" 2>/dev/null && exit 0
    refuse "no edits on $branch. $why"
    ;;
esac
exit 0
