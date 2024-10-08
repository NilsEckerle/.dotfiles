all: zsh vim neovim tmux alacritty oh-my-zsh

zsh:
	@echo "setting up zsh"
	ln -s -f ~/.dotfiles/.zshrc ~/.zshrc

oh-my-zsh:
	curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh

vim:
	echo "setting up vim"
	ln -s -f ~/.dotfiles/vimrc ~/.vimrc
	ln -s -f ~/.dotfiles/vim ~/.vim

neovim:
	@echo "setting up neovim"
	ln -s -f ~/.dotfiles/nvim ~/.config/nvim

tmux:
	@echo "setting up tmux"
	ln -s -f ~/.dotfiles/.tmux.conf ~/.tmux.conf
	ln -s -f ~/.dotfiles/tmux ~/.tmux
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
	
alacritty:
	@echo "setting up alacritty"
	ln -s -f ~/.dotfiles/alacritty ~/.config/alacritty

switch_caps_to_esc:
	@uname_str=$(shell uname); \
	if [ "$$uname_str" = "Linux" ]; then \
		echo "setxkbmap -option caps:swapescape" >> ~/.profile; \
	fi

i3:
	ln -s -f ~/.dotfiles/i3 ~/.config/
