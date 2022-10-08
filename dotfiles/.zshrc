# Load and initialize modules.
autoload -Uz compinit && compinit -u  # Unsecure Ok for single-user systems.

# Set options.
setopt PROMPT_SUBST

# Helper to return formatted git info for `PROMPT`.
prompt_git_info() {
  # Setup branch display.
  branch=`git rev-parse --abbrev-ref HEAD 2> /dev/null`
  if [ -z $branch ]; then
    return
  elif [ "$branch" = "HEAD" ]; then
    branch='%%F{red}[detached]%%f'
  else
    branch="%%F{cyan}[$branch]%%f"
  fi

  # Setup dirty display.
  if [ "$(git status --porcelain 2> /dev/null)" ]; then
    dirty=" %%F{yellow}\xe2\x9c\x98%%f"
  fi

  printf " $branch$dirty"
}

precmd() {
  # Configure prompt.
  PROMPT="%F{red}%n%f:%F{blue}%.%f$(prompt_git_info) %F{green}%%%f "
}

# Configure right-side smiley/frown status prompt.
RPROMPT='%(?,%F{green}:),%F{red}%? :()%f'

# Use `vi`.
export EDITOR=vim
bindkey -v
bindkey "^?" backward-delete-char  # Fix backspace bug.

# Docker Helpers
alias dockervm='screen ~/Library/Containers/com.docker.docker/Data/vms/0/tty'
alias dockerclean='docker rm `docker ps -aq`; docker volume rm `docker volume ls -q`; docker imagerm `docker image ls -aq`;'

# Python Environments
PATH="~/.pyenv:$PATH"
eval "$(pyenv init -)"
activate() {
  for f in ./venv ./.venv ./env ./.env; do
    if [ -d $f ]; then
      . "$f/bin/activate"
      break
    fi
  done
}

# Perlbrew
source ~/perl5/perlbrew/etc/bashrc

# Node/NPM
export NODE_PATH=/usr/local/lib/node_modules

# Compiled overrides for mysql/openssl.
#export LDFLAGS="-L/usr/local/opt/mysql@5.7/lib -L/usr/local/opt/mysql-client@5.7/lib"
#export CPPFLAGS="-I/usr/local/opt/mysql@5.7/include -I/usr/local/opt/mysql-client@5.7/include"
export LDFLAGS="-L/usr/local/opt/openssl@1.1/lib"
export CPPFLAGS="-I/usr/local/opt/openssl@1.1/include"

# Postgres (Homebrew)
PATH="$PATH:/usr/local/opt/postgresql\@14/lib/postgresql\@14/"

# Google Cloud SDK
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then source "$HOME/google-cloud-sdk/path.zsh.inc"; fi
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then source "$HOME/google-cloud-sdk/completion.zsh.inc"; fi

# Helper to collapse rails routes after a grep.
alias collapse_routes="sed -E 's/^[[:space:]]+([A-Z])/  _  \1/g' | sed -E 's/^(.)/  \1/g' | align"

# Helper to show license for all gems.
alias gem_licenses='for i in `gem list | cut -d" " -f1`; do printf "%38s `gem spec $i license`\n" $i; done'

# RVM
PATH="$PATH:$HOME/.rvm/bin"
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

# Java
PATH="/usr/local/opt/openjdk/bin:$PATH"

# Rust
. "$HOME/.cargo/env"

export PATH

