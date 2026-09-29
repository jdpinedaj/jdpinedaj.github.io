#!/usr/bin/env bash
# Runs guard-bash.sh against representative commands. 0 = allowed, 2 = denied.
# Run it as: bash .claude/hooks/tests/test_guard_bash.sh
set -u
here="$(cd "$(dirname "$0")/.." && pwd)"
pass=0; fail=0
check() {
  local exp="$1" cmd="$2" payload got
  payload=$(python3 -c 'import json,sys; print(json.dumps({"tool_name":"Bash","tool_input":{"command":sys.argv[1]}}))' "$cmd")
  printf '%s' "$payload" | bash "$here/guard-bash.sh" >/dev/null 2>&1; got=$?
  if [ "$got" -eq "$exp" ]; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL (want $exp got $got): $cmd"; fi
}
# The forbidden words are assembled at runtime so this file never contains them literally.
who="Cl${x:-}aude"; org="Anth${x:-}ropic"; trailer="Co-Auth${x:-}ored-By"
dash="$(printf '\xe2\x80\x94')"

# commit messages
check 2 "git commit -m \"Header static on phones\" -m \"$trailer: $who <noreply@example.com>\""
check 2 "git commit -m \"Fix: ask $who for help\""
check 2 "git commit -m \"Generated with $who Code\""
check 2 "git commit -m \"Uses the $org SDK\""
check 0 'git commit -m "Header static on phones"'
check 2 "git commit -m \"Cards $dash visible without JS\""
check 2 'git commit -F msg.txt'
check 2 'git commit --file=msg.txt'
check 2 'git commit -t template.txt'
check 0 'git commit -F - <<EOF
Review fixes: cards visible without JS
EOF'
check 2 "git commit -F - <<EOF
Review fixes

$trailer: $who <noreply@example.com>
EOF"
check 0 'git commit -m "Fix links" 2>&1 | tee /tmp/claude-1000/abc/scratchpad/commit.log'
check 0 'git commit -m "Hooks" && bash .claude/hooks/tests/test_guard_bash.sh'
check 0 "git commit -m \"Fix\" && grep -ciE \"$who|$org\" notes.txt"
check 0 "grep -rn $who .claude/ && git commit -m \"Rules\""
check 2 "git commit -m \"Fix\" && git commit -m \"chore: $who did it\""
# staging
check 0 'git add .claude/CLAUDE.md .claude/settings.json'
check 0 'git add -A'
check 0 'git add .'
check 2 'git add -f shots/desktop.png'
check 2 'git add --force TODO.md'
# pushes and verification
check 2 'git push --force origin main'
check 2 'git push -f'
check 2 'git push --force-with-lease origin main'
check 2 'git push -uf origin x'
check 0 'git push -u origin chore/internal-structure'
check 0 'git push origin main'
check 2 'git commit -m "x" --no-verify'
check 2 'git commit -n -m "x"'
check 2 'git push --no-verify origin main'
# destructive git
check 2 'git reset --hard HEAD~1'
check 0 'git reset --soft HEAD~1'
check 2 'git branch -D feature/x'
check 0 'git branch -d feature/x'
check 2 'git clean -fd'
check 2 'git clean --force'
check 2 'git checkout -- .'
check 2 'git checkout .'
check 2 'git restore .'
check 2 'git restore --worktree .'
check 2 'git checkout -- shots/'
check 0 'git restore --staged .'
check 0 'git restore --staged check.py'
check 0 'git restore check.py'
check 0 'git checkout -b feat/x'
check 0 'git checkout main'
check 0 'git switch -c chore/x'
check 0 'git merge --ff-only chore/x'
# rm
check 2 'rm -rf docs/'
check 2 'rm -r .claude'
check 2 'rm -rf *'
check 2 'rm -rf build; rm -rf /tmp/x'
check 0 'rm -rf /tmp/claude-1000/x/scratchpad/foo'
check 0 'rm -rf "$CLAUDE_SCRATCHPAD_DIR"/x'
check 0 'rm -rf shots/node_modules'
check 0 'rm -rf __pycache__'
check 0 'find . -name __pycache__ -exec rm -rf {} + 2>/dev/null'
check 0 'find . -name "*.pyc" -exec rm -f {} \; 2>/dev/null'
check 0 'rm og-image.svg'
# ordinary
check 0 'python3 check.py --offline'
check 0 'python3 -m unittest test_check'
check 0 'node shots/shoot.js 375 shots/m.png dark'
check 0 'ls -la'
check 0 'git rm --cached og-image.svg'
# malformed input never blocks
printf 'not json' | bash "$here/guard-bash.sh" >/dev/null 2>&1; [ $? -eq 0 ] && pass=$((pass+1)) || { fail=$((fail+1)); echo "FAIL: malformed stdin should be allowed"; }
echo "passed=$pass failed=$fail"
[ "$fail" -eq 0 ]
