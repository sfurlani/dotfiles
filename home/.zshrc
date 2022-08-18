# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# Debugging why it takes so long?
local DEBUG_ZSH=0

# DEBUGGING ZSHRC
if test $DEBUG_ZSH -gt 0; then
    echo "TESTING ZSHRC STARTUPS"
    zmodload zsh/zprof
fi

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

# Cocoapods requires UTF-8
export LANG=en_US.UTF-8

# Only re-fresh the auto-completion file if old
autoload -Uz compinit
if [ $(date +'%j') != $(stat -f '%Sm' -t '%j' ~/.zcompdump) ]; then
  compinit
else
  compinit -C
fi

# Autoload zsh add-zsh-hook and vcs_info functions (-U autoload w/o substition, -z use zsh style)
autoload -Uz add-zsh-hook colors && colors

# User configuration
export PATH="/usr/local/bin:/usr/local/sbin:$PATH"

# Local Environment Path
export PATH="$HOME/.local/bin:$PATH"

# Fastlane Configuration
export PATH="$HOME/.fastlane/bin:$PATH"
alias bef="bundle exec fastlane"
export FASTLANE_SKIP_UPDATE_CHECK=1

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Sourceable zsh files
if [ ! -d "$HOME/.zsh" ]; then
  mkdir ~/.zsh
fi

# Source your theme, or default to a simple one
if [ -f "$HOME/.p10k.zsh" ]; then
    # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
    ZSH_THEME="powerlevel10k/powerlevel10k"
    source "$HOME/.p10k.zsh"
else
    echo "Can't find zsh theme: $HOME/.p10k.zsh - defaulting to PS1"
    source "$HOME/.zsh/ps1.zsh"
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
plugins=(git command-not-found history docker common-aliases emoji osx xcode vi-mode vim-interaction zsh-navigation-tools zsh-syntax-highlighting jsontools k evalcache virtualenv)
# node, nvm, nodenv, rbenv, pyenv are the one that take forever

# EvalCache (prevents env from taking so long)
export PATH="$HOME/.rbenv/bin:$PATH"
export PATH="$HOME/.pyenv/bin:$PATH"
export PATH="$HOME/.nodenv/bin:$PATH"

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
alias l="ls -AFho"
alias ll="ls -AFho"
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
# -------------------------------------------------------------------

defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" 50

# -------------------------------------------------------------------
# Environments (see plugin evalcache)
# -------------------------------------------------------------------

# added by Miniconda3 installer
export PATH="$HOME/Developer/miniconda3/bin:$PATH"

# NVM takes FOREVER to Load
export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Imagemagick
export PATH="/usr/local/opt/imagemagick@6/bin:$PATH"

# Flutter
export PATH="$HOME/Developer/flutter/bin:$PATH"

# Ruby Install Path (From Brew Install Ruby) (for Fastlane)
export PATH="/usr/local/opt/ruby/bin:$PATH"
export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"

# rbENV
export PATH="/usr/local/opt/ruby@2.7/bin:$PATH"
export PATH="/usr/local/opt/openjdk/bin:$PATH"
# eval "$(rbenv init -)"
_evalcache rbenv init -

# PyENV
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/shims:$PATH"
# eval "$(pyenv init -)"
_evalcache pyenv init -

# NodENV
export PATH="$HOME/.nodenv/shims:$PATH"
# eval "$(nodenv init -)"
_evalcache nodenv init -

# JavaSDK
export JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk-11.0.15.1.jdk/Contents/Home"

# DEBUGGING ZSHRC
if test $DEBUG_ZSH -gt 0; then
    zprof # bottom of .zshrc
fi
