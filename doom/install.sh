mkdir -p "$HOME/.config/doom"

rm -rf $HOME/.config/doom/*

ln -s "$HOME/.dotfiles/doom/init.el" "$HOME/.config/doom/init.el"
ln -s "$HOME/.dotfiles/doom/config.el" "$HOME/.config/doom/config.el"
ln -s "$HOME/.dotfiles/doom/packages.el" "$HOME/.config/doom/packages.el"
ln -s "$HOME/.dotfiles/doom/snippets" "$HOME/.config/doom/snippets"

# Bootstrap Doom Emacs itself if it isn't already installed.
# We install to ~/.emacs.d (not ~/.config/emacs) because this setup exports
# XDG_CONFIG_HOME=$HOME/.dotfiles, which would make Emacs look for its XDG
# config under ~/.dotfiles/emacs. ~/.emacs.d is always found regardless.
if [ ! -d "$HOME/.emacs.d" ]; then
  git clone --depth 1 https://github.com/doomemacs/doomemacs "$HOME/.emacs.d"
  "$HOME/.emacs.d/bin/doom" install
else
  "$HOME/.emacs.d/bin/doom" sync
fi
