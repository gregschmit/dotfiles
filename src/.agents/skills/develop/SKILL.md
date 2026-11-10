---
name: develop
description: Use only when asked to develop with this skill in particular, or when asked to do a bakeoff, or build several competing implementations.
argument-hint: "[bakeoff] <task>"
---

# Develop

Build a change in the current checkout in review rounds, and leave it uncommitted. The caller owns the branch, the commits, and any forge work.

`$ARGUMENTS` is the task; if there is none, ask for one. Run a Bakeoff first only when the request asks for one, or for several implementations ("do 3 implementations"). Then always run the Rounds.

## Tools

Bakeoff developers and all reviewers run as headless CLIs, at high effort unless the user asks for another level. Run each in its worktree, with a 30-minute limit.

| Tool     | Command                                                                                 |
| :------- | :-------------------------------------------------------------------------------------- |
| `claude` | `claude -p "$PROMPT" --permission-mode acceptEdits --effort high`                       |
| `codex`  | `codex exec -s workspace-write -c model_reasoning_effort=high "$PROMPT"`                |
| `agy`    | `agy -p "$PROMPT" --mode accept-edits --effort high`                                    |
| ollama   | `ollama launch claude --model <model> -y -- -p "$PROMPT" --permission-mode acceptEdits` |

These flags keep each tool's checks on. Turn them off only if the user asks. If `agy` refuses `--effort` (it takes it only for Gemini models), run it without.

**The reviewer never shares the developer's tool and model.** Take the first of `claude`, `codex`, `agy` on `PATH` that differs from the developer in tool or model, so `codex` reviews `claude`, and `claude` reviews the rest. If none differs, use a fresh subagent, and say so in the report.

## Bakeoff (optional, before the Rounds)

Several contenders each build the change, with their own rounds. The best build, plus the good parts of the others, becomes the starting point for the Rounds. The working tree must be clean; if it is not, stop and ask.

1. **Contenders.** Take the tools or ollama models the user names. Else take the first N of `claude`, `codex`, `agy` on `PATH`, where N is the number asked for (default 3). With fewer than two, say so and stop.
2. **Worktrees.** Make one detached worktree per contender, one at a time, because `git worktree add` takes a lock: `git worktree add --detach <project>.worktrees/bakeoff/<slug>/<contender> HEAD`.
3. **Tracks.** Start one subagent per contender, all at once. Each runs the Rounds in its worktree, with its contender as the developer and a reviewer chosen by the rule above. Each developer turn is a fresh CLI run. The first gets the task, "Follow this repo's conventions and test what you can", and "Do not commit". Later ones also get the review, and must say which findings they fixed and which they refused, and why. Add no ideas of your own, so the builds stay independent. Each subagent returns its worktree, how its rounds ended, and its last review.
4. **Pick.** Judge the code and the tests, not the reports. In each worktree, read the diff (`git add -A -- . ':(exclude)CODE_REVIEW.md' && git diff --cached`) and run the tests yourself. Pick on correctness, fit with neighboring code, and simplicity. List what the other builds do better that is worth taking. If no build is worth keeping, say why and stop.
5. **Merge.** Bring the pick into the current checkout with `git -C <worktree> diff --cached --binary | git apply`, then port the parts you listed. Start the Rounds at step 2, with you as the developer.

## Rounds

You are the developer, and the reviewer comes from the rule above. If the working tree is dirty when you start, and no bakeoff ran, ask whether those changes belong to the task.

1. **Build.** Follow repo conventions (`CLAUDE.md` / `AGENTS.md`, neighboring code). Add tests for new behavior and run what you can. Ask the user before scope expansions the task does not describe.
2. **Review.** Run the reviewer fresh each round, so it does not inherit the developer's reasoning. Its prompt: the task, the findings refused so far with their reasons, and "Invoke the `code-review` skill in `changes` mode. Do not change code." It leaves the review in `./CODE_REVIEW.md`.
3. **Respond.** Fix or refuse each Blocking and Should-fix finding. Refuse only when you can say why the finding is wrong or out of scope. Nits are optional and never hold the rounds open.
4. **Repeat** from step 2, until one of these ends the rounds:
   - **Approved** — the review has no Blocking or Should-fix findings.
   - **Refused** — every Blocking and Should-fix finding was refused, so the code did not change this round.
   - **Cap** — the fifth review still has Blocking or Should-fix findings.

## End: report

Print how the Rounds ended, the review file, and anything the user must judge, e.g.

    Outcome: approved after 2 reviews by codex
    Review:  ~/git/rgnets/rxg.worktrees/gns/new-thing/CODE_REVIEW.md
    Refused: [K7R2] out of scope: the task excludes the old API
    Checks:  bin/rails test (passed)

After a bakeoff, also report each track (contender, reviewer, how its rounds ended), the pick and why, and what you took from the others. Ask once whether to remove the bakeoff worktrees.

`CODE_REVIEW.md` is not part of the change. Never commit it.
