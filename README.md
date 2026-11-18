# My Home Directory Dotfiles

This is my personal collection of dotfiles (and some miscellaneous files).

I don't include secrets, such as `.ssh` and `.gnupg`, because a lot of that is required to clone
this repo anyway, and it would make this little project harder to share. My git config is here,
though, with my name, email, and public signing key (see below).

Feel free to fork this repo and use for your own dotfiles.

## What gets installed

- Shell config for zsh and bash, with shared environment and aliases in `.commonenv` and
  `.commonrc`.
- Config for Vim, tmux, Alacritty, and mise.
- Git config: `.gitconfig`, plus `allowed_signers` and a global `ignore` in `.config/git`. The
  first two have my identity; change them first.
- Agent setup for Claude Code, Codex, and Antigravity: shared instructions in `.agents/AGENTS.md`,
  skills in `.agents/skills`, and Claude Code settings.
- Scripts in `.local/bin`, such as `pantheon`, a terminal UI that runs coding agents as a team.

For the details, look inside [`src/`](src). Its layout mirrors your home directory.

`./install` symlinks each top-level entry in `src/` into your home directory, after it deletes
(`rm -rf`) what is there. Some directories, such as `~/.config` and `~/.claude`, stay real
directories, and it symlinks their entries one at a time, so other files there stay.

## Installation

- Install git, Alacritty, VS Code, Vim, SQLite, and zsh.
- If you're not me, you should fork this repo first to make your own personal adjustments.
- Clone the repo somewhere. I always have a `~/git` directory, so I end up cloning to
  `~/git/dotfiles`. You can also track upstream to keep things up to date:

```sh
git clone git@github.com:<username>/dotfiles
cd dotfiles
git remote add upstream https://github.com/gregschmit/dotfiles
git fetch upstream
```

- If you're not me, change `src/.gitconfig` and `src/.config/git/allowed_signers` to match your
  setup (name, email, signing key), or delete them. Until you do, `./install` stops before it
  changes anything, unless `origin` is this repo.
- Run `./install` to install dotfiles.

> [!WARNING]
> `./install` deletes (`rm -rf`) each existing file or directory it replaces, including all of
> `~/.agents` and your Claude Code skills in `~/.claude/skills`. Back up anything you want to keep
> first, or take pieces one at a time (see below).

## Taking pieces one at a time

Symlink or copy single files instead of running `./install`. Symlinks follow the repo when you
pull; copies do not.

```sh
D=~/git/dotfiles/src  # where you cloned the repo
ln -s $D/.vimrc ~/
ln -s $D/.local/bin/shortcode ~/.local/bin/
ln -s $D/.agents/skills/git-forge ~/.claude/skills/
```
