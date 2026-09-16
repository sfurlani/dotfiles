# Two-line prompt with asynchronous native Git status.
# Created by Stephen Furlani and Codex GPT-6 on 2026-09-16.

autoload -Uz add-zsh-hook
add-zsh-hook -d precmd vcs_precmd
add-zsh-hook -d precmd _gs1_git_precmd
add-zsh-hook -d preexec _gs1_git_preexec
if (( ${_gs1_fd:--1} >= 0 )); then
    zle -F $_gs1_fd
    exec {_gs1_fd}<&-
fi

# Branch names may contain shell syntax. Only expand Zsh prompt escapes.
setopt prompt_percent no_prompt_subst no_prompt_bang
typeset -g _gs1_git_segment='' _gs1_request_pwd='' _gs1_git_dir=''
typeset -gi _gs1_fd=-1 _gs1_generation=0 _gs1_request_generation=0
typeset -gi _gs1_async_enabled=0

# Find the nearest repository without spawning Git, including linked worktrees.
_gs1_find_git_dir() {
    emulate -L zsh
    local directory=$PWD pointer
    _gs1_git_dir=''
    if [[ -n $GIT_DIR ]]; then
        _gs1_git_dir=${GIT_DIR:a}
        return 0
    fi
    while true; do
        if [[ -d $directory/.git ]]; then
            _gs1_git_dir=$directory/.git
            return 0
        elif [[ -f $directory/.git ]]; then
            IFS= read -r pointer < "$directory/.git"
            pointer=${pointer#gitdir: }
            [[ $pointer == /* ]] || pointer=$directory/$pointer
            _gs1_git_dir=${pointer:a}
            return 0
        fi
        [[ $directory == / ]] && return 1
        directory=${directory:h}
    done
}

_gs1_style_branch() {
    emulate -L zsh
    local branch=$1 branch_color='%B%F{black}'
    if [[ $branch == *main* || $branch == *master* ]]; then
        branch_color='%B%F{yellow}'
    elif [[ $branch == *develop* || $branch == *dev* ]]; then
        branch_color='%F{yellow}'
    fi
    branch=${(V)branch}
    branch=${branch//\%/%%}
    REPLY="${branch_color}${branch}%f%b"
}

# All Git commands and status formatting run in this background worker.
_gs1_status_worker() {
    emulate -L zsh
    local output line xy branch='' action='' REPLY segment=''
    local -i staged=0 unstaged=0 untracked=0 conflicted=0
    local -a indicators=()
    if output=$(GIT_OPTIONAL_LOCKS=0 command git status --porcelain=v1 --branch 2>/dev/null); then
        for line in ${(f)output}; do
            if [[ $line == '## '* ]]; then
                branch=${${line#\#\# }%%...*}
                branch=${branch#No commits yet on }
                branch=${branch#Initial commit on }
                if [[ $branch == 'HEAD ('* ]]; then
                    branch=@$(command git rev-parse --short HEAD 2>/dev/null)
                fi
                continue
            fi
            xy=${line[1,2]}
            case $xy in
                '??') untracked=1 ;;
                '!!') ;;
                DD|AU|UD|UA|DU|AA|UU) conflicted=1 ;;
                *)
                    [[ $xy[1] != ' ' ]] && staged=1
                    [[ $xy[2] != ' ' ]] && unstaged=1
                    ;;
            esac
        done
        if [[ -d $_gs1_git_dir/rebase-merge || -d $_gs1_git_dir/rebase-apply ]]; then
            action=rebase
        elif [[ -f $_gs1_git_dir/MERGE_HEAD ]]; then
            action=merge
        elif [[ -f $_gs1_git_dir/CHERRY_PICK_HEAD ]]; then
            action=cherry-pick
        elif [[ -f $_gs1_git_dir/REVERT_HEAD ]]; then
            action=revert
        fi
        _gs1_style_branch "$branch"
        (( ! staged && ! unstaged && ! untracked && ! conflicted )) && indicators+=('%B%F{black}=%f%b')
        (( untracked )) && indicators+=('%B%F{red}?%f%b')
        (( unstaged )) && indicators+=('%F{red}•%f')
        (( staged )) && indicators+=('%F{green}+%f')
        (( conflicted )) && indicators+=('%F{red}!%f')
        segment="git:[${REPLY} ${(j: :)indicators} ]"
        [[ -n $action ]] && segment+=" %F{red}(${action})%f"
    fi
    # The parent is notified only after the complete result is ready.
    print -rn -- "$segment"$'\0'
}

_gs1_render() {
    local path_color=yellow git_segment=$_gs1_git_segment
    # Detection must not change the repository of an outstanding request.
    local _gs1_git_dir head branch REPLY
    local wait_01='%F{magenta}⧖%f' wait_02='%F{magenta}⧗%f'
    if [[ -z $git_segment ]] && (( _gs1_async_enabled )) && _gs1_find_git_dir; then
        git_segment="git:[ ${wait_01} ]"
        # HEAD supplies the branch immediately, without a process or index scan.
        if IFS= read -r head < "$_gs1_git_dir/HEAD" 2>/dev/null; then
            if [[ $head == 'ref: refs/heads/'* ]]; then
                branch=${head#ref: refs/heads/}
            elif [[ ${#head} -ge 40 && $head != *[^0-9a-f]* ]]; then
                branch=@${head[1,8]}
            fi
            if [[ -n $branch ]]; then
                _gs1_style_branch "$branch"
                git_segment="git:[${REPLY} ${wait_02} ]"
            fi
        fi
    fi
    [[ $PWD == /Users* ]] && path_color=blue
    PROMPT=$'\n''%B%F{black}%D %t%f%b: %F{'${path_color}'}%~%f'
    [[ -n $git_segment ]] && PROMPT+=" $git_segment"
    PROMPT+=$'\n''%(!.%B%F{red}%n #%f%b.%F{cyan}%n $%f) '
}

_gs1_request() {
    emulate -L zsh
    (( _gs1_async_enabled && _gs1_fd < 0 )) || return 0
    _gs1_find_git_dir || return 0
    _gs1_request_pwd=$PWD
    _gs1_request_generation=$_gs1_generation
    exec {_gs1_fd}< <(_gs1_status_worker)
    zle -F $_gs1_fd _gs1_complete
}

_gs1_complete() {
    emulate -L zsh
    local result=''
    IFS= read -r -u $_gs1_fd -d '' result
    zle -F $_gs1_fd
    exec {_gs1_fd}<&-
    _gs1_fd=-1
    if [[ $_gs1_request_pwd == "$PWD" ]] &&
       (( _gs1_request_generation == _gs1_generation )); then
        _gs1_git_segment=$result
    else
        # Discard results from before a directory change or another command.
        _gs1_git_segment=''
        if zle; then
            _gs1_request
        fi
    fi
    _gs1_render
    if zle; then
        zle reset-prompt
    fi
    return 0
}

_gs1_git_preexec() {
    (( ++_gs1_generation ))
    return 0
}

_gs1_git_precmd() {
    emulate -L zsh
    _gs1_git_segment=''
    # Consume completed work without waiting when a command ran outside ZLE.
    if (( _gs1_fd >= 0 )) && zselect -t 0 -r $_gs1_fd; then
        _gs1_complete
    fi
    _gs1_request
    _gs1_render
    return 0
}

# Environment probes without a terminal need no background prompt work.
if [[ -o interactive && -t 0 && -t 1 ]]; then
    zmodload zsh/zselect && _gs1_async_enabled=1
fi
add-zsh-hook preexec _gs1_git_preexec
add-zsh-hook precmd _gs1_git_precmd
_gs1_render
