# Fix GPG
export GPG_TTY=$(tty)

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Add Hooks
autoload -Uz add-zsh-hook colors && colors

# DEfault Editor (NeoVim)
# if (( $+commands[nvim] )) then    
#     export EDITOR='nvim'
#     alias vi="nvim"
#     alias vim="nvim"
# else
    export EDITOR='vim'
    alias vi="vim"
    alias vim="nocorrect vim"
# fi

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# Source your theme, or default to a simple one
if [ -f "$HOME/.p10k.zsh" ]; then
    # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
    ZSH_THEME="powerlevel10k/powerlevel10k"
    source "$HOME/.p10k.zsh"
elif [ -f "$HOME/.ps1.zsh" ]; then
    # echo "Can't find zsh theme: $HOME/.p10k.zsh - defaulting to PS1"
    source "$HOME/.ps1.zsh"
else 
    echo "Can't find a theme to load - defaulting"
    ZSH_THEME="robbyrussell"
fi

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Colored Terminal output
# export CLICOLOR=1
# export LSCOLORS=Gxfxcxdxbxhghdabagacad
export LS_COLORS="di=1;36:ln=35:so=32:pi=33:ex=31:bd=37;46:cd=37;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
HIST_STAMPS="yyyy-mm-dd"

# Zsh Completions
# if type brew &>/dev/null; then
#   FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
#   autoload -Uz compinit
#   # Only re-fresh the auto-completion file if old
#   if [ $(date +'%j') != $(stat -f '%Sm' -t '%j' ~/.zcompdump) ]; then
#     compinit
#   else
#     compinit -C
#   fi
# fi

# Delete brew's objectively worse git completion
# https://stackoverflow.com/a/77774933
# remove_conflicting_git_completions() {
#     local git_completion_bash="$HOMEBREW_PREFIX/share/zsh/site-functions/git-completion.bash"
#     local git_completion_zsh="$HOMEBREW_PREFIX/share/zsh/site-functions/_git"

#     [ -e "$git_completion_bash" ] && rm -f "$git_completion_bash"
#     [ -e "$git_completion_zsh" ] && rm -f "$git_completion_zsh"
# }

# # This needs to run every time since brew sometimes brings those files back
# remove_conflicting_git_completions

# Add Homebrew's site functions to fpath (minus git, because that causes conflicts)
# This will give you autocomplete for _other_ things you installed
# from brew (like `just`, or `exa`, or `k6`)
fpath=($HOMEBREW_PREFIX/share/zsh/site-functions $fpath)

# zstyle ':completion:*:*:git:*' script ~/.zsh/git-completion.bash
fpath=(~/.zsh $fpath)

autoload -Uz compinit && compinit

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git macos pyenv rbenv xcode fzf vi-mode vim-interaction common-aliases command-not-found zsh-navigation-tools jsontools zsh-syntax-highlighting)
# git command-not-found history docker common-aliases emoji osx xcode vi-mode vim-interaction zsh-navigation-tools jsontools  zsh-syntax-highlighting 

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# Cocoapods requires UTF-8
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.

# alias git="nocorrect git" 

if type gls &>/dev/null; then
  alias gls="nocorrect gls"
  alias l="gls -AFh --color --group-directories-first"
  alias ll="gls -AFho --color --group-directories-first"
else
  alias l="ls -AFh"
  alias ll="ls -AFho"
fi

export DEVELOPER=$HOME/Developer

path+=$HOME/bin
path+=$HOME/scripts
path+=$DEVELOPER/bin
path+=$DEVELOPER/scripts

path+=/opt/homebrew/bin

# Environment

path+="$HOME/.fastlane/bin"
alias bef="bundle exec fastlane"
export FASTLANE_SKIP_UPDATE_CHECK=1

alias ber="bundle exec rake"

## Load rbenv into shell
path+=$HOME/.rbenv/bin
eval "$(rbenv init -)"

## Load pyenv into shell
export PYENV_ROOT=$HOME/.pyenv
path+=$PYENV_ROOT/bin
eval "$(pyenv init --path)"

## Auto-login SSH Agent
#### Life360 ####

SSH_ENV=$HOME/.ssh/environment

function start_ssh_agent {
        ssh-agent | sed 's/^echo/#echo/' > ${SSH_ENV}
        chmod 0600 ${SSH_ENV}
        . ${SSH_ENV} > /dev/null
        ssh-add
        ssh-add ~/.ssh/id_github360
}

if [ -f "${SSH_ENV}" ]; then
        . ${SSH_ENV} > /dev/null
        ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
        start_ssh_agent
}
else
        start_ssh_agent
fi

# -------------------------------------------------------------------
# Fix issues with Bluetooth Sound on Mac OS X
# http://scott.dier.name/2009/10/osx-snow-leopard-a2dp.html
# -------------------------------------------------------------------

defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" 50

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh" || true

# -------------------------------------------------------------------
# Fix issue with Xcode printing stupid errors during testing on simulator
# -------------------------------------------------------------------

xcrun simctl spawn booted log config --mode "level:off"  --subsystem com.apple.CoreTelephony
