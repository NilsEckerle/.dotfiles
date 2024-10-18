all: important

important: zsh vim i3 wallpaper 

zsh:
	@echo "setting up zsh..."
	ln -s -f ~/.dotfiles/.zshrc ~/.zshrc

oh-my-zsh:
	curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh

vim:
	echo "setting up vim..."
	ln -s -f ~/.dotfiles/vimrc ~/.vimrc
	ln -s -f ~/.dotfiles/vim ~/.vim

neovim:
	@echo "setting up neovim..."
	ln -s -f ~/.dotfiles/nvim ~/.config/nvim

tmux:
	@echo "setting up tmux..."
	ln -s -f ~/.dotfiles/.tmux.conf ~/.tmux.conf
	ln -s -f ~/.dotfiles/tmux ~/.tmux
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
	
alacritty:
	@echo "setting up alacritty..."
	@if [ -d "$$HOME/.config/alacritty" ]; then \
		echo "old alacritty config renamed to alacritty.old"; \
		mv $$HOME/.config/alacritty $$HOME/.config/alacritty.old/; \
	fi
	ln -s -f ~/.dotfiles/alacritty ~/.config/alacritty

kitty:
	@echo "setting up kitty..."
	@if [ -d "$$HOME/.config/kitty" ]; then \
		echo "old kitty config renamed to kitty.old"; \
		mv $$HOME/.config/kitty $$HOME/.config/kitty.old/; \
	fi
	ln -s -f $$HOME/.dotfiles/kitty $$HOME/.config/kitty

yazi:
	@echo "setting up yazi..."
	@if [ -d "$$HOME/.config/yazi" ]; then \
		echo "old yazi config renamed to yazi.old"; \
		mv $$HOME/.config/yazi $$HOME/.config/yazi.old; \
	fi
	ln -s -f $$HOME/.dotfiles/yazi $$HOME/.config/yazi

switch_caps_to_esc:
	@echo "setting up caps to esc..."
	@uname_str=$(shell uname); \
	if [ "$$uname_str" = "Linux" ]; then \
		echo "setxkbmap -option caps:swapescape" >> ~/.profile; \
	fi

i3:
	@echo "setting up i3..."
	ln -s -f ~/.dotfiles/i3 ~/.config/

wallpaper:
	@echo "setting up wallpaper..."
	ln -s -f ~/.dotfiles/wallpaper/ ~/
