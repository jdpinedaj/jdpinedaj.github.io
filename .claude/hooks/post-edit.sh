#!/usr/bin/env bash
# PostToolUse (Edit|Write): after an edit to the page, the sources or the checker, run the
# unit tests and the offline checks. Exit 2 with the failing output on stderr so it lands in
# context; silent otherwise. Never touches the network (that is `python3 check.py`).
set -u
payload="$(cat)"
path="$(printf '%s' "$payload" | python3 -c 'import json,sys
try:
    print(json.load(sys.stdin).get("tool_input",{}).get("file_path",""))
except Exception:
    print("")' 2>/dev/null)"
[ -n "$path" ] || exit 0
root="${CLAUDE_PROJECT_DIR:-$(pwd)}"; root="${root%/}"
case "$path" in
  "$root"/*) rel="${path#"$root"/}" ;;
  /*) exit 0 ;;
  *) rel="$path" ;;
esac
case "$rel" in
  index.html|styles.css|script.js|sources.md|check.py|test_check.py|og-image.png) ;;
  *) exit 0 ;;
esac
cd "$root" || exit 0

viol=()
if [ "$rel" = "script.js" ]; then
  lines=$(wc -l < script.js | tr -d ' ')
  [ "$lines" -ge 100 ] && viol+=("script.js has $lines lines; the spec keeps it under 100.")
fi
out=$(python3 -m unittest test_check 2>&1) || viol+=("unit tests failed:
$(printf '%s\n' "$out" | tail -25)")
out=$(python3 check.py --offline 2>&1) || viol+=("check.py --offline:
$(printf '%s\n' "$out" | grep -E '^FAIL|failure' | head -20)")

if [ "${#viol[@]}" -gt 0 ]; then
  { echo "post-edit.sh, fix before going on ($rel):"; printf ' - %s\n' "${viol[@]}"; } >&2
  exit 2
fi
exit 0
