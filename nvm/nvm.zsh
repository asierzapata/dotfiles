# Interactive-only: loading nvm.sh is slow, and `nvm` is a shell function that
# only makes sense in an interactive shell anyway.
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

if command -v nvm >/dev/null 2>&1; then
  nvm use default >/dev/null
fi
