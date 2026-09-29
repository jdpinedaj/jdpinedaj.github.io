---
name: deploy
description: Closing checklist to take dev live on GitHub Pages (working branch merged into dev and deleted, checks, screenshots, review, Juan's explicit yes, fast-forward merge of dev into main, push, live verification). Only when Juan asks to deploy, publish, merge or push.
disable-model-invocation: true
---
# Deploy

GitHub Pages serves the root of `main`; a push is live within about a minute.
Run in order; do not report "deployed" until step 8 shows the new content.

1. `git branch --show-current` is a working branch (`feature/`, `bugfix/`,
   `docs/`, `chore/` or a topic name), not `main` or `dev`. Working tree clean
   (`git status --short` empty) or only gitignored files.
2. `/check`: unit tests and `python3 check.py` (with links) both green, output
   quoted.
3. If the diff touches `index.html`, `styles.css` or `script.js`: `/shots` at
   375, 768 and 1280 in both themes, and the `page-reviewer` agent on the
   diff. Resolve its findings first.
4. `.claude/TODO.md` (gitignored): remove what this branch closed, add what it
   opened.
5. Commits: plain subjects, no tool attribution. Squash nothing; the history
   is the log.
6. Merge the working branch into `dev`, fast-forward only, then delete it:
   ```bash
   git switch dev && git merge --ff-only <branch> && git branch -d <branch>
   ```
   If it cannot fast-forward, go back to the branch, `git rebase dev`,
   re-run step 2, then merge.
7. Stop and ask Juan: "dev is at <hash>, <n> commits ahead of main. Merge to
   main?" Only after his yes:
   ```bash
   git switch main && git merge --ff-only dev
   ```
   `git push origin main` only when Juan says push. Then `git switch dev`.
8. Verify live after about a minute:
   ```bash
   curl -sI https://jdpinedaj.github.io/ | head -5
   curl -s https://jdpinedaj.github.io/ | grep -c "<article class=\"card\""
   ```
   The second number is 4. Open the URL in a browser for a layout change.
9. Report: commits merged, check output, live verification, what remains in
   `.claude/TODO.md`.
