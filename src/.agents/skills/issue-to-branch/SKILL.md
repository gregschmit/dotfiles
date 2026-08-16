---
name: issue-to-branch
description: Start work on a tracker issue - read it, branch from primary, make the changes, commit, and optionally open a PR/MR. Use when the user says "work on issue N", "start issue N", or similar.
---

# Work an issue → branch (→ optional PR/MR)

Follow `git-forge` for `gh` vs `glab` and the glab `--repo` rule.

## 0. Check the working tree

`git status --porcelain`. If dirty (uncommitted changes or untracked files that would be affected), stop and ask the user what to do — commit, stash, or discard — before branching.

## 1. Read the issue

Fetch the issue by number. Read title, body, and every comment before proposing an approach.

## 2. Check for an existing PR/MR

Search open PRs/MRs referencing the issue. If one exists, stop and ask whether to continue it rather than open a new one.

## 3. Branch from a fresh primary

Determine the primary branch (`git symbolic-ref refs/remotes/origin/HEAD`, fallback to `main` then `master`). `git fetch origin`, then create the branch off the fresh primary tip.

Branch name: `gns/<short-kebab-slug>` — short and human-readable, e.g. `gns/fix-portal-devices-ui`. Do not encode the issue number in the branch name.

## 4. Work

Follow repo conventions (`CLAUDE.md` / `AGENTS.md`, neighboring code). Ask the user before scope expansions the issue does not describe.

## 5. Commit — confirm first

Draft the commit message and share it with the user before running `git commit`. Reference the issue on a final separate line (e.g., `Closes #N`) so the forge links commit ↔ issue.

## 6. Push — confirm first

Confirm with the user before `git push -u origin <branch>`.

## 7. Open a PR/MR — only if requested

The branch may stand on its own — do not assume a PR/MR is wanted. If the user asks for one, draft title and body, share with the user, then open. Body should link the issue (`Closes #N` works on both forges). Open as draft unless told otherwise. Follow any repo CI or template conventions.
