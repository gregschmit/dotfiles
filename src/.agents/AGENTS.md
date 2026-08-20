Check for a project README.md to orient yourself.

Follow these software development guidelines when practical:
- Avoid duplication, but prefer simple duplication over complex DRY abstractions.
- Write code that is easy to understand and maintain.
- Return early to avoid deep nesting.
- Favor composition over inheritance.
- Write data-oriented code: think carefully about your data types.
- In database migrations, most boolean and string columns should have a NOT NULL constraint and a default value (empty string for strings). This simplifies queries, and application logic usually treats blank strings and NULL the same way.
- Lean on ASD-STE100 Simplified Technical English as a guide (not a strict rule — deviate when it reads better) and write with clarity, simplicity, brevity, and humanity (Zinsser).
- Keep comments terse. Explain WHY, not WHAT — unless the code is genuinely hard to follow.
- Don't reference old behavior unless writing an upgrade/migration guide.
- Commit messages: terse, 50/72 line length. Body is a short paragraph unless the commit warrants more. Use `fmt -w 72` to help you wrap lines properly, but note that it clobbers lists, which is why I prefer paragraphs.

Agent worktrees live under `/tmp/agent-worktrees/<origin-path>/<branch>`, where `<origin-path>` is the owner/repo path from the origin remote (e.g. `gregschmit/dotfiles`, `rgnets/rxg`) and `<branch>` may itself contain slashes which should be treated as a subpath:
- Only create a worktree if your skill demands one. Skills that use them (`issue-to-branch`, `review-branch`) print the worktree path when they finish.
- If you are already in a worktree, stay there and just work like normal unless the worktree path doesn't match your work; don't try to create another worktree.
- If you want to create a worktree and it already exists, ask reuse / recreate / abort.
- Worktrees persist across runs so their outputs (edits, `CODE_REVIEW.md`) remain reachable. When you're done, ask the user if you should clean up the worktree with `git worktree remove <path>`.
- When creating a new branch, use the format `<local_username>/<short-kebab-slug>` — short and human-readable, e.g. `gns/fix-portal-devices-ui`. Always branch from the primary branch unless explicitly told otherwise. Do not encode the issue number in the branch name. If creating a new branch in a worktree, use `git worktree add -b <branch> <path> origin/<primary>`.
