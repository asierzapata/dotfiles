# Interactive pyenv init (registers shims + completion).
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init - zsh)"
fi
