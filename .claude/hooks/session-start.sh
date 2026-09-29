#!/usr/bin/env bash
# SessionStart: one line of repo state so the branch step is never skipped by accident.
set -u
cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0
branch="$(git branch --show-current 2>/dev/null || echo '?')"
dirty="$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')"
last="$(git log -1 --format='%h %ad %s' --date=short 2>/dev/null || echo 'n/a')"
warn=""
[ "$branch" = "main" ] && warn=" You are on main (what Pages serves): create a working branch from dev before editing (git switch -c <type>/<topic> dev)."
[ "$branch" = "dev" ] && warn=" You are on dev (integration branch): create a working branch from it before editing (git switch -c <type>/<topic> dev)."
ctx="Branch: ${branch}. Uncommitted files: ${dirty}. Last commit: ${last}.${warn}"
python3 -c 'import json,sys;print(json.dumps({"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":sys.argv[1]}}))' "$ctx"
