---
name: work-on-issue
description: Implement an issue on a new branch. Use when asked to work on or start a tracker issue.
---

# Work on an issue

Follow `git-forge` for `gh` vs `glab` and the glab `--repo` rule.

## 1. Read the issue

Fetch the issue by number. Read title, body, and every comment before proposing an approach. A `triage-issue` comment is a head start, not a fact: check that it still holds.

## 2. Check for an existing PR/MR

Search open PRs/MRs referencing the issue. If one exists, stop and ask whether to continue it rather than open a new one.

## 3. Analyze

Decide what done means: the behavior to change, how to confirm it, and what is out of scope. If the issue is too vague to build, or a triage comment says it is not `ready`, stop and ask.

Run a bakeoff only if the user asks for one. If the issue leaves the design open, suggest one before you start.

## 4. Branch

Create a new branch inside a worktree. `cd` into the worktree. All remaining steps happen there.

## 5. Develop

Invoke `develop`, with a bakeoff if §3 chose one, and a task written from §3: the issue number, what done means, and what is out of scope. If it ends in anything but approval, show the user the open or refused findings and ask how to proceed.

## 6. Commit — confirm first

Draft the commit message and share it with the user before running `git commit`. Start from the last review's suggested message. Reference the issue on a final separate line (e.g., `Closes #N`) so the forge links commit ↔ issue. Leave `CODE_REVIEW.md` out of the commit.

## 7. Push — confirm first

Confirm with the user before `git push -u origin <branch>`.

## 8. Open a PR/MR — only if requested

The branch may stand on its own — do not assume a PR/MR is wanted. If the user asks for one, draft title and body, share with the user, then open. Body should link the issue (`Closes #N` works on both forges). Open as draft unless told otherwise. Follow any repo CI or template conventions.

## End: report the worktree

Print the worktree path and how `develop` ended, e.g.

    Worktree: ~/git/dotfiles.worktrees/gns/fix-portal-devices-ui
    Outcome:  approved after 2 reviews
