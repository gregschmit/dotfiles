# in .bash_profile, source this file, like this:
#   [ -f ~/.bashrc ] && . ~/.bashrc

. ~/.common

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

# Google Cloud SDK
source_if_exists "$HOME/google-cloud-sdk/path.bash.inc"
source_if_exists "$HOME/google-cloud-sdk/completion.bash.inc"
