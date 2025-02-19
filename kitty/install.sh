mkdir -p "$HOME/.config/kitty"
rm -rf $HOME/.config/kitty/*

ln -s "$HOME/.dotfiles/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
