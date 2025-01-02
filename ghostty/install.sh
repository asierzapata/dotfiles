mkdir -p "$HOME/.config/ghostty"
rm -rf $HOME/.config/ghostty/*
mkdir -p "$HOME/.config/ghostty/themes"

ln -s "$HOME/.dotfiles/ghostty/config" "$HOME/.config/ghostty/config"
ln -s "$HOME/.dotfiles/ghostty/themes/catpuccin-mocha" "$HOME/.config/ghostty/themes/catpuccin-mocha"
ln -s "$HOME/.dotfiles/ghostty/themes/catpuccin-latte" "$HOME/.config/ghostty/themes/catpuccin-latte"
