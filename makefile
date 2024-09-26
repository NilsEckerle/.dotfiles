zsh:
	ln -s -f ~/.dotfiles/.zshrc ~/.zshrc

vim:
	ln -s -f ~/.dotfiles/vimrc ~/.vimrc
	ln -s -f ~/.dotfiles/vim ~/.vim

neovim:
	ln -s -f ~/.dotfiles/nvim ~/.config/nvim

tmux:
	ln -s -f ~/.dotfiles/.tmux.conf ~/.tmux.conf
	ln -s -f ~/.dotfiles/tmux ~/.tmux
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

alacritty:
	ln -s -f ~/.dotfiles/alacritty ~/.config/alacritty
