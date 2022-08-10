#!/bin/bash
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    # Linux
    sudo apt-get install -y --fix-missing \
	    software-properties-common \
	    build-essential \
	    git \
	    zsh \
	    curl \
	    tree \
	    ack-grep \
	    gnupg \
	    ranger

	sudo add-apt-repository -y ppa:neovim-ppa/stable
	sudo apt-get -y update
	sudo apt-get install -y --fix-missing neovim

	cat $(pwd)/home/.config/gpg/private.asc | gpg --batch --import || true
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
	# Homebrew
	if !(hash brew 2>/dev/null); then
		/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	fi

	if !(brew ls --versions git > /dev/null); then
		brew install git
	fi

	if !(brew ls --versions bash > /dev/null); then
		brew install bash
	fi

	if !(brew ls --versions zsh > /dev/null); then
		brew install zsh
	fi

	if !(brew ls --versions coreutils > /dev/null); then
		brew install coreutils
	fi

	if !(brew ls --versions neovim > /dev/null); then
		brew install neovim
	fi

	if !(brew ls --versions tree > /dev/null); then
		brew install tree
	fi

	if !(brew ls --versions ack > /dev/null); then
		brew install ack
	fi

	if !(brew ls --versions mosh > /dev/null); then
		brew install mosh
	fi
fi

# vim-plug
if [ ! -f "$HOME/.local/share/nvim/site/autoload/plug.vim" ]; then
  curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
  	https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

# nvm
if [ ! -d "$HOME/.nvm" ]; then
  mkdir ~/.nvm
fi

# zsh config files
if [ ! -d "$HOME/.zsh" ]; then
  mkdir ~/.zsh
fi

# move theme files over
cat $(pwd)/zsh_themes/ps1.zsh-theme > $HOME/.zsh/ps1.zsh-theme
cat $(pwd)/zsh_themes/powerlevel9k.zsh-theme > $HOME/.zsh/powerlevel9k.zsh-theme

if [ ! -f "$HOME/.nvm/nvm-exec" ]; then
	curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
fi

# Git Config
if [ -f "$(pwd)/home/.gitconfig_private" ]; then
	cat $(pwd)/home/.gitconfig_private >> $HOME/.gitconfig
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
	cat $(pwd)/home/.gitconfig_macos >> $HOME/.gitconfig
fi

# SSH
if [ ! -d "$HOME/.ssh" ]; then
	mkdir $HOME/.ssh
fi

chmod 700 $HOME/.ssh

if [ -f "$(pwd)/home/.ssh/config" ] || [[ "$OSTYPE" == "darwin"* ]]; then
  	rm -rf $HOME/.ssh/config
  	
  	if [ -f "$(pwd)/home/.ssh/config" ]; then
  		echo 'found config'
  		cat $(pwd)/home/.ssh/config > $HOME/.ssh/config
	fi
	if [[ "$OSTYPE" == "darwin"* ]]; then
		cat $(pwd)/home/.ssh/config_macos >> $HOME/.ssh/config
	fi
fi

if [ -f "$(pwd)/home/.ssh/id_rsa" ]; then
  	cp $(pwd)/home/.ssh/id_rsa $HOME/.ssh/id_rsa
  	chmod 600 $HOME/.ssh/id_rsa
	
	# Add Keys to macOS
	if [[ "$OSTYPE" == "darwin"* ]]; then
	ssh-add -K $HOME/.ssh/id_rsa
	fi

fi

if [ -f "$(pwd)/home/.ssh/id_rsa.pub" ]; then
  	cp $(pwd)/home/.ssh/id_rsa.pub $HOME/.ssh/id_rsa.pub
  	chmod 644 $HOME/.ssh/id_rsa.pub
fi

# oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
	echo "no zsh folder, cloning oh-my-zsh"
	git clone https://github.com/robbyrussell/oh-my-zsh.git $HOME/.oh-my-zsh

	if [ ! -n "$ZSH" ]; then
	    ZSH=$HOME/.oh-my-zsh
	fi

	if [ ! -f "$HOME/.zshrc" ]; then
		echo "Copying zsh"
		cp "$ZSH"/templates/zshrc.zsh-template $HOME/.zshrc
	fi

	sudo chsh -s $(which zsh) $(whoami)
fi

# fzf
if [ ! -d "$HOME/.fzf" ]; then
	git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
	$HOME/.fzf/install
fi

# symlink
sh symlink.sh

