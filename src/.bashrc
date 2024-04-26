# in .bash_profile, source this file, like this:
#   [ -f ~/.bashrc ] && . ~/.bashrc

# Use `vi` mode.
set -o vi

# Import system-wide completion scripts and local plugins.
if [ -d /usr/local/etc/bash_completion.d ]; then
  for f in /usr/local/etc/bash_completion.d/*; do . $f; done
fi
if [ -d ~/.bash_plugins ]; then
  for f in ~/.bash_plugins/*; do . $f; done
fi

# Bash colors (need to wrap with 001 and 002 for PS1 length calculation).
NOCOLOR='\001\033[0m\002'
RED='\001\033[0;31m\002'
GREEN='\001\033[0;32m\002'
YELLOW='\001\033[0;33m\002'
BLUE='\001\033[0;34m\002'
MAGENTA='\001\033[0;35m\002'
CYAN='\001\033[0;36m\002'

# Bash prompt.
ps_status_smiley() {
  status=$?
  if [ "$status" -eq 0 ]; then
    printf " $GREEN:)$NOCOLOR"
  else
    printf " $RED:( $status$NOCOLOR"
  fi
}
ps_git_branch() {
  branch=`git rev-parse --abbrev-ref HEAD 2> /dev/null`
  if [ -z $branch ]; then
    return
  elif [ "$branch" = "HEAD" ]; then
    branch="$RED[detached]$NOCOLOR"
  else
    branch="$CYAN[$branch]$NOCOLOR"
  fi
  printf " $branch"
}
ps_git_dirty() {
  if [ "$(git status --porcelain 2> /dev/null)" ]; then
    printf " ${YELLOW}\xe2\x9c\x98${NOCOLOR}"
  fi
}
if [ "$BASH_VERSINFO" -gt 3 ]; then
  PS1="$RED\u$NOCOLOR@$MAGENTA\h$NOCOLOR:$BLUE\W$NOCOLOR\$(ps_status_smiley)\$(ps_git_branch)\$(ps_git_dirty) $ "
fi

if [[ $- == *i* ]]; then
  bind '"\e[A": history-search-backward'
  bind '"\e[B": history-search-forward'
fi

. ~/.commonrc
