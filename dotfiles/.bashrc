# in .bash_profile, source this file, like this:
#   [ -f ~/.bashrc ] && source ~/.bashrc

# Set bash mode to vi.
set -o vi

# Import system-wide completion scripts and local plugins.
if [ -d /usr/local/etc/bash_completion.d ]; then
  for f in /usr/local/etc/bash_completion.d/*; do source $f; done
fi
if [ -d ~/.bash_plugins ]; then
  for f in ~/.bash_plugins/*; do source $f; done
fi

# Editor
export EDITOR=vim

# Bash colors (need to wrap with 001 and 002 for PS1 length calculation).
BASHNOCOLOR='\001\033[0m\002'
BASHRED='\001\033[0;31m\002'
BASHGREEN='\001\033[0;32m\002'
BASHBRIGHTGREEN='\001\033[1;32m\002'
BASHBLUE='\001\033[1;34m\002'
BASHPURPLE='\001\033[0;35m\002'
BASHCYAN='\001\033[0;36m\002'
BASHYELLOW='\001\033[1;33m\002'

# Bash prompt.
ps_status_smiley() {
  status=$?
  if [ "$status" -eq 0 ]; then
    printf " $BASHGREEN:)$BASHNOCOLOR"
  else
    printf " $BASHRED:( $status$BASHNOCOLOR"
  fi
}
ps_git_branch() {
  branch=`git rev-parse --abbrev-ref HEAD 2> /dev/null`
  if [ -z $branch ]; then
    return
  elif [ "$branch" = "HEAD" ]; then
    branch="$BASHRED[detached]$BASHNOCOLOR"
  else
    branch="$BASHCYAN[$branch]$BASHNOCOLOR"
  fi
  printf " $branch"
}
ps_git_dirty() {
  if [ "$(git status --porcelain 2> /dev/null)" ]; then
    printf " ${BASHYELLOW}\xe2\x9c\x98${BASHNOCOLOR}"
  fi
}
if [ "$BASH_VERSINFO" -gt 3 ]; then
  PS1="$BASHRED\u$BASHNOCOLOR@$BASHBRIGHTGREEN\h$BASHNOCOLOR:$BASHBLUE\W$BASHNOCOLOR\$(ps_status_smiley)\$(ps_git_branch)\$(ps_git_dirty) $ "
fi

if [[ $- == *i* ]]; then
  bind '"\e[A": history-search-backward'
  bind '"\e[B": history-search-forward'
fi

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

# Sublime
PATH="$PATH:/Applications/Sublime Text.app/Contents/SharedSupport/bin"

# Google Cloud SDK
if [ -f "$HOME/google-cloud-sdk/path.bash.inc" ]; then source "$HOME/google-cloud-sdk/path.bash.inc"; fi
if [ -f "$HOME/google-cloud-sdk/completion.bash.inc" ]; then source "$HOME/google-cloud-sdk/completion.bash.inc"; fi

# Helper to collapse rails routes after a grep.
alias collapse_routes="sed -E 's/^[[:space:]]+([A-Z])/  _  \1/g' | sed -E 's/^(.)/  \1/g' | align"

# Helper to show license for all gems.
alias gem_licenses='for i in `gem list | cut -d" " -f1`; do printf "%38s `gem spec $i license`\n" $i; done'

# RVM
PATH="$PATH:$HOME/.rvm/bin"
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

# Java
PATH="/usr/local/opt/openjdk/bin:$PATH"

# Rust
. "$HOME/.cargo/env"

export PATH

