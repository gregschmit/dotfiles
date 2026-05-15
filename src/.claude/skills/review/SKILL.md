---
name: review
description: Comprehensive technical review of code changes in a git repo. Modes - branch, staged, unstaged/changes. Optional focus hint after the mode.
---

Perform a comprehensive technical review of code changes in this git repository.

## Mode

Parse `$1` as the mode; remaining tokens in `$ARGUMENTS` are an optional focus hint.

- `branch` / empty / unrecognized → diff the current branch against the repo's primary branch. If already on primary, stop - nothing to review.
- `staged` → staged changes only
- `unstaged` or `changes` → unstaged working-tree changes

If `$1` is unrecognized, treat all of `$ARGUMENTS` as the focus hint. If the diff is empty, say so and stop.

## Review

Read the diff, then read surrounding code in each modified file.

Cover where applicable: correctness (logic, error handling, nil paths, concurrency, resource leaks), security (input validation, authn/authz, secrets, injection, SSRF), performance (complexity, N+1, blocking I/O, hot-path allocation), API design (signatures, backwards compat, error contracts), idioms and project conventions (use neighboring code as the reference, not generic style guides), tests (new-behavior coverage, edge cases, missing negatives), maintainability (clarity, duplication, lying comments, dead code), and ops (migrations, config, deploy ordering, rollback safety).

If a focus hint was supplied, weight that area heavily but still pass over the rest.

## Output

Group findings by severity: **Blocking**, **Should fix**, **Nits**. Cite `path:line` for each. Be specific - say what's wrong and why. If uncertain, say so and what you'd need to verify.

End with a one-paragraph verdict and a checklist of just the blocking items.
