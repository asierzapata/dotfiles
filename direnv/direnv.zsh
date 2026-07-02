# Hook direnv into the shell so .envrc files load/unload automatically.
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi
