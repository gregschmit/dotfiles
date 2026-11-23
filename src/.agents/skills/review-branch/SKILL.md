---
name: review-branch
description: Review a branch in a worktree, often with PR/MR context. Use when asked to review one branch, PR, or MR.
---

# Review a branch

Follow `git-forge` for CLI choice and the glab `--repo` rule.

## 1. Prepare a worktree, if not already inside one

Determine the branch to review and its base, the branch it merges into (GitLab calls it the target branch):

- PR/MR mode: query the forge (`gh pr view N --json headRefName,baseRefName`, or `source_branch` and `target_branch` from the glab equivalent with `--repo`).
- Local mode: use the branch the user provides. Its base is primary.

Follow the AGENTS.md worktree convention (existing branch). If git refuses because the branch is checked out elsewhere — rare, only if the main clone happens to sit on it — surface the error and ask the user what to do.

`cd` into the worktree. All remaining steps happen there.

## 2. Fetch PR/MR state (PR/MR mode only)

Get title, description, and every comment/thread — top-level and inline. See `git-forge` for why the API subcommands beat `view --comments` when completeness matters. Note unresolved threads separately.

## 3. Check for a current review

Find the newest review. On a PR/MR, it is the newest comment that opens with the `🤖 **Agent` header and holds a `Code Review:` summary line. With no PR/MR, it is `./CODE_REVIEW.md` in a reused worktree. The summary line names the commit it reviewed.

The review is current when no development commits came after that commit, so everything newer is a merge of the base: `git rev-list --no-merges <commit>..HEAD --not origin/<base>` prints nothing. A `+dirty` commit, or one a force push removed, is never current.

If the review is current, skip §4 to §6 unless the user specifically asked for a re-review. Take that review to §7: post it if it exists only in the worktree and there is a PR/MR, or fix from it if asked.

## 4. Merge the base if it matters, and push

Merge `origin/<base>` in when it could surface conflicts or drift, then push the merge commit. Decide from how far behind the branch is (`git rev-list --count HEAD..origin/<base>`):

- More than 10 commits: merge.
- 1 to 10: read them (`git log -p HEAD..origin/<base>`). Merge if any could interact significantly with this branch: the same code, or code this branch calls, extends, or depends on. Otherwise skip the merge and note why in one line.
- 0: nothing to merge.

The user's prompt overrides this: they may ask for a merge regardless, or for no merge or no push.

- Merge in the worktree. If it conflicts, try to resolve them yourself when the correct resolution is obvious from the code on both sides. Only stop and ask the user when the resolution requires a judgment call (semantic overlap, ambiguous intent, non-trivial logic clashes).
- After a clean merge, push the merge commit. A branch with no remote has nothing to push. (This is the exception to the usual "don't touch someone else's branch" rule — the user wants it.)

## 5. Assess the base's impact

List files the base changed since the branch point and files this branch touches. For overlaps, say briefly whether the base's changes affect this work. Judgment call — spell out your reasoning; do not reduce it to a script. If §4 skipped the merge, include its reason.

## 6. Run the code review

Invoke the `code-review` skill in `branch` mode against the base. It writes `./CODE_REVIEW.md` (inside the worktree) and includes a suggested squash-merge commit message. Do not push that message or edit the PR/MR description yourself — it's for the human to copy into the squash box.

## 7. Choose: post the review or fix the findings

Decide from the user's prompt — don't ask. Post the review by default. Fix the findings only when the user specifically asks for fixes, and leave the review in the worktree if they say not to post.

- **Post the review** — top-level comment or review submission, whichever fits. Post the full code-review output as-is, preserving both `<details>` blocks (review and suggested commit message). With no PR/MR there is nowhere to post, so leave the review in the worktree.
  - **Inline suggested changes** — only when the user specifically asks; don't offer them. They need PR/MR mode and a local head that matches the pushed head: no §4 merge, or one that merged cleanly and was pushed (otherwise inline anchors drift from the server-side head SHA and the API rejects the position). If that didn't happen, say so and post the review without them. Post each finding that maps to a single diff hunk as an inline suggestion — see `git-forge` for the gh/glab APIs. Skip findings that don't map cleanly.
- **Fix the findings** — work through Blocking and Should-fix items in the worktree, commit (confirm the message first), push, and if a PR/MR exists, post a short comment citing each finding's code to say what was addressed and what was intentionally left.

## End: report the worktree

Print the worktree path, the review file, and the summary row the review landed on, e.g.

    Worktree:   ~/git/rgnets/rxg.worktrees/feature/new-thing
    Review:     ~/git/rgnets/rxg.worktrees/feature/new-thing/CODE_REVIEW.md
    Confidence: High
    Difficulty: Trivial
    Findings:   0 blocking / 2 should-fix / 3 nits
    Why:        comments only, no code paths touched
