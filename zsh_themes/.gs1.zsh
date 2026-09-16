#!/bin/zsh
# Two-line prompt with independent asynchronous Git and GitHub status.
# Created by Stephen Furlani and Codex GPT-6 on 2026-09-16.

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

# Shared by the worker and offline samples; sets REPLY to prompt markup.
_gs1_format_git() {
    emulate -L zsh
    local branch=$1 action=$6 segment=''
    local -i staged=$2 unstaged=$3 untracked=$4 conflicted=$5
    local -a indicators=()
    _gs1_style_branch "$branch"
    (( ! staged && ! unstaged && ! untracked && ! conflicted )) && indicators+=('%B%F{black}=%f%b')
    (( untracked )) && indicators+=('%B%F{red}?%f%b')
    (( unstaged )) && indicators+=('%F{red}•%f')
    (( staged )) && indicators+=('%F{green}+%f')
    (( conflicted )) && indicators+=('%F{red}!%f')
    segment="git:[${REPLY} ${(j: :)indicators} ]"
    [[ -n $action ]] && segment+=" %F{red}(${action})%f"
    REPLY=$segment
}

# All Git commands and status formatting run in this background worker.
_gs1_status_worker() {
    emulate -L zsh
    local output line xy branch='' action='' REPLY segment=''
    local -i staged=0 unstaged=0 untracked=0 conflicted=0
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
        _gs1_format_git "$branch" $staged $unstaged $untracked $conflicted "$action"
        segment=$REPLY
    fi
    # The parent is notified only after the complete result is ready.
    print -rn -- "$segment"$'\0'
}

# PR number/state/draft/review, then successful/pending/failed/skipped counts.
_gs1_format_gh() {
    emulate -L zsh
    local -a fields=("$1" "$2" "$3" "$4") indicators=()
    local -i passed=$5 pending=$6 failed=$7 skipped=$8
    local color=blue segment=''
    # Terminal states win, followed by draft, failing CI, and approval.
    if [[ $fields[2] == MERGED ]]; then
        color=135
    elif [[ $fields[2] == CLOSED ]]; then
        color=red
    elif [[ $fields[3] == true ]]; then
        color=8
    elif (( failed )); then
        color=yellow
    elif [[ $fields[4] == APPROVED ]]; then
        color=green
    fi
    if (( passed && ! pending && ! failed && ! skipped )); then
        indicators+=('%F{green}all ✔︎%f')
    elif (( passed )); then
        indicators+=("%F{green}${passed}✔︎%f")
    fi
    (( pending )) && indicators+=("%F{yellow}${pending}⧗%f")
    (( failed )) && indicators+=("%F{red}${failed}✘%f")
    (( skipped )) && indicators+=("%F{8}${skipped}╍%f")
    segment="gh:[%F{8}#$fields[1]%f %F{${color}}◆%f"
    (( ${#indicators} )) && segment+=" ${(j:・:)indicators}"
    segment+=' ]'
    REPLY=$segment
}

# One worker at a time; GitHub requests never hold up the Git result.
_gs1_gh_worker() {
    emulate -L zsh
    local metadata checks bucket segment='' REPLY
    local -a fields
    local -i passed=0 pending=0 failed=0 skipped=0
    if metadata=$(GH_PROMPT_DISABLED=1 command gh pr view \
        --json number,state,isDraft,reviewDecision,url \
        --jq '[.number, .state, .isDraft, (.reviewDecision // "" | if . == "" then "NONE" else . end), .url] | map(tostring) | join(" ")' 2>/dev/null); then
        fields=(${=metadata})
        if (( ${#fields} == 5 )) && [[ $fields[1] == <-> && $fields[5] == https://* ]]; then
            # gh returns nonzero for failed/pending checks even with valid JSON.
            checks=$(GH_PROMPT_DISABLED=1 command gh pr checks "$fields[5]" \
                --json bucket --jq 'map(.bucket) | join(" ")' 2>/dev/null)
            for bucket in ${=checks}; do
                case $bucket in
                    pass) (( ++passed )) ;;
                    pending) (( ++pending )) ;;
                    fail) (( ++failed )) ;;
                    cancel|skipping) (( ++skipped )) ;;
                esac
            done
            _gs1_format_gh "$fields[1]" "$fields[2]" "$fields[3]" "$fields[4]" \
                $passed $pending $failed $skipped
            segment=$REPLY
        fi
    fi
    print -rn -- "$segment"$'\0'
}

# Include HEAD so switching branches cannot display the previous branch's PR.
_gs1_gh_current_key() {
    emulate -L zsh
    local _gs1_git_dir head
    REPLY=''
    (( _gs1_async_enabled && $+commands[gh] )) || return 1
    _gs1_find_git_dir || return 1
    IFS= read -r head < "$_gs1_git_dir/HEAD" 2>/dev/null || return 1
    REPLY="$PWD:$_gs1_git_dir:$head"
}

_gs1_gh_request() {
    emulate -L zsh
    local REPLY
    if ! _gs1_gh_current_key; then
        _gs1_gh_segment='' _gs1_gh_key='' _gs1_gh_checked_at=0
        return 0
    fi
    if [[ $_gs1_gh_key != "$REPLY" ]]; then
        _gs1_gh_segment='' _gs1_gh_key=$REPLY _gs1_gh_checked_at=0
    fi
    (( _gs1_gh_fd < 0 )) || return 0
    (( EPOCHSECONDS - _gs1_gh_checked_at >= GS1_GH_REFRESH_SECONDS )) || return 0
    _gs1_gh_request_key=$REPLY
    _gs1_gh_request_generation=$_gs1_generation
    _gs1_gh_checked_at=$EPOCHSECONDS
    exec {_gs1_gh_fd}< <(_gs1_gh_worker)
    zle -F $_gs1_gh_fd _gs1_gh_complete
}

_gs1_gh_complete() {
    emulate -L zsh
    local result='' REPLY
    IFS= read -r -u $_gs1_gh_fd -d '' result
    zle -F $_gs1_gh_fd
    exec {_gs1_gh_fd}<&-
    _gs1_gh_fd=-1
    if _gs1_gh_current_key && [[ $_gs1_gh_request_key == "$REPLY" ]] &&
       (( _gs1_gh_request_generation == _gs1_generation )); then
        _gs1_gh_segment=$result
        _gs1_gh_key=$REPLY
        _gs1_gh_checked_at=$EPOCHSECONDS
    else
        _gs1_gh_segment='' _gs1_gh_checked_at=0
        if zle; then
            _gs1_gh_request
        fi
    fi
    _gs1_render
    if zle; then
        zle reset-prompt
    fi
    return 0
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
    if [[ -n $_gs1_gh_segment ]] && _gs1_gh_current_key && [[ $_gs1_gh_key == "$REPLY" ]]; then
        PROMPT+=" $_gs1_gh_segment"
    fi
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
    if (( _gs1_gh_fd >= 0 )) && zselect -t 0 -r $_gs1_gh_fd; then
        _gs1_gh_complete
    fi
    _gs1_gh_request
    _gs1_render
    return 0
}

# Direct execution is an offline preview; sourcing only installs the theme.
if [[ $ZSH_EVAL_CONTEXT == toplevel ]]; then
    if [[ $# != 1 || $1 != debug ]]; then
        print -ru2 -- "Usage: zsh ${0} debug"
        exit 2
    fi
    # These commands are defined only in the short-lived preview process.
    _gs1_debug_row() {
        emulate -L zsh
        setopt prompt_percent no_prompt_subst no_prompt_bang
        local label=$1 git_segment=$2 gh_segment=$3
        local display_path=${4:-'~/Developer/example'} path_color=${5:-blue}
        display_path=${display_path//\%/%%}
        local sample='%B%F{black}%D %t%f%b: '
        sample+="%F{${path_color}}${display_path}%f"
        [[ -n $git_segment ]] && sample+=" $git_segment"
        [[ -n $gh_segment ]] && sample+=" $gh_segment"
        print -r -- "$label"
        print -Pr -- "$sample"
        print -Pr -- '%F{cyan}%n $%f '
        print
    }
    _gs1_debug() {
        emulate -L zsh
        setopt prompt_percent no_prompt_subst no_prompt_bang
        local REPLY git_segment gh_segment row
        local -a values
        print -r -- '====== BEGIN SAMPLE ======'
        print -r -- 'GS1 offline samples — illustrative PR numbers and counts'
        print -r -- 'Colors follow your terminal palette; cancelled and skipped are combined.'
        print
        print -Pr -- '%F{8}██████ muted: PR number, draft, cancelled/skipped%f'
        print -Pr -- '%F{blue}██████ blue: ready for review, /Users paths%f'
        print -Pr -- '%F{yellow}██████ yellow: failed-checks PR diamond, pending checks, dev branches, paths outside /Users%f'
        print -Pr -- '%F{cyan}██████ cyan: username%f'
        print -Pr -- '%F{green}██████ green: approved, successful checks, staged files%f'
        print -Pr -- '%F{red}██████ red: closed, failed checks, unstaged files/conflicts%f'
        print -Pr -- '%B%F{red}██████ bold red: untracked files, root username%f%b'
        print -Pr -- '%B%F{black}██████ bold black: timestamp, ordinary branches, clean Git%f%b'
        print -Pr -- '%B%F{yellow}██████ bold yellow: main/master branches%f%b'
        print -Pr -- '%F{135}██████ violet: merged%f'
        print -Pr -- '%F{magenta}██████ magenta: Git loading indicators%f'
        print
        _gs1_format_git feature/example 0 0 0 0 ''
        git_segment=$REPLY
        # label | state | draft | review | pass | pending | fail | skip
        for row in \
            'Draft|OPEN|true|NONE|0|3|0|0' \
            'Ready for review|OPEN|false|NONE|9|0|0|0' \
            'Failed checks|OPEN|false|NONE|7|0|2|0' \
            'Approved|OPEN|false|APPROVED|9|0|0|0' \
            'Merged|MERGED|false|APPROVED|9|0|0|0' \
            'Closed|CLOSED|false|NONE|0|0|0|4' \
            'All check categories|OPEN|false|NONE|9|2|1|3' \
            'No checks (all zero counts omitted)|OPEN|false|NONE|0|0|0|0' \
            'Draft with failures (draft diamond wins)|OPEN|true|NONE|5|0|1|0' \
            'Approved with failures (failure diamond wins)|OPEN|false|APPROVED|5|0|1|0'; do
            values=("${(@s:|:)row}")
            _gs1_format_gh 12345 "$values[2]" "$values[3]" "$values[4]" \
                "$values[5]" "$values[6]" "$values[7]" "$values[8]"
            _gs1_debug_row "$values[1]" "$git_segment" "$REPLY"
        done
        _gs1_format_gh 12345 OPEN false NONE 9 2 0 0
        gh_segment=$REPLY
        _gs1_format_git develop/example 1 1 1 0 ''
        _gs1_debug_row 'Untracked + unstaged + staged, development branch' "$REPLY" "$gh_segment"
        _gs1_format_git main 1 1 0 1 merge
        _gs1_debug_row 'Merge conflict on main' "$REPLY" "$gh_segment"
        _gs1_debug_row 'Git loading, branch not yet known' 'git:[ %F{magenta}⧖%f ]' ''
        _gs1_style_branch feature/example
        _gs1_debug_row 'Branch known, Git status loading' "git:[${REPLY} %F{magenta}⧗%f ]" ''
        _gs1_format_git @abc12345 0 0 0 0 ''
        _gs1_debug_row 'Detached HEAD, no PR' "$REPLY" ''
        _gs1_debug_row 'Git repository without a PR (also when gh is unavailable)' "$git_segment" ''
        _gs1_debug_row 'Outside a Git repository (User Directory)' '' '' '~/Developer' blue
        _gs1_debug_row 'Outside a Git repository (System Directory)' '' '' '/tmp/local' yellow
        print -r -- '====== END SAMPLE ======'
    }
    _gs1_debug
    exit $?
fi

autoload -Uz add-zsh-hook
add-zsh-hook -d precmd vcs_precmd
add-zsh-hook -d precmd _gs1_git_precmd
add-zsh-hook -d preexec _gs1_git_preexec
if (( ${_gs1_fd:--1} >= 0 )); then
    zle -F $_gs1_fd
    exec {_gs1_fd}<&-
fi

if (( ${_gs1_gh_fd:--1} >= 0 )); then
    zle -F $_gs1_gh_fd
    exec {_gs1_gh_fd}<&-
fi

# Branch names may contain shell syntax. Only expand Zsh prompt escapes.
setopt prompt_percent no_prompt_subst no_prompt_bang
typeset -g _gs1_git_segment='' _gs1_request_pwd='' _gs1_git_dir=''
typeset -gi _gs1_fd=-1 _gs1_generation=0 _gs1_request_generation=0
typeset -gi _gs1_async_enabled=0
typeset -g _gs1_gh_segment='' _gs1_gh_key='' _gs1_gh_request_key=''
typeset -gi _gs1_gh_fd=-1 _gs1_gh_checked_at=0 _gs1_gh_request_generation=0
# Refresh on the next prompt after this interval; failures/no PR are cached too.
: ${GS1_GH_REFRESH_SECONDS:=60}
zmodload zsh/datetime

# Environment probes without a terminal need no background prompt work.
if [[ -o interactive && -t 0 && -t 1 ]]; then
    zmodload zsh/zselect && _gs1_async_enabled=1
fi
add-zsh-hook preexec _gs1_git_preexec
add-zsh-hook precmd _gs1_git_precmd
_gs1_render
