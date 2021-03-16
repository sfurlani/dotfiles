#/bin/bash

# zplug
if [ -d $HOME/.zplug ]; then    
  source ~/.zplug/init.zsh
  zplug "~/.zsh", from:local 

  # plugins here
  zplug "plugins/zsh-syntax-highlighting", from:oh-my-zsh
  zplug "plugins/zsh-navigation-tools", from:oh-my-zsh
  zplug "plugins/git", from:oh-my-zsh
  zplug "plugins/docker", from:oh-my-zsh
  zplug "plugins/fzf", from:oh-my-zsh
  zplug "plugins/vi-mode", from:oh-my-zsh
  zplug "plugins/osx", from:oh-my-zsh, if:"[[ $OSTYPE == *darwin* ]]"
  
  zplug "denysdovhan/spaceship-prompt", use:spaceship.zsh, from:github, as:theme
  SPACESHIP_CHAR_SYMBOL='>'
  SPACESHIP_CHAR_SUFFIX=' '

  # Install plugins if there are plugins that have not been installed
  if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
      echo; zplug install
    fi
  fi

  # Then, source plugins and add commands to $PATH
  zplug load
else
  # Plugins
  plugins=(zsh-navigation-tools git history docker common-aliases git gitignore sublime osx)

  if [ -f ~/.zshrc_theme ]; then
    source ~/.zshrc_theme
  else
    # Set name of the theme to load.
    ZSH_THEME="theunraveler" 
  fi

fi
