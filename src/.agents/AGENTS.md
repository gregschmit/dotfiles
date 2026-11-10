# General Agent Instructions

## Software Development Guidelines

- Check for a project README.md to orient yourself.
- Avoid duplication, but prefer simple duplication over complex DRY abstractions.
- Write code that is easy to understand and maintain.
- Return early to avoid deep nesting.
- Favor composition over inheritance.
- Write data-oriented code: think carefully about your data types.
- In database migrations:
  - Use foreign key constraints for referential integrity; always explicitly specify ON DELETE behavior (CASCADE, SET NULL, RESTRICT, etc.).
  - Join tables should almost always have a composite index with a uniqueness constraint.
  - Most boolean and string columns should have a NOT NULL constraint and a default value (empty string for strings). This simplifies queries, and application logic often treats blank strings and NULL the same way.
  - Multiple migrations in a feature branch should typically be squashed into a single migration before merging into the target branch.
- Lean on ASD-STE100 Simplified Technical English as a guide (not a strict rule — deviate when it reads better) and write with clarity, simplicity, brevity, and humanity (Zinsser). Don't use overly complex words or sentences.
- Keep comments terse. Explain WHY, not WHAT — unless the code is genuinely hard to comprehend.
- Don't reference old behavior unless writing an upgrade/migration guide.
- Commit messages: terse, 50/72 line length. Body is a short paragraph unless the commit warrants more. Use `fmt -w 72` to help you wrap lines properly, but note that it clobbers lists, which is why I prefer paragraphs.

## Worktrees

Agent worktrees live under `<project>.worktrees/<branch>`, beside the main checkout, so `~/git/rgnets/rxg` keeps them in `~/git/rgnets/rxg.worktrees`. Find `<project>` with `dirname "$(git rev-parse --path-format=absolute --git-common-dir)"`, because `--show-toplevel` gives the worktree when you are inside one. `<branch>` may itself contain slashes:
- Only create a worktree if your skill or task demands one. Skills that use them print the worktree path when they finish.
- If you're already in a worktree and it matches what the user asked for, stay there; otherwise create a new one per the convention below.
- When you would create a worktree at a path that already exists, ask reuse / recreate / abort — do not silently overwrite.
- Worktrees persist across runs so their outputs (edits, `CODE_REVIEW.md`) remain reachable. When you're done, ask the user if you should clean up the worktree with `git worktree remove <path>`.
- New branch in a worktree: `git fetch origin`, then `git worktree add -b <branch> <path> origin/<primary>`.
- Existing branch in a worktree: `git fetch origin`, `git worktree add <path> origin/<primary>`, `cd` in, `git pull`, then attach the target — `gh pr checkout N` / `glab mr checkout N --repo …` for PR/MR mode, or `git checkout <branch> && git pull` for a local branch.
- New branches use `<$USER>/<short-kebab-slug>` — short and human-readable, e.g. `gns/fix-portal-devices-ui`. Always branch from primary unless told otherwise. Do not encode the issue number in the branch name.

## Comment Attribution

Everything an agent posts or sends MUST start with this attribution header. Above all, that means every comment on GitHub or GitLab (even inline suggestions), but it also covers emails, comments on other websites, and any other posting of any kind:

```
🤖 **Agent Comment** · [model] · [effort] · [operation]

---

[content]
```

- `[model]` — e.g. `Claude Opus 5.5 (1M)`. Emit what you know (ideally name, full version, and context window); omit information you can't confirm rather than guess.
- `[effort]` — e.g. `high`, `fast`. Omit if unknown.
- `[operation]` — primary active skill and/or action; e.g.: `review-branch summary`, `review-branch inline-suggestion`.
