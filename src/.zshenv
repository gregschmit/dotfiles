# Sourced for ALL zsh invocations (login/non-login/interactive/scripts). Loads
# `.commonenv` so non-interactive shells see the same PATH and env as
# interactive sessions.
[ -f "$HOME/.commonenv" ] && . "$HOME/.commonenv"
