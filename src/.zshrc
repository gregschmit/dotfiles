# Load and initialize modules.
autoload -Uz compinit && compinit -u  # Unsecure Ok for single-user systems.

# Set options.
setopt PROMPT_SUBST

# Return formatted git info for `PROMPT`.
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

# Determine if we are in a Python virtual environment.
env_info() {
  if [ "$VIRTUAL_ENV" ]; then
    echo "(env) "
  fi
}

precmd() {
  # Configure prompt.
  PROMPT="$(env_info)%F{red}%n%f:%F{blue}%.%f$(prompt_git_info) %(?,%F{green},%F{red})%%%f "
}

# Configure right-side smiley/frown status prompt.
RPROMPT='%(?,%F{green}:),%F{red}%? :()%f'

# Use `vi` mode.
bindkey -v
bindkey "^?" backward-delete-char  # Fix backspace bug.

# Google Cloud SDK
source_if_exists "$HOME/google-cloud-sdk/path.zsh.inc"
source_if_exists "$HOME/google-cloud-sdk/completion.zsh.inc"
