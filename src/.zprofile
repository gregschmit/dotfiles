# Sourced for login zsh shells, AFTER `/etc/zprofile` runs `path_helper` (which
# prepends `/etc/paths` and `/etc/paths.d/*` and would otherwise push our
# entries behind system paths). Re-sourcing `.commonenv` restores our PATH
# ordering for login sessions.
[ -f "$HOME/.commonenv" ] && . "$HOME/.commonenv"
