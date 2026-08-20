---
name: issue-to-branch
description: Start work on a tracker issue - read it, branch from primary in a fresh worktree, make the changes, commit, and optionally open a PR/MR. Use when the user says "work on issue N", "start issue N", or similar.
---

# Work an issue → branch (→ optional PR/MR)

Follow `git-forge` for `gh` vs `glab` and the glab `--repo` rule.

## 1. Read the issue

Fetch the issue by number. Read title, body, and every comment before proposing an approach.

## 2. Check for an existing PR/MR

Search open PRs/MRs referencing the issue. If one exists, stop and ask whether to continue it rather than open a new one.

## 3. Branch

Create a new branch inside a worktree. `cd` into the worktree. All remaining steps happen there.

## 4. Work

Follow repo conventions (`CLAUDE.md` / `AGENTS.md`, neighboring code). Ask the user before scope expansions the issue does not describe.

## 5. Commit — confirm first

Draft the commit message and share it with the user before running `git commit`. Reference the issue on a final separate line (e.g., `Closes #N`) so the forge links commit ↔ issue.

## 6. Push — confirm first

Confirm with the user before `git push -u origin <branch>`.

## 7. Open a PR/MR — only if requested

The branch may stand on its own — do not assume a PR/MR is wanted. If the user asks for one, draft title and body, share with the user, then open. Body should link the issue (`Closes #N` works on both forges). Open as draft unless told otherwise. Follow any repo CI or template conventions.

## End: report the worktree

Print the worktree path plainly, e.g.

    Worktree: /tmp/agent-worktrees/gregschmit/dotfiles/gns/fix-portal-devices-ui
