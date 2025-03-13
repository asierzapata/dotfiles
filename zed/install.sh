mkdir -p "$HOME/.config/zed"

rm -rf $HOME/.config/zed/*

mkdir -p "$HOME/.config/zed/snippets"

ln -s "$HOME/.dotfiles/zed/settings.json" "$HOME/.config/zed/settings.json"
ln -s "$HOME/.dotfiles/zed/snippets/javascript.json" "$HOME/.config/zed/snippets/javascript.json"
