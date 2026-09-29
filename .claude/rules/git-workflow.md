# Git workflow (always applies)

- `main` is what GitHub Pages serves; a push to `main` is live within a minute.
  Work on a branch (`feat/`, `fix/`, `chore/`, `docs/` or a plain topic name)
  created from `main`. `main` only receives fast-forward merges.
- A hook refuses edits and commits while `main` is checked out. Do not work
  around it: `git switch -c <branch>` and continue there.
- Commit subject: what changed, in plain words, 72 characters or fewer. This
  repo uses no type prefixes ("Header static on phones", "Review fixes: ...").
  The body, when present, says why.
- Never mention the assistant in a commit, never add a Co-Authored-By or
  "Generated with" line. A hook denies it.
- Never `--no-verify`, never force push, never `reset --hard`, `branch -D` or
  `clean -f` (hook-enforced). Never rewrite pushed history.
- Before a merge to `main`: `python3 -m unittest test_check` and
  `python3 check.py` (with the link check) both green, output quoted. That is
  the `/deploy` skill.
- Commit and push only when Juan asks. Never versioned: `.claude/TODO.md`,
  `.claude/superpowers/` (specs and plans), `shots/*.png`, `.superpowers/`.
  The screenshot scripts in `shots/` are versioned.
- One `git commit` at a time: the `.git` lock on `/mnt/c` fails under
  concurrent commits.
