# Contents

A guide to what is in this repo, for anyone who forks it and wants to take a few pieces without
running `./install`.

## What `./install` does

`install` walks `src/` and, for each top-level entry, runs `rm -rf ~/<entry>` and then symlinks
`~/<entry>` to the file or directory in this repo. Two directories are the exception: the contents
of `src/.config/` and `src/.local/bin/` are symlinked one entry at a time, so other files in
`~/.config` and `~/.local/bin` stay.

> [!WARNING]
> `install` deletes these directories, with everything in them, and replaces them with symlinks:
>
> - `~/.claude`: Claude Code settings, skills, plugins, memory, and session history.
> - `~/.codex`: Codex auth, config, and sessions.
> - `~/.gemini`: Gemini CLI auth, settings, and chats.
> - `~/.agents`: any skills installed there.
>
> It also replaces `~/.zshrc`, `~/.zshenv`, `~/.zprofile`, `~/.zlogin`, `~/.bashrc`,
> `~/.bash_profile`, `~/.profile`, `~/.tcshrc`, `~/.inputrc`, `~/.tmux.conf`, and `~/.vimrc`, and
> it puts `Brewfile`, `chess`, and `ubuntu_pkgs.txt` in your home directory. Back up anything you
> want to keep first, or take pieces one at a time (see the end of this file).

After an install, the agent tools keep their runtime state inside this repo's `src/.claude`,
`src/.codex`, and `src/.gemini`. Each has a `.gitignore` that ignores everything except the tracked
config files.

## Agent setup

| Path | What it is |
| :--- | :--- |
| `src/.agents/AGENTS.md` | Shared agent instructions: coding guidelines, database migration rules, commit message style, a worktree convention (`/tmp/agent-worktrees/<owner/repo>/<branch>`), and a required attribution header for agent comments on GitHub and GitLab. `src/.claude/CLAUDE.md`, `src/.codex/AGENTS.md`, and `src/.gemini/GEMINI.md` are symlinks to it. |
| `src/.agents/skills/` | Skills, shared with Claude through the `src/.claude/skills` symlink. A `synced` subdirectory is ignored. |
| `src/.claude/settings.json` | Claude Code settings: permission allow rules, effort level, theme, fullscreen TUI. |
| `src/.codex/config.toml` | Codex model, reasoning effort, and trusted project paths. |
| `src/.gemini/settings.json` | Gemini CLI auth type, UI, and session retention. |

### Skills

| Skill | What it does |
| :--- | :--- |
| `git-forge` | Picks `gh` (github.com) or `glab` (any other host) from the origin remote, and always passes `--repo` to `glab` so it never falls back to gitlab.com. Has working recipes for collecting all comments, posting multi-line comments with `glab api`, and inline suggestion blocks on both forges. The other skills use it. |
| `code-review` | Reviews the branch against primary (`branch`) or the working tree against `HEAD` (`changes`). Writes `CODE_REVIEW.md` with a verdict, a confidence and difficulty rating, findings grouped as Blocking, Should fix, and Nits, and a suggested commit message. Uses `shortcode` for finding IDs. |
| `review-branch` | Reviews one local branch or PR/MR in a worktree: collects comments, optionally merges primary, runs `code-review`, then posts the review or fixes the findings. |
| `review-branches` | Reviews a batch (`mine`, explicit branches or PR/MR numbers, or the `llm::pipeline-complete` label). Asks all questions up front, then runs one agent per target and reports a table. |
| `issue-to-branch` | Reads an issue, branches in a worktree, does the work, and asks before it commits, pushes, or opens a draft PR/MR. |

The skills depend on the worktree convention and attribution header in `AGENTS.md` and on the
`shortcode` script. Take them together. Note that Claude Code has a built-in `/code-review`
command; rename this `code-review` skill if you install both.

## Scripts in `src/.local/bin`

| Script | What it is |
| :--- | :--- |
| `pantheon` | A terminal UI that runs Claude, Codex, Gemini, or Ollama agents as a team in a private tmux server, with a shared chat room and a tab for each agent. A mode sets the agents and the plan, such as `bakeoff` (several designs and builds, then pick the best) and `develop` (build, then review with one reviewer for each tool). Needs `uv` and `tmux`. Run `pantheon help` or read the docstring at the top of the file. Outside a clone of this repo, it offers to update itself from this repo's `master`. |
| `shortcode` | Prints short IDs such as `K7R2` for code-review findings: Crockford base32, always starting with a letter, so forges do not autolink them as issue numbers. |
| `install_tool` | Runs the official install scripts for claude, codex, mise, ollama, opencode, rustup, and uv. |
| `echo_flask` | An HTTP server that prints each request's method, URL, headers, and body. Port 9999 by default. Runs with `uv`. |

## Shell

| Path | What it is |
| :--- | :--- |
| `src/.commonenv` | Environment for all bash and zsh shells, including non-interactive ones: `EDITOR`, `PATH` helpers that remove duplicates (`path_prepend`, `path_append`), and setup for Homebrew, mise shims, Cargo, opencode, and the Google Cloud SDK. Sets `BASH_ENV` so non-interactive bash loads it too. |
| `src/.commonrc` | Interactive setup for bash and zsh: aliases (Docker, Rails routes, gem licenses, DNS cache flush, macOS sleep) and completions for gcloud and uv. Note that `dockerclean` removes all containers and volumes. |
| `src/.zshenv`, `src/.zprofile` | Load `.commonenv`. `.zprofile` loads it again after macOS `path_helper` reorders `PATH`. |
| `src/.zshrc` | Prompt with git branch and a dirty marker, exit status on the right, vi mode. |
| `src/.bashrc`, `src/.bash_profile` | The same prompt and vi mode for bash, plus prefix history search on the arrow keys. |
| `src/.inputrc` | Vi mode for readline. |
| `src/.profile`, `src/.tcshrc`, `src/.zlogin` | Empty. They replace any existing file. |

## Editors and terminal

| Path | What it is |
| :--- | :--- |
| `src/.vimrc` | Line numbers, relative numbers, rulers at 81 and 101, and indent settings by file type. |
| `src/.tmux.conf` | Mouse on, vi keys, no escape delay, larger history. |
| `src/.config/alacritty/alacritty.toml` | Starts fullscreen, sets `TERM`. |
| `src/.config/mise/config.toml` | Node LTS and the Gemini CLI, uv venvs for Python, and version files for Ruby, Node, Python, and Java. |
| `src/.config/nvim/init.lua` | Empty. |

## Other files

| Path | What it is |
| :--- | :--- |
| `src/Brewfile` | Homebrew packages: core tools, forge CLIs, and libraries for Ruby projects. |
| `src/ubuntu_pkgs.txt` | The same list for apt; the install command is in its first line. |
| `src/chess/` | Chess positions (PGN and FEN). |

## Taking pieces one at a time

Symlink or copy single files instead of running `install`. Symlinks follow the repo when you pull;
copies do not.

```sh
D=~/git/dotfiles/src  # where you cloned the repo
ln -s $D/.local/bin/shortcode ~/.local/bin/
ln -s $D/.agents/skills/git-forge ~/.claude/skills/
```
