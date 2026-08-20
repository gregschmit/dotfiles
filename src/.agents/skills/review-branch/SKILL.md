---
name: review-branch
description: Review a branch in a worktree - either a local branch against primary, or a PR/MR by number (checked out via the forge). Collects comments if a PR/MR exists, runs a full code review, and then either posts the review or works on the findings. Use when the user says "review this branch", "review PR N", "review MR N", or similar.
---

# Review a branch

Follow `git-forge` for CLI choice and the glab `--repo` rule.

## 1. Prepare a worktree, if not already inside one

Determine the target branch:

- PR/MR mode: query the forge (`gh pr view N --json headRefName -q .headRefName`, or the glab equivalent with `--repo`).
- Local mode: use the branch the user provides.

Follow the AGENTS.md worktree convention (existing branch). If git refuses because the branch is checked out elsewhere — rare, only if the main clone happens to sit on it — surface the error and ask the user what to do.

`cd` into the worktree. All remaining steps happen there.

## 2. Fetch PR/MR state (PR/MR mode only)

Get title, description, and every comment/thread — top-level and inline. See `git-forge` for why the API subcommands beat `view --comments` when completeness matters. Note unresolved threads separately.

## 3. Merge primary — ask first

Ask the user whether to merge the primary branch in to surface conflicts/drift, and whether to push the merge commit. If yes:

- Merge in the worktree. If it conflicts, try to resolve them yourself when the correct resolution is obvious from the code on both sides. Only stop and ask the user when the resolution requires a judgment call (semantic overlap, ambiguous intent, non-trivial logic clashes).
- After a clean merge, push the merge commit up if requested. (This is the exception to the usual "don't touch someone else's branch" rule — the user asked for it.)

If no, skip.

## 4. Assess primary's impact

List files primary changed since the branch point and files this branch touches. For overlaps, say briefly whether primary's changes affect this work. Judgment call — spell out your reasoning; do not reduce it to a script.

## 5. Run the code review

Invoke the `code-review` skill in `branch` mode against the current state. It writes `./CODE_REVIEW.md` (inside the worktree) and includes a suggested squash-merge commit message. Do not push that message or edit the PR/MR description yourself — it's for the human to copy into the squash box.

## 6. Ask the user which path

Confirm before either — both are visible to other humans:

- **Post the review** — only if a PR/MR exists. Top-level comment or review submission, whichever fits. Post the full code-review output as-is, preserving both `<details>` blocks (review and suggested commit message).
  - **Optional add-on: inline suggested changes.** Only offer this when all of the following hold: PR/MR mode, the §3 merge-primary was requested, merged cleanly, and was pushed (otherwise inline anchors drift from the server-side head SHA and the API rejects the position). If the user asks for it, post each finding that maps to a single diff hunk as an inline suggestion — see `git-forge` for the gh/glab APIs. Skip findings that don't map cleanly.
- **Fix the findings** — work through Blocking and Should-fix items in the worktree, commit (confirm the message first), push, and if a PR/MR exists, post a short comment noting what was addressed and what was intentionally left.

## End: report the worktree

Print the worktree path and the review file, e.g.

    Worktree: /tmp/agent-worktrees/rgnets/rxg/feature/new-thing
    Review:   /tmp/agent-worktrees/rgnets/rxg/feature/new-thing/CODE_REVIEW.md
