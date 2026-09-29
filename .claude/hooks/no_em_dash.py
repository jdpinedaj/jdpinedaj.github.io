#!/usr/bin/env python3
"""PreToolUse hook: block Edit/Write calls whose new content contains an em-dash (U+2014).

Reads the tool call as JSON on stdin. Exit 0 lets it through; exit 2 blocks it and the
stderr message is shown to the model. check.py enforces the same rule on the whole
repository at check time; this hook catches it at write time.

Files outside the project (memory, scratchpad, other repos) are not this repo's business
and pass untouched.

Limit: only Edit and Write go through this hook. Content written via a bash heredoc is
caught later by the post-edit hook or by check.py.
"""
from __future__ import annotations

import json
import os
import sys

EM_DASH = chr(0x2014)


def outside_project(path: str) -> bool:
    root = os.environ.get("CLAUDE_PROJECT_DIR", "").rstrip("/")
    if not root or not path.startswith("/"):
        return False
    return not (path == root or path.startswith(root + "/"))


def main() -> int:
    try:
        call = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        return 0
    tool_input = call.get("tool_input") or {}
    path = str(tool_input.get("file_path", ""))
    if outside_project(path):
        return 0
    text = tool_input.get("content") if "content" in tool_input else tool_input.get("new_string", "")
    if not text or EM_DASH not in text:
        return 0
    lines = [str(i) for i, line in enumerate(text.splitlines(), start=1) if EM_DASH in line]
    print(
        f"Em-dash (U+2014) in {path or 'new content'} at line(s) {', '.join(lines)}. "
        "Replace it with a comma, full stop, colon or parentheses.",
        file=sys.stderr,
    )
    return 2


if __name__ == "__main__":
    sys.exit(main())
