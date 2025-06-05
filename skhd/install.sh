if [ "$(uname -s)" == "Darwin" ]
then
	mkdir -p "$HOME/.config/skhd"
	rm -rf $HOME/.config/skhd/*
	cp -rf $HOME/.dotfiles/skhd/* $HOME/.config/skhd

	skhd --start-service
fi
