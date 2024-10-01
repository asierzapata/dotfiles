mkdir -p "$HOME/.config/zed"
rm -rf $HOME/.config/zed/*

ln -s "$HOME/.dotfiles/zed/settings.json" "$HOME/.config/zed/settings.json"
