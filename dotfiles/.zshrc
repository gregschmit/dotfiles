# Load and initialize modules.
autoload -Uz compinit && compinit -u  # Unsecure Ok for single-user systems.

# Allow substitution in the prompt.
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
    PROMPT="%F{red}%n%f@%F{green}%m%f:%F{blue}%C%f$(prompt_git_info) %% "
}

# Configure right-side smiley/frown status prompt.
RPROMPT='%(?,%F{green}:%),%F{red}%? :()%f'