---
name: review-branches
description: Use when asked to review several branches, PRs, or MRs.
---

# Review a batch of branches

A batch wrapper around `review-branch`. Follow `git-forge` for CLI choice and the glab `--repo` rule.

## 1. Resolve the input — five modes

Each mode has a keyword. The user may name the keyword or just describe what they want; map what they say onto one (or more) of these. If multiple are provided, query to find the PR/MR numbers and/or branch names in each mode, and then remove the duplicate entries. With no input at all, use `mine`.

- **`branches`** — an explicit list of branch names. Each is reviewed against primary. If one turns out to have an open PR/MR, treat it as a PR/MR target instead — that gets you the comments and somewhere to post.
- **`prs`** — an explicit list of PR numbers.
- **`mrs`** — an explicit list of MR numbers. Same path as `prs`; forge detection picks the CLI, so either keyword works either place.
- **`pipeline-complete`** — every open MR/PR labeled `llm::pipeline-complete`, the "the LLM pipeline finished, now review its work" batch. `glab mr list --label 'llm::pipeline-complete' --repo …`, or `gh pr list --label 'llm::pipeline-complete' --json number,title,author,isDraft,headRefName`. Quote the label — the `::` is a GitLab scoped-label separator, not shell-safe on its own.
- **`mine`** (the default) — open PRs/MRs where the user is the author, the assignee, or the requested reviewer, not everything the repo has open.
  - Author OR assignee OR reviewer — one filter per call, then union the results on number. Both forges AND their filters within a single call, so `--author=@me --assignee=@me` returns only the ones where you are both, which is not what we want.
  - **gh** — `gh pr list --author @me --json number,title,author,isDraft,headRefName`, then `gh pr list --assignee @me --json ...`, then `gh pr list --search "review-requested:@me" --json ...`.
  - **glab** — `glab mr list --author=@me --repo …`, then `glab mr list --assignee=@me --repo …`, then `glab mr list --reviewer=@me --repo …`. If the installed glab lacks a flag or rejects `@me`, run the same three passes through `glab api` on `author_username` / `assignee_username` / `reviewer_username`.

Print the resolved batch before going further: number (if any), title, author, draft flag, branch, and why it's in the batch. If the batch is empty, say so and stop.

## 2. Account for the ones already reviewed

Run the `review-branch` §3 check on each target from the main clone, with the branch's head in place of `HEAD`. For a branch with no PR/MR, read the review from its worktree, if one exists.

Launch no agent for a target with a current review, unless the user specifically asked for a re-review. Keep its review for the final report.

## 3. Confirm the batch — one round, then no more questions

The whole point is that the parallel agents never stop to ask. These are the defaults for every target. The user's prompt or answer can override any of them:

- **Merge the base branch in when `review-branch` §4 calls for it, and push the merge commit.** The base is what the PR/MR merges into, or primary for a bare branch.
- **Post the review** to the PR/MR. Targets with no PR/MR hold it in the worktree. Add inline suggestions only when the user asks.

Print the defaults under the batch and ask one question: which ones — all of §1, or a subset. Drafts are the usual exclusion. In the same answer the user can add a target the mode didn't pick up, ask for a re-review of one §2 found current, or change a default. Skip the question when the user named the targets.

Fixing findings is not on the menu here. Unattended commits across many branches is a bad trade — rerun `review-branch` on the ones worth fixing.

## 4. Fan out — one agent per target

Run `git fetch origin` once in the main clone first, so the agents don't fight over the lock.

Launch the agents in a single message so they run concurrently. Cap it around ten at a time and queue the rest. Give each agent one target (a PR/MR number or a branch name), the §3 settings (defaults plus any overrides), and these rules:

- Follow the `review-branch` skill end to end.
- The §3 settings are the user's answers — never prompt. Anything they don't cover, take the conservative path (skip the step, post nothing) and report it.
- Work only inside your own worktree. The path is keyed on the branch, so no two agents share one. Never touch another worktree or the main clone.
- `git worktree add` serializes on the main clone's lock. Retry once on a lock error.
- If this is a branch labeled `llm::pipeline-complete`, then if there are any blocking findings, the label should be removed and a new label `llm::ready-to-implement` should be added.
- Return: the target, worktree path, review file path, verdict, the review's whole summary row (confidence, difficulty, blocking/should-fix/nit counts, and the one-line why), and what you posted or skipped.

## End: report the table

One row per target — number or branch (link to the PR/MR if available), title, confidence, difficulty, findings as `B/S/N`, posted or held, worktree path. **Sort by confidence descending (High, Medium, Low), then by difficulty ascending (Trivial, Low, Medium, High)**, so the safest merges sit at the top, quickest first, and the ones needing real work sit at the bottom. Carry each agent's one-line why; trim it to a few words if the table gets wide.

Keep the dropped ones in the table so the batch accounts for everything the mode resolved to. Then ask once whether to clean up the worktrees with `git worktree remove <path>`.
