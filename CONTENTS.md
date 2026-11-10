# Contents

A guide to what is in this repo, for anyone who forks it and wants to take a few pieces without
running `./install`.

## What `./install` does

`install` walks `src/` and, for each top-level entry, runs `rm -rf ~/<entry>` and then symlinks
`~/<entry>` to the file or directory in this repo. Some directories are the exception: `install`
keeps `~/.config`, `~/.local/bin`, `~/.claude`, `~/.codex`, and `~/.gemini` (with
`~/.gemini/config`) as real directories and symlinks each entry inside them one at a time, so
other files there stay. If one of those is still a symlink from an older install, `install` removes
the symlink and stops; move anything you need out of the repo and run it again.

> [!WARNING]
> `install` deletes (`rm -rf`) each existing file or directory it replaces, with everything in it.
> That includes:
>
> - `~/.agents`, as a whole: shared agent instructions and any skills installed there.
> - `~/.claude/skills` (every Claude Code skill you have there), `~/.claude/CLAUDE.md`, and
>   `~/.claude/settings.json`. The rest of `~/.claude` stays.
> - `~/.codex/AGENTS.md`, `~/.gemini/AGENTS.md`, and `~/.gemini/config/skills`.
> - `~/.config/alacritty`, `~/.config/mise`, and `~/.config/nvim`, as whole directories, and any
>   file in `~/.local/bin` with the same name as a script here.
>
> It also replaces `~/.zshrc`, `~/.zshenv`, `~/.zprofile`, `~/.zlogin`, `~/.bashrc`,
> `~/.bash_profile`, `~/.profile`, `~/.tcshrc`, `~/.inputrc`, `~/.tmux.conf`, and `~/.vimrc`, and
> it puts `chess` in your home directory. Back up anything you want to keep first, or take pieces
> one at a time (see the end of this file).

The agent tools keep their runtime state (sessions, history, caches) in your home directory, not
in this repo.

## Agent setup

| Path | What it is |
| :--- | :--- |
| `src/.agents/AGENTS.md` | Shared agent instructions: coding guidelines, database migration rules, commit message style, a worktree convention (`<project>.worktrees/<branch>`, beside the main checkout), and a required attribution header for everything an agent posts or sends, above all on GitHub and GitLab. `src/.claude/CLAUDE.md`, `src/.codex/AGENTS.md`, and `src/.gemini/AGENTS.md` are symlinks to it. |
| `src/.agents/skills/` | Skills, shared with Claude through the `src/.claude/skills` symlink and with Antigravity through `src/.gemini/config/skills`. A `synced` subdirectory is ignored. |
| `src/.claude/settings.json` | Claude Code settings: permission allow rules, Opus at `xhigh` effort, theme, fullscreen TUI. It also skips the dangerous-mode permission prompt. |
| `src/.gemini/` | For the Antigravity CLI (`agy`), which reads `~/.gemini`: only the `AGENTS.md` and `config/skills` links. |

### Skills

The skills depend on the worktree convention and attribution header in `AGENTS.md` and on the
`shortcode` script. Take them together. Note that Claude Code has a built-in `/code-review`
command; rename this `code-review` skill if you install both.

## Scripts in `src/.local/bin`

| Script | What it is |
| :--- | :--- |
| `pantheon` | A terminal UI that runs Claude, Codex, Antigravity (`agy`), or Ollama agents as a team in a private tmux server, with a shared chat room and a tab for each agent. A mode sets the agents and the plan, such as `bakeoff` (several designs and builds, then pick the best) and `develop` (build, then review with one reviewer for each tool). Needs `uv` and `tmux`. Run `pantheon help` or read the docstring at the top of the file. Outside a clone of this repo, it checks GitHub for a newer version at most every 12 hours. |
| `shortcode` | Prints short IDs such as `K7R2` for code-review findings: Crockford base32, always starting with a letter, so forges do not autolink them as issue numbers. |
| `install_tool` | Runs the official install scripts for antigravity, claude, codex, mise, ollama, opencode, rustup, and uv. |
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
| `src/.tmux.conf` | Mouse on, vi keys, no escape delay, larger history, and windows shown as clickable tabs with a `+` button for a new one. |
| `src/.config/alacritty/alacritty.toml` | Starts fullscreen, sets `TERM`. |
| `src/.config/mise/config.toml` | Node LTS, Perl, Yarn 1, `gh`, `glab`, Neovim, ShellCheck, sshuttle, tmux, `align`, and `anycable-go`; uv venvs for Python; and version files for Ruby, Node, Python, and Java. |
| `src/.config/nvim/init.lua` | Empty. |

## Other files

| Path | What it is |
| :--- | :--- |
| `src/chess/` | Chess positions (PGN and FEN). |

## Taking pieces one at a time

Symlink or copy single files instead of running `install`. Symlinks follow the repo when you pull;
copies do not.

```sh
D=~/git/dotfiles/src  # where you cloned the repo
ln -s $D/.local/bin/shortcode ~/.local/bin/
ln -s $D/.agents/skills/git-forge ~/.claude/skills/
```
