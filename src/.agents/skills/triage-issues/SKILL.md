---
name: triage-issues
description: Evaluate and rank issues. Use when asked to triage several issues, or to show existing triages.
---

# Triage a batch of issues

A batch wrapper around `triage-issue`, plus the comparison that one issue alone cannot give. Follow `git-forge` for CLI choice and the glab `--repo` rule.

## Report only

If the user says `report`, or asks only to see existing triages, follow this section and skip §1 to §6. It evaluates nothing, starts no agents, posts nothing, and needs no worktree.

Scan the 200 most recent open issues, unless the user asks for more. Find their triages as §2 describes, and leave out issues with no triage.

Print the table from End, sorted the same way, with the triage's date in place of posted or held. Under it, say how many issues you scanned, how many had a triage, and whether the limit left any out.

## 1. Resolve the input — four modes

Each mode has a keyword. The user may name the keyword or just describe what they want; map what they say onto one or more of these, and remove duplicates. With no input at all, use `untriaged`.

- **`issues`** — an explicit list of issue numbers.
- **`label`** — open issues with the named label. Quote the label: the `::` in a GitLab scoped label is not shell-safe on its own.
- **`mine`** — open issues where the user is the author or the assignee. One filter per call, then union on number, because both forges AND their filters within a call.
- **`untriaged`** (the default) — open issues with no current triage (see §2).

**Limit:** `label`, `mine`, and `untriaged` stop at the 20 most recent issues that still need triage, to keep token use down. Go past 20 only when the user asks for more. An `issues` list is exact, so it has no limit.

Print the resolved batch: number, title, labels, and why it is in the batch. If the limit left issues out, say so. If the batch is empty, say so and stop.

## 2. Account for the ones already triaged

A triage comment holds the line `Agent Triage: #N` (see `triage-issue` §5). Find triage comments with one search, not by reading threads:

- **GitHub** — `gh search issues -R <owner>/<repo> --state open --match comments '"Agent Triage"' --json number`, then fetch the comments of those issues only.
- **GitLab** — `glab api "projects/<id>/search?scope=notes&search=Agent%20Triage&per_page=100"`, paged, where `<id>` may be the URL-encoded path (`rgnets%2Frxg`). It returns the comments themselves, from issues and MRs alike.

Do the rest in one script, so only its output reaches your context. Search matching is loose, so keep only comments on open issues that contain `Agent Triage: #`. Take the newest per issue, and print one row each: number, title, verdict, priority, difficulty, and why from the comment's table row, and the comment's date. A triage is current unless the issue was updated more than a minute after it.

Do not triage a current issue again. Take its row for the final table.

## 3. Ask everything up front — one round, then no more questions

The parallel agents never stop to ask. Get every decision before you launch anything:

- **Which ones** — all of §1 or a subset. This is also where the user can add an issue or drop one.
- **What to do with each result** — hold it in the report, or post it as a comment.
- **Labels** — none, unless the user names them here.
- **Worktree** — reuse or recreate the triage worktree, if it already exists.

Do not launch until all four are answered.

## 4. Fan out — one agent per issue

Run `git fetch origin` once in the main clone, and make the detached worktree from `triage-issue` §2 once. The agents only read, so they share it.

Launch the agents in a single message so they run concurrently. Cap it around ten at a time and queue the rest. Give each agent one issue number, the worktree path, and these rules:

- Follow `triage-issue` §1, §3, §4, and §5. Skip §2 and §6: never prompt and never post.
- Read code only inside the shared worktree.
- Return: the issue, the §5 report, the verdict, the priority and its source, the difficulty, the one-line why, the code areas involved, and any issues it may duplicate.

## 5. Compare

Read the results side by side. Do this before anything is posted, so that no comment needs a correction.

- **Duplicates** — where two issues in the batch cover the same thing, keep the one with better detail, or else the older one, and change the other's verdict to `duplicate`.
- **Overlap** — note issues that touch the same code, so they can be planned together.
- **Scale** — ratings must mean the same across the batch. Adjust any that are out of line with the rest, unless the priority came from a label or was stated on the issue.

## 6. Post

Apply the §3 answers under the rules in `triage-issue` §6. Post each comment with the operation `triage-issue`, in exactly the shape of `triage-issue` §5, so §2 finds it on the next run.

## End: report the table

One row per issue: number (link to the issue if available), title, verdict, priority, difficulty, posted or held, and the one-line why. Put `ready` first, then `needs-info`, then the rest. Within each group, **sort by priority descending (Critical to Low), then by difficulty ascending (Trivial to High)**, so the most important quick wins sit at the top.

Keep the already-triaged issues in the table, so the batch accounts for everything the mode resolved to. List any overlaps under the table. Then ask once whether to clean up the worktree with `git worktree remove <path>`.
