---
name: review-branch
description: Review a branch - either the local branch against primary, or a PR/MR by number (checked out via the forge). Collects comments if a PR/MR exists, runs a full code review, and then either posts the review or works on the findings. Use when the user says "review this branch", "review PR N", "review MR N", or similar.
---

# Review a branch

Follow `git-forge` for CLI choice and the glab `--repo` rule.

## 0. Check the working tree

`git status --porcelain`. If dirty (uncommitted changes or untracked files that would be affected), stop and ask the user what to do — commit, stash, or discard — before checking out or merging.

## 1. Pick the mode

- **PR/MR number supplied** (or currently open on GitHub/GitLab for the current branch): fetch the PR/MR state — title, description, and every comment/thread (top-level and inline). See `git-forge` for why the API subcommands beat `view --comments` when completeness matters. Note unresolved threads separately. Then check the branch out via the forge CLI (`gh pr checkout N`, or `glab mr checkout N --repo ...`).
- **No PR/MR** (local branch review): stay on the current branch. Skip the fetch-state step.

`git fetch origin` either way.

## 2. Merge primary — ask first

Ask the user whether to merge the primary branch in to surface conflicts and drift. If yes:

- Merge locally. If it conflicts, try to resolve them yourself when the correct resolution is obvious from the code on both sides. Only stop and ask the user when the resolution requires a judgment call (semantic overlap, ambiguous intent, non-trivial logic clashes).
- After a clean merge, push the merge commit up. (This is the exception to the usual "don't touch someone else's branch" rule — the user asked for it.)

If no, skip.

## 3. Assess primary's impact

List files primary changed since the branch point and files this branch touches. For overlaps, say briefly whether primary's changes affect this work. Judgment call — spell out your reasoning; do not reduce it to a script.

## 4. Run the code review

Invoke the `code-review` skill in `branch` mode against the current state. It writes `./CODE_REVIEW.md`.

## 5. Ask the user which path

Confirm before either — both are visible to other humans:

- **Post the review** — only if a PR/MR exists. Top-level comment or review submission, whichever fits. Preserve the code-review markdown, including the `<details>` wrapper.
- **Fix the findings** — work through Blocking and Should-fix items, commit (confirm the message first), push, and if a PR/MR exists, post a short comment noting what was addressed and what was intentionally left.
