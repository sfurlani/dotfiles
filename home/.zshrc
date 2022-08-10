# -------------------------------------------------------------------
# Oh-My-ZSH Customization
# -------------------------------------------------------------------
# Custom Plugins:
#   zsh-autosuggestions
#   zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/INSTALL.md
# Custom Themes
#   Powerlevel9k https://github.com/Powerlevel9k/powerlevel9k
#   Powerlevel10k https://github.com/romkatv/powerlevel10k ??
# Custom Fonts
#   Nerd Fonts https://github.com/ryanoasis/nerd-fonts#option-4-homebrew-fonts
#
#   You'll need to install these separately after installing the dotfiles

# Only re-fresh the auto-completion file if old
autoload -Uz compinit
if [ $(date +'%j') != $(stat -f '%Sm' -t '%j' ~/.zcompdump) ]; then
  compinit
else
  compinit -C
fi


# # Debugging why it takes so long?
# DEBUG_ZSH=1

# if test $DEBUG_ZSH -gt 0; then
#     echo "TESTING ZSHRC STARTUPS"
#     zmodload zsh/zprof
# fi

# Autoload zsh add-zsh-hook and vcs_info functions (-U autoload w/o substition, -z use zsh style)
autoload -Uz add-zsh-hook colors && colors

# Enable substitution in the prompt.
setopt prompt_subst

# User configuration
export PATH="/usr/local/bin:/usr/local/sbin:$PATH"

# Local Environment Path
export PATH="$HOME/.local/bin:$PATH"

# Fastlane Configuration
export PATH="$HOME/.fastlane/bin:$PATH"
alias bef="bundle exec fastlane"

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Sourceable zsh files
if [ ! -d "$HOME/.zsh" ]; then
  mkdir ~/.zsh
fi

local zsh_theme="powerlevel9k"
# Source your theme, or default to a simple one
if [ -f "$HOME/.zsh/$zsh_theme.zsh-theme" ]; then
    source "$HOME/.zsh/$zsh_theme.zsh-theme"
else
    echo "Can't find zsh theme: $HOME/.zsh/$zsh_theme.zsh-theme - defaulting to PS1"
    source "$HOME/.zsh/ps1.zsh-theme"
fi

# Removes the User@ from prompt
DEFAULT_USER=`whoami`

# Uncomment the following line to change how often to auto-update (in days).
export UPDATE_ZSH_DAYS=5

# Uncomment the following line to disable auto-setting terminal title.
DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="yyyy-mm-dd"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git command-not-found history docker common-aliases emoji osx xcode vi-mode vim-interaction zsh-navigation-tools zsh-syntax-highlighting jsontools)
# node and npm plugins are looong
# add k
# git clone https://github.com/supercrabtree/k $ZSH_CUSTOM/plugins/k
# brew install coreutils
plugins+=(k)


# Check if using Darwin
if [[ $(uname) = 'Darwin'  ]]; then
    IS_MAC=1
fi

# Default Editor
if (( $+commands[nvim] )) then    
    export EDITOR='nvim'
    alias vi="nvim"
    alias vim="nvim"
else
    export EDITOR='vim'
    alias vim="nocorrect vim"
fi

# ZSH Source
source $ZSH/oh-my-zsh.sh

# Cocoapods requires UTF-8
export LANG=en_US.UTF-8

# Brew
alias brew_update_all="brew update && brew upgrade `brew outdated` --all"

# -------------------------------------------------------------------
# Aliases
# -------------------------------------------------------------------

# Git
alias git_pull_subdirectories='find . -type d -name .git -exec sh -c "cd \"{}\"/../ && pwd && git pull" \;'
alias git_push_subdirectories='find . -type d -name .git -exec sh -c "cd \"{}\"/../ && pwd && git push origin master" \;'
alias glsub="git_pull_subdirectories"
alias gpsub="git_push_subdirectories"
alias gptag="git push; git push --tags"
alias gitclean="git rm -r --cached .;ga ."
alias git='nocorrect git'

# General
alias c='clear'
alias cd..="cd .."
alias l="ls -Fo"
alias la="ls -AFho"
alias lp="ls -p"
alias kk="k -Ah"

alias conda-which="conda-env list"


# -------------------------------------------------------------------
# Functions
# -------------------------------------------------------------------

# Gitlogger
# Add current folder to ~/.gitlogger with name specified as argument 1
# For use with gitlogger.sh
function glog () {
    (echo "$1:`pwd`";grep -v "`pwd`$" ~/.gitlogger) | sort > ~/.gitlogger.tmp
    mv ~/.gitlogger.tmp ~/.gitlogger
}

# -------------------------------------------------------------------
# Sensitive Functions and Aliases
# -------------------------------------------------------------------
if [ -f ~/.zshrc_pushover  ]; then
    source ~/.zshrc_pushover
fi
if [ -f ~/.zshrc_tokens  ]; then
    source ~/.zshrc_tokens
fi

# -------------------------------------------------------------------
# Plugins (Moved to Oh-My-Zsh)
# -------------------------------------------------------------------


# -------------------------------------------------------------------
# Key Bindings (like-bash)
# -------------------------------------------------------------------

# bindkey "^?" backward-delete-char
# bindkey "^W" backward-kill-word 
# bindkey "^H" backward-delete-char      # Control-h also deletes the previous char
# bindkey "^U" backward-kill-line  

# -------------------------------------------------------------------
# Fix issues with Bluetooth Sound on Mac OS X
# http://scott.dier.name/2009/10/osx-snow-leopard-a2dp.html
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" 50
# -------------------------------------------------------------------

# added by Miniconda3 installer
export PATH="$HOME/Developer/miniconda3/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
#[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
alias nvm="unalias nvm; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"; nvm $@"
export PATH="/usr/local/opt/imagemagick@6/bin:$PATH"
export PATH="$HOME/Developer/flutter/bin:$PATH"

# Ruby Install Path (From Brew Install Ruby)
export PATH="/usr/local/opt/ruby/bin:$PATH"
export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"

# Prevents Fastlane from printing out THOUSANDS of lines of updates...
export FASTLANE_SKIP_UPDATE_CHECK=1

# Load rbenv automatically by appending
# the following to ~/.zshrc:

eval "$(rbenv init -)"
export PATH="/usr/local/opt/ruby@2.7/bin:$PATH"

export PATH="/usr/local/opt/openjdk/bin:$PATH"

# PyENV
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/shims:$PATH"
eval "$(pyenv init -)"

# NodENV
export PATH="$HOME/.nodenv/shims:$PATH"
eval "$(nodenv init -)"

# Hey, are you adding something? put it in ~/.zprofile so this doesnt have to reload all the plugins
