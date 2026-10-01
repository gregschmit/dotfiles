---
name: review-branches
description: Review a batch of branches/PRs/MRs in one pass - collect all the review-branch decisions up front, then fan out one agent per target, each in its own worktree. Use when the user says "review my PRs", "review these branches", "review the pipeline-complete MRs", or similar. For a single target, use review-branch instead.
---

# Review a batch of branches

A batch wrapper around `review-branch`. Follow `git-forge` for CLI choice and the glab `--repo` rule.

## 1. Resolve the input — five modes

Each mode has a keyword. The user may name the keyword or just describe what they want; map what they say onto one (or more) of these. If multiple are provided, query to find the PR/MR numbers and/or branch names in each mode, and then remove the duplicate entries. With no input at all, use `mine`.

- **`branches`** — an explicit list of branch names. Each is reviewed against primary. If one turns out to have an open PR/MR, treat it as a PR/MR target instead — that gets you the comments and somewhere to post.
- **`prs`** — an explicit list of PR numbers.
- **`mrs`** — an explicit list of MR numbers. Same path as `prs`; forge detection picks the CLI, so either keyword works either place.
- **`pipeline-complete`** — every open MR/PR labeled `llm::pipeline-complete`, the "the LLM pipeline finished, now review its work" batch. `glab mr list --label 'llm::pipeline-complete' --repo …`, or `gh pr list --label 'llm::pipeline-complete' --json number,title,author,isDraft,headRefName`. Quote the label — the `::` is a GitLab scoped-label separator, not shell-safe on its own.
- **`mine`** (the default) — open PRs/MRs where the user is the assignee or the requested reviewer, not everything the repo has open.
  - Assignee OR reviewer, never both at once — one filter per call, then union the results on number. Both forges AND their filters within a single call, so `--assignee=@me --reviewer=@me` returns only the ones where you are both, which is not what we want.
  - **gh** — `gh pr list --assignee @me --json number,title,author,isDraft,headRefName`, then `gh pr list --search "review-requested:@me" --json ...`.
  - **glab** — `glab mr list --assignee=@me --repo …`, then `glab mr list --reviewer=@me --repo …`. If the installed glab lacks a flag, run the same two passes through `glab api` on `assignee_username` / `reviewer_username`.

Print the resolved batch before going further: number (if any), title, author, draft flag, branch, and why it's in the batch. If the batch is empty, say so and stop.

## 2. Account for the ones already reviewed

For each target that has a PR/MR, find the newest agent review comment — the ones that open with the `🤖 **Agent Comment**` attribution header (see AGENTS.md). Its `<summary>` line carries the commit it reviewed. The review is still current when that commit is the current head or the only commit afterwards is the primary branch being merged in to keep it up to date: it already describes the code, so there is nothing to redo.

For current targets, don't perform another review, just keep it for the final report.

Branches with no PR/MR have nothing on the server to check, so they always get reviewed.

## 3. Ask everything up front — one round, then no more questions

The whole point is that the parallel agents never stop to ask. Get every `review-branch` decision answered before you launch anything:

- **Which ones** — all of §1, or a subset. Drafts are the usual exclusion. This is also where the user can add a target the mode didn't pick up, or drop one §2 flagged as already reviewed.
- **Merge primary in** — yes/no. If yes, **push the merge commit** — yes/no. Inline suggestions need both to be yes.
- **What to do with each review** — hold it in the worktree, post it to the PR/MR, or post it with inline suggestions where findings map cleanly to a single hunk. Targets with no PR/MR can only be held; say so rather than asking again per target.
- **Worktree collisions** — reuse / recreate / skip, applied to every path that already exists.

Fixing findings is not on the menu here. Unattended commits across many branches is a bad trade — rerun `review-branch` on the ones worth fixing.

Do not launch until all four are answered.

## 4. Fan out — one agent per target

Run `git fetch origin` once in the main clone first, so the agents don't fight over the lock.

Launch the agents in a single message so they run concurrently. Cap it around six at a time and queue the rest. Give each agent one target (a PR/MR number or a branch name), the §3 answers verbatim, and these rules:

- Follow the `review-branch` skill end to end.
- The §3 answers are the user's answers — never prompt. Anything they don't cover, take the conservative path (skip the step, post nothing) and report it.
- Work only inside your own worktree. The path is keyed on the branch, so no two agents share one. Never touch another worktree or the main clone.
- `git worktree add` serializes on the main clone's lock. Retry once on a lock error.
- Return: the target, worktree path, review file path, verdict, finding count of each category (blocking/should-fix/nit), the merge-readiness confidence with its one-line justification, and what you posted or skipped.

## End: report the table

One row per target — number or branch, title, confidence, verdict, count of findings of each category, posted or held, worktree path. **Sort by confidence, High first**, so the changes the user can merge on sight sit at the top and the ones needing real attention sit at the bottom. Carry each agent's one-line justification for the rating; trim it to a few words if the table gets wide.

Keep the dropped ones in the table so the batch accounts for everything the mode resolved to. Then ask once whether to clean up the worktrees with `git worktree remove <path>`.
