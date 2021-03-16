#!/bin/bash

# NeoVim
if [ -d "$HOME/.config/nvim" ]; then
  	rm -rf ~/.config/nvim
fi

mkdir -p ~/.config/nvim
ln -s $(ls "`pwd`/home/.config/nvim/init.vim") ~/.config/nvim/init.vim

# Oh-My-Zsh
if [ -f "$HOME/.zshrc" ]; then
  	rm -rf ~/.zshrc
fi
ln -s $(ls "`pwd`/home/.zshrc") ~/.zshrc

if [ -f "$HOME/.zshrc_theme" ]; then
  	rm -rf ~/.zshrc_theme
fi
ln -s $(ls "`pwd`/home/.zshrc_theme") ~/.zshrc_theme

if [ -f "$HOME/.zshrc_private" ]; then
  	rm -rf ~/.zshrc_private
fi

if [ -f "`pwd`/home/.zshrc_private" ]; then
	ln -s $(ls "`pwd`/home/.zshrc_private") ~/.zshrc_private
fi

# git ignore
if [ -f "$HOME/.gitignore_global" ]; then
  	rm -rf ~/.gitignore_global
fi
ln -s $(ls "`pwd`/home/.gitignore_global") ~/.gitignore_global