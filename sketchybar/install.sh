mkdir -p "$HOME/.config/sketchybar"
cp -rf $HOME/.dotfiles/sketchybar/* $HOME/.config/sketchybar

brew services restart sketchybar
curl -L https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v1.0.16/sketchybar-app-font.ttf -o $HOME/Library/Fonts/sketchybar-app-font.ttf