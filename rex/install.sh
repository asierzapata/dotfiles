#!/bin/sh
#
# Rex reads $XDG_CONFIG_HOME/rex/init.lua, which is this folder's init.lua
# since XDG_CONFIG_HOME is ~/.dotfiles. That file is machine-local and ignored
# by git: it loads the shared config in config.lua, and tools such as leaf add
# managed blocks to it. leaf rewrites its block while it runs, so keeping it
# out of the shared config keeps the repository clean.

REX_DIR="$HOME/.dotfiles/rex"
LOCAL="$REX_DIR/init.lua"

if [ ! -f "$LOCAL" ]; then
  cat > "$LOCAL" <<'EOF'
-- Machine-local Rex config, ignored by git. The shared config is config.lua;
-- managed blocks from tools such as leaf go below.
dofile(os.getenv("HOME") .. "/.dotfiles/rex/config.lua")
EOF
  echo "  Created $LOCAL"
fi

# Without XDG_CONFIG_HOME, Rex reads ~/.config/rex/init.lua instead.
mkdir -p "$HOME/.config/rex"
ln -sf "$LOCAL" "$HOME/.config/rex/init.lua"

# leaf's command palette plugin: a managed block in init.lua and the plugin
# in plugins/leaf. Rerunning refreshes both after a leaf upgrade.
if command -v leaf >/dev/null 2>&1; then
  leaf rex install
fi
