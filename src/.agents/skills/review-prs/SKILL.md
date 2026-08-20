---
name: review-prs
description: Review every open PR/MR on the current repo in one batch - collect all the review-branch decisions up front, then fan out one agent per PR/MR, each in its own worktree. Use when the user says "review all the PRs", "review the open MRs", or similar. For a single PR/MR, use review-branch instead.
---

# Review every open PR/MR

A batch wrapper around `review-branch`. Follow `git-forge` for CLI choice and the glab `--repo` rule.

## 1. List what's open

`gh pr list --json number,title,author,isDraft,headRefName`, or the glab equivalent with `--repo`. Print number, title, author, and draft flag for each. If nothing is open, say so and stop.

## 2. Drop the ones already reviewed

For each candidate, find the newest agent review comment — the ones that open with the `🤖 **Agent Comment**` attribution header (see AGENTS.md). Its `<summary>` line carries the commit it reviewed. Skip the PR/MR when that commit is the current head: the review still describes the code, so there is nothing to redo.

A review that merged primary in without pushing stamps a local commit the forge never saw, so it never matches — those get reviewed again.

Older comments predate the commit stamp. For those, fall back to timestamps — skip when the comment is newer than the newest commit on the head branch — and review it when a rebase leaves the two too close to call.

Review it anyway when the user asks for a re-review, or when the last review was held in a worktree instead of posted. Nothing on the server proves that one happened.

Say which ones you skipped and what they were reviewed at.

## 3. Ask everything up front — one round, then no more questions

The whole point is that the parallel agents never stop to ask. Get every `review-branch` decision answered before you launch anything:

- **Which ones** — all of them, or a subset. Drafts and other people's branches are the usual exclusions.
- **Merge primary in** — yes/no. If yes, **push the merge commit** — yes/no. Inline suggestions need both to be yes.
- **What to do with each review** — hold it in the worktree, post it to the PR/MR, or post it with inline suggestions where findings map cleanly to a single hunk.
- **Worktree collisions** — reuse / recreate / skip, applied to every path that already exists.

Fixing findings is not on the menu here. Unattended commits across many branches is a bad trade — rerun `review-branch` on the ones worth fixing.

Do not launch until all four are answered.

## 4. Fan out — one agent per PR/MR

Run `git fetch origin` once in the main clone first, so the agents don't fight over the lock.

Launch the agents in a single message so they run concurrently. Cap it around six at a time and queue the rest. Give each agent one PR/MR number, the §3 answers verbatim, and these rules:

- Follow the `review-branch` skill end to end.
- The §3 answers are the user's answers — never prompt. Anything they don't cover, take the conservative path (skip the step, post nothing) and report it.
- Work only inside your own worktree. The path is keyed on the branch, so no two agents share one. Never touch another worktree or the main clone.
- `git worktree add` serializes on the main clone's lock. Retry once on a lock error.
- Return: PR/MR number, worktree path, review file path, verdict, blocking-finding count, and what you posted or skipped.

## End: report the table

One row per PR/MR — number, title, verdict, blocking count, posted or held, worktree path. Keep the skipped ones in the table so the batch accounts for everything that is open. Then ask once whether to clean up the worktrees with `git worktree remove <path>`.
