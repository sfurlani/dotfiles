# Basic Theme

# Autoload zsh add-zsh-hook and vcs_info functions (-U autoload w/o substition, -z use zsh style)
autoload -Uz vcs_info
# Run vcs_info just before a prompt is displayed (precmd)
add-zsh-hook precmd vcs_precmd

# Git Fetch each time?
zstyle ':vcs_info:*' check-for-changes true

# customize git appearance (✓⚠︎⚑)
zstyle ':vcs_info:git:*' unstagedstr "%{$fg[red]%}•%{$reset_color%}" # • or M or unstaged
zstyle ':vcs_info:git:*' stagedstr "%{$fg[green]%}+%{$reset_color%}" # + or S for staged 
zstyle ':vcs_info:git*+set-message:*' hooks git-colorized
+vi-git-colorized() {
    if [ -z "$(git status --porcelain)" ]; then
        hook_com[misc]="%{$fg_bold[grey]%}=%{$reset_color%}" # = or OK or clean
    elif [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]] && \
        git status --porcelain | grep -m 1 '^??' &>/dev/null
    then
        hook_com[misc]="%{$fg_bold[red]%}?%{$reset_color%}" # ? or U or untracked
    fi
    local branch=$(git branch --show-current)
    if [[ $branch == *"main"* || $branch == *"master"* ]]; then
        hook_com[branch]="%{$fg_bold[yellow]%}${branch}%{$reset_color%}"
    elif [[ $branch == *"develop"* || $branch == *"dev"* ]]; then
        hook_com[branch]="%{$fg[yellow]%}${branch}%{$reset_color%}"
    else
        hook_com[branch]="%{$fg_bold[grey]%}${branch}%{$reset_color%}"
    fi

}

# Set Git Info? Not sure why the colors here aren't working
zstyle ':vcs_info:*' formats "%s:[%b %m %u %c]"
zstyle ':vcs_info:*' actionformats "%s:[%b %m %u %c] %{$fg[red]%}(%a)%{$reset_color%}"

function vcs_precmd {
    vcs_info

    # Patch Components
    local user_prompt="%(!.%{$fg_bold[red]%}%n #.%{$fg[cyan]%}%n $)%{$reset_color%}"
    local time_prompt="%{$fg_bold[black]%}%D%t%{$reset_color%}"

    #if in user directory
    local path_color='yellow'
    [[ $PWD == "/Users"* ]] && path_color='blue'
    local path_prompt="%{$fg[${path_color}]%}%~%{$reset_color%}"

    # a 'return' isnt useful here, write to the PS variable instead
    if [[ ! -z "${vcs_info_msg_0_}" ]]; then
        PS1=$'\n'"${time_prompt}: ${path_prompt} ${vcs_info_msg_0_}"$'\n'"${user_prompt} "
    else
        PS1=$'\n'"${time_prompt}: ${path_prompt}"$'\n'"${user_prompt} "
    fi
}