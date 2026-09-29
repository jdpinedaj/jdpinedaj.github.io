#!/usr/bin/env bash
# Runs no_em_dash.py and post-edit.sh against representative payloads. 0 = allowed, 2 = denied.
# Run it as: bash .claude/hooks/tests/test_no_em_dash.sh
set -u
here="$(cd "$(dirname "$0")/.." && pwd)"
root="$(cd "$here/../.." && pwd)"
pass=0; fail=0
dash="$(printf '\xe2\x80\x94')"
check() {
  local exp="$1" field="$2" text="$3" got
  payload=$(python3 -c 'import json,sys; print(json.dumps({"tool_name":"Write","tool_input":{"file_path":"/x/index.html",sys.argv[1]:sys.argv[2]}}))' "$field" "$text")
  printf '%s' "$payload" | python3 "$here/no_em_dash.py" >/dev/null 2>&1; got=$?
  if [ "$got" -eq "$exp" ]; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL (want $exp got $got): $field=$text"; fi
}
check 2 content "one ${dash} two"
check 2 new_string "line one
line ${dash} two"
check 0 content "one - two, three: four (five)"
check 0 new_string "en dash is fine: 2011$(printf '\xe2\x80\x93')2026"
check 0 content ""
printf 'not json' | python3 "$here/no_em_dash.py" >/dev/null 2>&1; [ $? -eq 0 ] && pass=$((pass+1)) || { fail=$((fail+1)); echo "FAIL: malformed stdin should be allowed"; }

# post-edit.sh runs the offline checks only for the page, the sources and the checker.
post() {
  local exp="$1" path="$2" got
  payload=$(python3 -c 'import json,sys; print(json.dumps({"tool_name":"Edit","tool_input":{"file_path":sys.argv[1]}}))' "$path")
  printf '%s' "$payload" | CLAUDE_PROJECT_DIR="$root" bash "$here/post-edit.sh" >/dev/null 2>&1; got=$?
  if [ "$got" -eq "$exp" ]; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL (want $exp got $got): post-edit $path"; fi
}
post 0 "$root/index.html"
post 0 "$root/README.md"
post 0 "$root/.claude/CLAUDE.md"
post 0 /tmp/claude-1000/scratchpad/x.html
echo "passed=$pass failed=$fail"
[ "$fail" -eq 0 ]
