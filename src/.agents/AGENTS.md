Check for a project README.md to orient yourself.

Follow these software development guidelines when practical:
- Avoid duplication, but prefer simple duplication over complex DRY abstractions.
- Write code that is easy to understand and maintain.
- Return early to avoid deep nesting.
- Favor composition over inheritance.
- Write data-oriented code: think carefully about your data types.
- In database migrations, most boolean and string columns should have a NOT NULL constraint and a default value (empty string for strings). This simplifies queries, and application logic usually treats blank strings and NULL the same way.
- Lean on ASD-STE100 Simplified Technical English as a guide (not a strict rule — deviate when it reads better) and write with clarity, simplicity, brevity, and humanity (Zinsser). Don't use overly complex words or sentences.
- Keep comments terse. Explain WHY, not WHAT — unless the code is genuinely hard to follow.
- Don't reference old behavior unless writing an upgrade/migration guide.
- Commit messages: terse, 50/72 line length. Body is a short paragraph unless the commit warrants more. Use `fmt -w 72` to help you wrap lines properly, but note that it clobbers lists, which is why I prefer paragraphs.

Agent worktrees live under `/tmp/agent-worktrees/<origin-path>/<branch>`, where `<origin-path>` is the owner/repo path from the origin remote (e.g. `gregschmit/dotfiles`, `rgnets/rxg`) and `<branch>` may itself contain slashes:
- Only create a worktree if your skill demands one. Skills that use them (`issue-to-branch`, `review-branch`, `review-prs`) print the worktree path when they finish.
- If you're already in a worktree and it matches what the user asked for, stay there; otherwise create a new one per the convention below.
- When you would create a worktree at a path that already exists, ask reuse / recreate / abort — do not silently overwrite.
- Worktrees persist across runs so their outputs (edits, `CODE_REVIEW.md`) remain reachable. When you're done, ask the user if you should clean up the worktree with `git worktree remove <path>`.
- New branch in a worktree: `git fetch origin`, then `git worktree add -b <branch> <path> origin/<primary>`.
- Existing branch in a worktree: `git fetch origin`, `git worktree add <path> origin/<primary>`, `cd` in, `git pull`, then attach the target — `gh pr checkout N` / `glab mr checkout N --repo …` for PR/MR mode, or `git checkout <branch> && git pull` for a local branch.
- New branches use `<$USER>/<short-kebab-slug>` — short and human-readable, e.g. `gns/fix-portal-devices-ui`. Always branch from primary unless told otherwise. Do not encode the issue number in the branch name.

Every comment an agent posts to GitHub or GitLab (top-level, review, inline suggestion, follow-up) starts with this attribution header on its own line, a newline, a horizontal rule, another newline, then the content:

```
🤖 **Agent Comment** · [model] · [effort] · [operation]

---

[content]
```

- `[model]` — e.g. `Claude Opus 5 (1M)`. Emit what you know (ideally name, version, and context window); omit information you can't confirm rather than guess.
- `[effort]` — e.g. `high`, `fast`. Omit if unknown.
- `[operation]` — the skill's short label including skill and action; e.g.: `review-branch summary`, `review-branch inline-suggestion`.
- Segments joined by ` · ` (U+00B7 middle dot with a space on each side), never dashes or pipes.
