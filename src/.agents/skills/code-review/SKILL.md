---
name: code-review
description: Comprehensive technical review of code changes in a git repo, plus a suggested commit message. Modes - branch, changes. Optional focus hint after the mode.
---

# Code Review Skill

Perform a comprehensive technical review of code changes in this git repository, and draft a commit message alongside it.

## Mode

Parse `$1` as the mode; remaining tokens in `$ARGUMENTS` are an optional focus hint.

- `branch` / empty / unrecognized → diff the current branch against the repo's primary branch. If already on primary and the focus hint doesn't explain what to look at, then stop - nothing to review.
- `changes` → all working-tree changes vs. `HEAD`.

If `$1` is unrecognized, treat all of `$ARGUMENTS` as the focus hint. If the diff is empty, say so and stop.

## Review

Read the diff, then read surrounding code in each modified file.

Cover where applicable: correctness (logic, error handling, nil paths, concurrency, resource leaks), security (input validation, authn/authz, secrets, injection, SSRF), performance (complexity, N+1, blocking I/O, hot-path allocation), API design (signatures, backwards compat, error contracts), idioms and project conventions (use neighboring code as the reference, not generic style guides), tests (new-behavior coverage, edge cases, missing negatives), maintainability (clarity, duplication, lying comments, dead code), and ops (migrations, config, deploy ordering, rollback safety; a boolean DB column should be `NOT NULL` with a default unless it is genuinely a 3-state flag where `NULL` carries its own meaning).

If a focus hint was supplied, weight that area heavily but still pass over the rest.

## Commit Message

Always draft a commit message alongside the review, following the repo's commit conventions (terse, 50/72; body a short paragraph on the _why_).

- `branch` mode → the message for the branch as a whole (what a squash-merge would use). If the PR/MR description or a comment already supplies one (a fenced block reading like a commit message — ≤50-char subject, optional body), use it as-is.
- `changes` mode → the message for these changes as a single commit.

## Output

Print the output in this shape, and also save it to `./CODE_REVIEW.md`. The `<details>` blocks keep a copy-paste into a PR/MR comment tidy.

```
[verdict emoji] [verdict phrase]

[verdict paragraph]

| Confidence   | Difficulty   | Findings (B/S/N) | Why                      |
| :----------- | :----------- | :--------------: | :----------------------- |
| [confidence] | [difficulty] |   [b]/[s]/[n]    | [one-line justification] |

<details>

<summary>Code Review: [review mode] - [reviewed commit] - [datestamp]</summary>

[review content]

</details>

<details>

<summary>Suggested Commit Message</summary>

[commit message inside a fenced code block for easy copy]

</details>
```

### Verdict

A human reads the verdict first, to understand the review before opening it. Write it for a teammate who hasn't seen the diff. Not too technical.

- `[verdict emoji]` — 🟢, 🟡, or 🔴 for High, Medium, or Low **Confidence**.
- `[verdict phrase]` — the bottom line in a few words: what to do next. E.g. "Ready to merge", "Two small fixes first", "Not ready: the new login check can be skipped".
- `[verdict paragraph]` — two to four plain sentences: what the change does, how well it does it, and what stands in the way, if anything. Name the most important finding instead of listing them all.

### Summary table

One row, so the status reads at a glance without expanding the review. `Findings` counts Blocking/Should-fix/Nits from the review. `Why` is a short technical reason for both ratings, e.g. "comments only, no code paths touched".

**Confidence** — how sure you are that merging this as-is is safe. You should consider primarily code correctness and completeness, but also the size/scope of the changes, and how thoroughly they can be verified.

- **High** — you can account for every behavior change and nothing material is left in doubt. Two routes get here: the change is small enough to see correct by reading, or it is large but well covered — you traced the paths that matter, tests exercise the risky behavior and pass, and the design fits the surrounding code.
- **Medium** — you read every hunk and believe it's right, but something material is unverified: tests not run or missing for a risky path, a caller not traced, or a subsystem you know less well. An open should-fix finding also lands here.
- **Low** — you cannot account for the behavior, or it plainly isn't ready. Any blocking finding, risky territory you could not verify (concurrency, authn/authz, migrations, money, data loss), behavior only a real run would prove, or unresolved review threads that change what "correct" means.

**Difficulty** — how much work it would take to get this into a mergeable state. Weigh how complex the underlying problem is, how much of it is already done, what is left to finish, and how much testing the change demands. Judge the remaining work, not the size of the diff: a 2000-line mechanical rename with no findings is Trivial, while a 10-line authz change with a blocking bug and no test is High.

- **Trivial** — merge it as it stands, or after one obvious one-line fix. Existing tests are enough.
- **Low** — a few localized fixes, no design decisions. Existing tests cover it, or one new test does.
- **Medium** — a focused session: several findings, or one fix that isn't obvious. Needs a new test or a manual run to confirm, but the approach is settled.
- **High** — the approach is wrong or unfinished, risky behavior is untested, or someone has to make a call before this can be finished.

### Review block

`[review mode]` is `branch` or `changes`, and `[datestamp]` is today's date as `YYYY-MM-DD`. `[reviewed commit]` is `git rev-parse --short HEAD`, with `+dirty` appended in `changes` mode or whenever the working tree is dirty. It pins the review to the code it read, so a later reader — or a later agent deciding whether a re-review is due — can tell at a glance whether it still applies.

`[review content]` groups findings by severity: **Blocking**, **Should fix**, **Nits**. Cite `path:line` for each. Be specific - say what's wrong and why. If uncertain, say so and what you'd need to verify.

Give each finding a short code and lead with it: `[K7R2] path:line`. Run `shortcode <number of findings>` once and spend the codes it prints. Codes rather than counters because GitLab autolinks `#1` to issue 1, and because a code stays unambiguous when two agents review the same branch. If `shortcode` command is not found, make your own — 4 characters from `0123456789ABCDEFGHJKMNPQRSTVWXYZ`, the first one a letter.
