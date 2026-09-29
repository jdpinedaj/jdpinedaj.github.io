#!/usr/bin/env bash
# PreToolUse guard for the Bash tool. Reads the hook JSON on stdin and denies (exit 2,
# reason on stderr) commands that break hard repo rules. Anything unparseable is allowed.
# Rules are judged per shell segment (split on ; && || |), and the git rules only on
# segments that invoke git, so a word in a grep pattern or a path elsewhere in the same
# command is not mistaken for a commit message.
set -u
set -f   # never glob-expand tokens taken from the command
payload="$(cat)"
cmd="$(printf '%s' "$payload" | python3 -c 'import json,sys
try:
    d=json.load(sys.stdin); print(d.get("tool_input",{}).get("command",""))
except Exception:
    print("")' 2>/dev/null)"
[ -z "$cmd" ] && exit 0
deny() { printf 'BLOCKED by .claude/hooks/guard-bash.sh: %s\n' "$1" >&2; exit 2; }
has() { printf '%s' "$2" | grep -qE "$1"; }
em_dash="$(printf '\xe2\x80\x94')"

segs="$(printf '%s' "$cmd" | python3 -c 'import re,sys
s=sys.stdin.read().replace(chr(92)+";", " ")
print("\n".join(re.split(r"\|\||&&|;|\||\n", s)))')"
while IFS= read -r seg; do
  [ -z "${seg// /}" ] && continue
  lseg="$(printf '%s' "$seg" | tr '[:upper:]' '[:lower:]')"
  first="$(printf '%s' "$lseg" | sed -E 's/^[[:space:]]*(sudo[[:space:]]+)?//; s/[[:space:]].*$//')"

  if [ "$first" = "git" ]; then
    # 1. Commit messages: no tool attribution, no em-dash, no message read from a file
    #    (it cannot be scanned). Path tokens are stripped before scanning.
    if has '[[:space:]]commit([[:space:]]|$)' "$lseg"; then
      source_text="$lseg"
      has '<<' "$lseg" && source_text="$(printf '%s' "$cmd" | tr '[:upper:]' '[:lower:]')"
      scan="$(printf '%s' "$source_text" | sed -E -e 's#/tmp/claude-[^[:space:]"|;&]*##g' -e 's#(^|[[:space:]/])\.claude/[^[:space:]]*##g')"
      has 'claude|anthropic|co-authored-by|generated with' "$scan" && deny "commit message carries tool attribution; rewrite it"
      printf '%s' "$scan" | LC_ALL=C grep -qF "$em_dash" && deny "commit message contains an em-dash; use a comma, colon or full stop"
      has '[[:space:]](-f|--file|-t|--template)(=|[[:space:]]+)([^-[:space:]]|-[^[:space:]])' "$lseg" \
        && deny "commit messages from a file cannot be checked; pass the message with -m or -F -"
      has '[[:space:]](--no-verify|-n)([[:space:]]|$)' "$lseg" && deny "--no-verify skips the checks; fix the cause instead"
    fi
    # 2. Staging: never force past .gitignore.
    if has '[[:space:]]add([[:space:]]|$)' "$lseg"; then
      has '[[:space:]](-[a-z]*f[a-z]*|--force)([[:space:]]|$)' "$lseg" && deny "git add --force bypasses .gitignore"
    fi
    # 3. Pushes: never forced, never unverified.
    if has '[[:space:]]push([[:space:]]|$)' "$lseg"; then
      has '[[:space:]](-[a-z]*f[a-z]*|--force[^[:space:]]*)([[:space:]]|$)|[[:space:]]\+[a-z]' "$lseg" && deny "force push is not allowed"
      has '[[:space:]]--no-verify([[:space:]]|$)' "$lseg" && deny "--no-verify skips the checks; fix the cause instead"
    fi
    # 4. Destructive git.
    has '[[:space:]]reset([[:space:]]|$)' "$lseg" && has '[[:space:]]--hard([[:space:]]|$)' "$lseg" && deny "git reset --hard discards work"
    has '[[:space:]]branch([[:space:]]|$)' "$lseg" \
      && has '[[:space:]](-[a-zA-Z]*D[a-zA-Z]*|--delete[[:space:]]+--force|--force[[:space:]]+--delete)([[:space:]]|$)' "$seg" \
      && deny "git branch -D force-deletes a branch"
    has '[[:space:]]clean([[:space:]]|$)' "$lseg" && has '[[:space:]](-[a-z]*f[a-z]*|--force)([[:space:]]|$)' "$lseg" && deny "git clean -f deletes untracked files"
    if has '[[:space:]](checkout|restore)([[:space:]]|$)' "$lseg"; then
      inspect=1
      has '[[:space:]]checkout[^;&|]*[[:space:]]-[a-zA-Z]*[bB][a-zA-Z]*([[:space:]]|$)' "$seg" && inspect=0
      if has '[[:space:]]restore([[:space:]]|$)' "$lseg"; then
        has '[[:space:]](--staged|-[a-zA-Z]*S[a-zA-Z]*)([[:space:]]|$)' "$seg" && ! has '[[:space:]](--worktree|-[a-zA-Z]*W[a-zA-Z]*)([[:space:]]|$)' "$seg" && inspect=0
      fi
      if [ "$inspect" = 1 ]; then
        targets="$(printf '%s' "$seg" | sed -E 's/^.*[[:space:]](checkout|restore)([[:space:]]+|$)//')"
        for tok in $targets; do
          case "$tok" in
            -*) continue ;;
            .|'*'|:/|*/) deny "discarding a whole tree or directory is not allowed ($tok)" ;;
          esac
        done
      fi
    fi
    continue
  fi

  # 5. rm -r / rm -f only inside temp dirs or the gitignored screenshot tooling.
  if has '(^|[[:space:]])rm[[:space:]]+' "$seg"; then
    args="$(printf '%s' "$seg" | sed -E 's/^.*(^|[[:space:]])rm[[:space:]]+//')"
    has '(^|[[:space:]])(-[a-zA-Z]*[rRf][a-zA-Z]*|--recursive|--force)([[:space:]]|$)' " $args" || continue
    for tok in $args; do
      case "$tok" in
        -*) continue ;;
        '{}'|'+') continue ;;
        [0-9]*'>'*|[0-9]*'<'*|'>'*|'<'*) continue ;;
        /tmp/*|"${CLAUDE_SCRATCHPAD_DIR:-/nonexistent}"*) continue ;;
        '$CLAUDE_SCRATCHPAD_DIR'*|'"$CLAUDE_SCRATCHPAD_DIR'*|'${CLAUDE_SCRATCHPAD_DIR}'*|'"${CLAUDE_SCRATCHPAD_DIR}'*) continue ;;
        shots/node_modules*|./shots/node_modules*|__pycache__|./__pycache__|*/__pycache__) continue ;;
        *) deny "rm -r/-f outside a temp directory ($tok)" ;;
      esac
    done
  fi
done <<< "$segs"
exit 0
