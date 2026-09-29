# Git workflow (always applies)

Three kinds of branch, enforced by `.claude/hooks/guard-branch.sh`:

- `main`: what GitHub Pages serves; a push is live within a minute. It only
  receives a fast-forward merge of `dev`, and only after Juan has said yes to
  that specific merge. No edits, no commits on it.
- `dev`: the integration branch, created from `main`. It only receives merges
  of working branches. No edits, no commits on it.
- Working branches: `feature/`, `bugfix/`, `docs/`, `chore/` (or a plain
  topic name), always created from `dev`:
  `git switch -c <type>/<topic> dev`. All edits and commits happen here.

The cycle for any change:

1. `git switch -c <type>/<topic> dev` (from an up-to-date `dev`).
2. Edit, run the checks, commit on the working branch.
3. Merge into `dev`: `git switch dev && git merge --ff-only <branch>`. If it
   cannot fast-forward, `git rebase dev` on the working branch, re-run the
   checks, then merge.
4. Delete the working branch: `git branch -d <branch>` (never `-D`).
5. Ask Juan whether `dev` should go to `main`. Only after his yes:
   `git switch main && git merge --ff-only dev`, and `git push origin main`
   only when he asks to push. That is the `/deploy` skill.

Other rules:

- Commit subject: what changed, in plain words, 72 characters or fewer. This
  repo uses no type prefixes in subjects ("Header static on phones"). The
  body, when present, says why.
- Never mention the assistant in a commit, never add a Co-Authored-By or
  "Generated with" line. A hook denies it.
- Never `--no-verify`, never force push, never `reset --hard`, `branch -D` or
  `clean -f` (hook-enforced). Never rewrite pushed history.
- Before a merge to `main`: `python3 -m unittest test_check` and
  `python3 check.py` (with the link check) both green, output quoted.
- Never versioned: `.claude/TODO.md`, `.claude/superpowers/` (specs and
  plans), `shots/*.png`, `.superpowers/`. The screenshot scripts in `shots/`
  are versioned.
- One `git commit` at a time: the `.git` lock on `/mnt/c` fails under
  concurrent commits.
