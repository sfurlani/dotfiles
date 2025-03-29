
eval "$(/opt/homebrew/bin/brew shellenv)"

path+="$HOME/.fastlane/bin"
alias bef="bundle exec fastlane"
export FASTLANE_SKIP_UPDATE_CHECK=1

## Load rbenv into shell
path+=$HOME/.rbenv/bin
eval "$(rbenv init -)"

## Load pyenv into shell
export PYENV_ROOT=$HOME/.pyenv
path+=$PYENV_ROOT/bin
eval "$(pyenv init --path)"

## Fix Default Alert Animation Time (on restart)
defaults write com.apple.notificationcenterui bannerTime 300
## Fix iOS 17 on Xcode 14 (sans Xcode 15 beta)
# select `iPhone (core device)` instead of the other one
defaults write com.apple.dt.Xcode DVTEnableCoreDevice enabled

export LS_COLORS="di=1;36:ln=35:so=32:pi=33:ex=31:bd=37;46:cd=37;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
