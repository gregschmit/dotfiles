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

## 6. Commit

Commit the change without asking: the request to work on the issue covers commits and pushes on its branch. Start the message from the last review's suggested message. Reference the issue on a final separate line (e.g., `Closes #N`) so the forge links commit ↔ issue.

## 7. Push

Run `git push -u origin <branch>`. If you can tell that you lack the rights to push, e.g. `origin` is an `https` URL, do not push: skip §8.

## 8. Open a PR/MR

Open one by default. Leave it out only when the user says so, or when the branch was not pushed. Draft title and body, share with the user, then open. Body should link the issue (`Closes #N` works on both forges). Open as draft unless told otherwise. Follow any repo CI or template conventions.

## End: clean up and report

Remove the worktree, as AGENTS.md says. Print the branch, the PR/MR (or why there is none), and how `develop` ended, e.g.

    Branch:  gns/fix-portal-devices-ui
    PR/MR:   https://github.com/owner/repo/pull/12
    Outcome: approved after 2 reviews

If the worktree stays, add a `Worktree:` line with its path and the reason.
