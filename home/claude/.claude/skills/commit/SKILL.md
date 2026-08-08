---
description: Stage and commit changes with git. Use when asked to commit, or to commit and push.
when_to_use: User says "commit", "commit it", "commit this", "commit and push".
model: sonnet
effort: medium
context: fork
background: false
---

Check `git status --short` and `git diff` to see what actually changed, stage it,
and commit. Push only if asked.

Follow any commit conventions in the repo's CLAUDE.md — grouping, message length,
style. They override the defaults here.

Extra instructions for this commit, if any: $ARGUMENTS
