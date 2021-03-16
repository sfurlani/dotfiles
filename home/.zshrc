# -------------------------------------------------------------------
# Oh-My-ZSH Customization
# -------------------------------------------------------------------
# Custom Plugins:
#   zsh-autosuggestions
# Custom Themes
#   Powerlevel9k
#
#   You'll need to install these separately after installing the dotfiles

# User configuration
export PATH="/usr/local/bin:/usr/local/sbin:$PATH"

# Fastlane Configuration
export PATH="$HOME/.fastlane/bin:$PATH"

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# POWERLEVEL9K_MODE='awesome-fontconfig'
ZSH_THEME="powerlevel9k/powerlevel9k"
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(root_indicator dir rbenv virtualenv anaconda vcs)
POWERLEVEL9K_DISABLE_RPROMPT=true
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX="\n"
POWERLEVEL9K_MULTILINE_SECOND_PROMPT_PREFIX="$ "
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="$ "
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=''
POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=''
POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=''
POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR=''

POWERLEVEL9K_STATUS_OK=false
POWERLEVEL9K_STATUS_CROSS=true
POWERLEVEL9K_STATUS_OK_FOREGROUND='white'
POWERLEVEL9K_STATUS_OK_BACKGROUND='none'
POWERLEVEL9K_STATUS_ERROR_FOREGROUND='red'
POWERLEVEL9K_STATUS_ERROR_BACKGROUND='none'

POWERLEVEL9K_TIME_FOREGROUND='white'
POWERLEVEL9K_TIME_BACKGROUND='none'

POWERLEVEL9K_DIR_DEFAULT_BACKGROUND='none'
POWERLEVEL9K_DIR_DEFAULT_FOREGROUND='yellow'
POWERLEVEL9K_DIR_HOME_BACKGROUND='none'
POWERLEVEL9K_DIR_HOME_FOREGROUND='blue'
POWERLEVEL9K_DIR_HOME_SUBFOLDER_BACKGROUND='none'
POWERLEVEL9K_DIR_HOME_SUBFOLDER_FOREGROUND='blue'

POWERLEVEL9K_VCS_CLEAN_FOREGROUND='green'
POWERLEVEL9K_VCS_CLEAN_BACKGROUND='none'
POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='yellow'
POWERLEVEL9K_VCS_MODIFIED_BACKGROUND='none'
POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='red'
POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND='none'

# Config Prompt before loading
# POWERLEVEL9K_PYTHON_ICON=$'\UE63C' #$'\U1F40D'
POWERLEVEL9K_ANACONDA_LEFT_DELIMITER="‹"
POWERLEVEL9K_ANACONDA_RIGHT_DELIMITER="›"
POWERLEVEL9K_ANACONDA_BACKGROUND="none"
POWERLEVEL9K_ANACONDA_FOREGROUND="cyan"

#ZSH_THEME="bullet-train/bullet-train"
#BULLETTRAIN_PROMPT_ORDER=(
  #dir
  #git
  #status
#)
#
#BULLETTRAIN_DIR_EXTENDED=2
#BULLETTRAIN_DIR_BG=black
#BULLETTRAIN_DIR_FG=blue
#
#BULLETTRAIN_GIT_COLORIZE_DIRTY=true
#BULLETTRAIN_GIT_COLORIZE_DIRTY_BG_COLOR=black
#BULLETTRAIN_GIT_COLORIZE_DIRTY_FG_COLOR=yellow
#BULLETTRAIN_GIT_BG=black
#BULLETTRAIN_GIT_FG=green
#BULLETTRAIN_GIT_DIRTY=" " # %F{red}✖%F{white} "
#BULLETTRAIN_GIT_CLEAN=" " # %F{green}•%F{white} "
#BULLETTRAIN_GIT_ADDED="✚"
#BULLETTRAIN_GIT_MODIFIED="•"
#BULLETTRAIN_GIT_DELETED="✖"
#BULLETTRAIN_GIT_UNTRACKED="?"

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
plugins=(git command-not-found history docker common-aliases composer emoji laravel laravel5 marked2 npm osx node vi-mode vim-interaction xcode zsh-navigation-tools)

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
fi

# ZSH Source
source $ZSH/oh-my-zsh.sh

# ssh
export SSH_KEY_PATH="~/.ssh/dsa_id"

if [[ $IS_MAC -eq 1  ]]; then
    # Start Screen Saver
    alias ss='open -a /System/Library/Frameworks/ScreenSaver.framework/Versions/A/Resources/ScreenSaverEngine.app'

    # Dash
    function dash() {
        open dash://$1
    }

    # Brew
    alias brew_update_all="brew update && brew upgrade `brew outdated` --all"

    # Git Directory
    alias gitdir="cd ~/Developer/Projects"

    # Fastlane
    export PATH="$HOME/.fastlane/bin:$PATH"

    export GPG_TTY=$(tty)
fi

# -------------------------------------------------------------------
# Aliases
# -------------------------------------------------------------------

# Git
alias git_pull_subdirectories='find . -type d -name .git -exec sh -c "cd \"{}\"/../ && pwd && git pull" \;'
alias git_push_subdirectories='find . -type d -name .git -exec sh -c "cd \"{}\"/../ && pwd && git push origin master" \;'
alias gls="git_pull_subdirectories"
alias gps="git_push_subdirectories"
alias gpt="git push; git push --tags"
alias gitclean="git rm -r --cached .;ga ."
alias git='nocorrect git'

# General
alias c='clear'
alias cd..="cd .."
alias l="ls -Fo"
alias la="ls -AFo"
alias lp="ls -p"
alias vim='nocorrect vim'

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
# Plugins
# -------------------------------------------------------------------
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


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

# added by Miniconda3 installer
export PATH="/Users/stephenf/Developer/miniconda3/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export PATH="/usr/local/opt/imagemagick@6/bin:$PATH"
export PATH="/Users/stephenf/Developer/flutter/bin:$PATH"

# Cocoapods requires UTF-8
export LANG=en_US.UTF-8

# AppCenter Environment Variables
# cab2a93e4c9df8067766918d4b460fa15e3aabd2
export UPSIDE_HOCKEY_KEY=cab2a93e4c9df8067766918d4b460fa15e3aabd2
export HOCKEY_APP_TOKEN_UPSIDE=cab2a93e4c9df8067766918d4b460fa15e3aabd2

# Ruby Install Path (From Brew Install Ruby)
export PATH="/usr/local/opt/ruby/bin:$PATH"
export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"

export QRCODE_PASSWORD=upside

# Prevents Fastlane from printing out THOUSANDS of lines of updates...
export FASTLANE_SKIP_UPDATE_CHECK=1
