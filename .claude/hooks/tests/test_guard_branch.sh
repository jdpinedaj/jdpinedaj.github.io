#!/usr/bin/env bash
# Runs guard-branch.sh for a given branch and edited path or command. 0 = allowed, 2 = denied.
# Run it as: bash .claude/hooks/tests/test_guard_branch.sh
set -u
here="$(cd "$(dirname "$0")/.." && pwd)"
root="$(cd "$here/../.." && pwd)"
pass=0; fail=0
check() {
  local exp="$1" branch="$2" path="$3" got
  payload=$(python3 -c 'import json,sys; print(json.dumps({"tool_input":{"file_path":sys.argv[1]}}))' "$path")
  printf '%s' "$payload" | CLAUDE_PROJECT_DIR="$root" bash "$here/guard-branch.sh" "$branch" >/dev/null 2>&1; got=$?
  if [ "$got" -eq "$exp" ]; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL (want $exp got $got): branch=$branch path=$path"; fi
}
check_cmd() {
  local exp="$1" branch="$2" cmd="$3" got
  payload=$(python3 -c 'import json,sys; print(json.dumps({"tool_input":{"command":sys.argv[1]}}))' "$cmd")
  printf '%s' "$payload" | CLAUDE_PROJECT_DIR="$root" bash "$here/guard-branch.sh" "$branch" >/dev/null 2>&1; got=$?
  if [ "$got" -eq "$exp" ]; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL (want $exp got $got): branch=$branch cmd=$cmd"; fi
}
# Commits belong on a working branch; main only receives merges and pushes.
check_cmd 2 main 'git commit -m "Fix"'
check_cmd 2 master 'git commit -q -m "Fix"'
check_cmd 2 main 'git add -u && git commit -m "Fix"'
check_cmd 0 chore/internal-structure 'git commit -m "Fix"'
check_cmd 0 main 'git merge --ff-only chore/x'
check_cmd 0 main 'git switch -c fix/topic'
check_cmd 0 main 'git push origin main'
check_cmd 0 main 'git status'
check_cmd 0 main 'python3 check.py'
# main refuses edits to tracked files inside the repository.
check 2 main "$root/index.html"
check 2 main "$root/styles.css"
check 2 main "$root/.claude/CLAUDE.md"
check 2 master "$root/check.py"
# Gitignored files never reach a commit, so they are editable on any branch.
check 0 main "$root/TODO.md"
check 0 main "$root/shots/shoot.js"
check 0 main "$root/.claude/settings.local.json"
# Working branches are free.
check 0 chore/internal-structure "$root/index.html"
check 0 fix/theme-color "$root/styles.css"
check 0 docs/readme "$root/README.md"
# Outside the repository is fine even on main.
check 0 main /tmp/claude-1000/scratchpad/notes.md
check 0 main /home/juanp/.claude/settings.json
# A missing or unreadable payload must never block.
printf 'not json' | CLAUDE_PROJECT_DIR="$root" bash "$here/guard-branch.sh" main >/dev/null 2>&1
if [ $? -eq 0 ]; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL: malformed stdin should be allowed"; fi
echo "passed=$pass failed=$fail"
[ "$fail" -eq 0 ]
