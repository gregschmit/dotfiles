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

Group review findings by severity: **Blocking**, **Should fix**, **Nits**. Cite `path:line` for each. Be specific - say what's wrong and why. If uncertain, say so and what you'd need to verify.

Give each finding a short code and lead with it: `[K7R2] path:line`. Run `shortcode <number of findings>` once and spend the codes it prints. Codes rather than counters because GitLab autolinks `#1` to issue 1, and because a code stays unambiguous when two agents review the same branch. If `shortcode` command is not found, make your own — 4 characters from `0123456789ABCDEFGHJKMNPQRSTVWXYZ`, the first one a letter.

Provide a small one-paragraph verdict.

End the verdict with a **merge-readiness confidence** — how sure you are that merging this as-is is safe — and one line of justification. A reader working through a stack of reviews uses this to pick what to take first.

- **High** — no blocking or should-fix findings, and the whole change fits in your head: comments/docs/formatting only, a mechanical rename, a self-evident one- or two-line fix, a dependency or config bump with no behavioral reach. You can see it is correct by reading it.
- **Medium** — you read every hunk and believe it's right, but something is unverified: tests not run, a caller not traced, a subsystem you know less well, or an open should-fix finding.
- **Low** — you cannot see the whole picture, or it plainly isn't ready. Any blocking finding lands here, as does a large or wide-reaching diff, risky territory (concurrency, authn/authz, migrations, money, data loss), behavior only a real run would prove, or unresolved review threads that change what "correct" means.

This rates readiness, not the author: Low means either you could not verify it or it needs work. Either way it is not the one to pick up first.

`[reviewed commit]` is `git rev-parse --short HEAD`, with `+dirty` appended in `changes` mode or whenever the working tree is dirty. It pins the review to the code it read, so a later reader — or a later agent deciding whether a re-review is due — can tell at a glance whether it still applies.

Print the output, and also save it to `./CODE_REVIEW.md` in markdown format. Wrap both the review and the commit message in their own `<details>` blocks so a copy-paste into a PR/MR comment stays tidy:

```
<details>

<summary>Code Review: [review mode] - [reviewed commit] - [datestamp]</summary>

[review content]

</details>

<details>

<summary>Suggested Commit Message</summary>

[commit message inside a fenced code block for easy copy]

</details>
```
