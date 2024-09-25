mkdir -p "$HOME/.config/yabai"
rm -rf $HOME/.config/yabai/*
cp -rf $HOME/.dotfiles/yabai/* $HOME/.config/yabai

yabai --start-service