mkdir -p "$HOME/.config/tmux"
rm -rf $HOME/.config/tmux/*

ln -s "$HOME/.dotfiles/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"
