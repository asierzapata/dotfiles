mkdir -p "$HOME/.config/rex"

ln -sf "$HOME/.dotfiles/rex/init.lua" "$HOME/.config/rex/init.lua"

# leaf's command palette plugin. It lives in rex/plugins/leaf and is loaded
# from a managed block in init.lua; this refreshes both after a leaf upgrade.
if command -v leaf >/dev/null 2>&1; then
  leaf rex install
fi
