---
description: Stage and commit changes with git. Use when asked to commit, or to commit and push. Pass a one-line note of what changed and why as arguments — this runs without the conversation's context.
when_to_use: User says "commit", "commit it", "commit this", "commit and push".
model: sonnet
effort: medium
background: false
---

Be fast. Run `git status --short; git diff HEAD` as one call, then stage and
commit as one call (`git add <paths> && git commit -m ...`). Push only if asked.
The diff is enough — don't browse `git log` or re-read changed files.

Follow any commit conventions in the repo's CLAUDE.md — grouping, message length,
style. They override the defaults here.

Stage explicit paths: `git add .` and `-A` abort with exit 128 inside the sandbox.
`git status` may also list untracked paths that don't exist on disk — the sandbox
masks deny-listed paths with character devices (`crw-rw-rw- nobody nobody 1, 3`),
typically `.bashrc`, `.zshrc`, `.gitconfig`, `.idea`, `.vscode`, `.mcp.json`,
`.claude/`. Skip them silently, don't investigate. Regular files are real.

Extra instructions for this commit, if any: $ARGUMENTS
