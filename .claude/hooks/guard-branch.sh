#!/usr/bin/env bash
# PreToolUse guard: never edit files or commit while main (what Pages serves) is checked out.
# Work starts on its own branch and reaches main through a fast-forward merge, so an edit
# here means the branch step was skipped. Files outside the project (scratchpad, /tmp) and
# gitignored files (TODO.md, shots/) are not affected. Reading is always allowed.
# The branch may be passed as $1 (the test suite does that); otherwise it is read from git.
set -u
branch="${1:-}"
if [ -z "$branch" ]; then
  branch="$(cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null && git branch --show-current 2>/dev/null)"
fi
case "$branch" in
  main | master) ;;
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
  printf 'BLOCKED by .claude/hooks/guard-branch.sh: %s is what GitHub Pages serves.\n' "$branch" >&2
  printf 'Create a working branch first: git switch -c <topic> %s\n' "$branch" >&2
  exit 2
}

case "${command:-}" in
  *"git "*commit*) refuse ;;
esac

root="${CLAUDE_PROJECT_DIR:-$(pwd)}"
case "${path:-}" in
  "$root"/*)
    git -C "$root" check-ignore -q "$path" 2>/dev/null && exit 0
    refuse
    ;;
esac
exit 0
