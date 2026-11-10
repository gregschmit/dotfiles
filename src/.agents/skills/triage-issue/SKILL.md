---
name: triage-issue
description: Evaluate an issue. Use when asked to triage one issue.
---

# Triage an issue

Follow `git-forge` for `gh` vs `glab` and the glab `--repo` rule. Triage reads code and changes none of it.

## 1. Read the issue

Get the title, body, labels, state, and every comment. Follow links to related issues and PRs/MRs.

## 2. Get the code

Judge the issue against primary as it is now. Run `git fetch origin`. If this checkout is not at `origin/<primary>`, read from a detached worktree: `git worktree add --detach <project>.worktrees/triage origin/<primary>`. If you reuse one, move it to `origin/<primary>` first.

## 3. Investigate

- **What is asked.** Say the problem or request in your own words.
- **Is it real.** Find the code involved. For a bug, trace whether it can happen. For a feature, check whether it exists already.
- **Is it covered.** Search open and closed issues and open PRs/MRs, with a few keywords.
- **What it takes.** Note the code to change and the riskiest part.

## 4. Rate it

Three properties, the same for every issue, so that issues can be compared.

**Verdict** — what should happen next.

- `ready` — clear and valid; someone could start now.
- `needs-info` — cannot be judged or built without answers. List the questions.
- `duplicate` — another issue covers it. Name that issue.
- `done` — the code already does this. Cite it.
- `decline` — not a bug, or not worth doing. Say why.

**Priority** — how much it matters: Critical, High, Medium, or Low. A priority label, or a priority stated on the issue, wins. Otherwise infer it from who the issue affects, how badly, and whether there is a workaround. Data loss, security, and outages rate highest. Record the source: `label`, `stated`, or `inferred`.

**Difficulty** — how much work it would take. An educated guess is fine.

- **Trivial** — a one-line or obvious fix.
- **Low** — a few localized changes, no design decisions.
- **Medium** — a focused session, or a fix that is not obvious.
- **High** — cross-cutting or risky, or someone must make a design call first.

## 5. Report

Print the triage in this shape. A human reads the top first, so write it for a teammate who has not seen the issue.

```
[emoji] [verdict phrase]

[two to four plain sentences: what is asked, what you found, what should happen next]

| Verdict   | Priority              | Difficulty   | Why               |
| :-------- | :-------------------- | :----------- | :---------------- |
| [verdict] | [priority] ([source]) | [difficulty] | [one-line reason] |

<details>

<summary>Triage: #[number] - [commit] - [datestamp]</summary>

[what you found, with `path:line` citations; related issues; a suggested approach; open questions]

</details>
```

`[emoji]` is 🟢 for `ready`, 🟡 for `needs-info`, 🟠 for `duplicate`, 🔴 for `decline`, and 🟣 for `done`. `[commit]` is the short SHA of the primary you read, and `[datestamp]` is today's date as `YYYY-MM-DD`.

## 6. Post — confirm first

Show the user the comment and ask before posting it. Post it as an issue comment, with the attribution header from AGENTS.md and the operation `triage-issue`.

Never close, edit, or assign the issue: flag a duplicate and let a human close it. Add a label only if the user names it, and that includes `llm::` labels, which start automated pipelines on some projects.

## End: report the worktree

If you made a worktree, print its path.
