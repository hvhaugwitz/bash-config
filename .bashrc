# ~/.bashrc: executed by bash(1) for non-login shells

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# history
HISTSIZE=2500
HISTFILESIZE=-1
HISTCONTROL=ignoredups
HISTTIMEFORMAT="%FT%T%z "

PROMPT_COMMAND='history -a'

# set options
shopt -s checkwinsize
shopt -s globstar
shopt -s histappend
shopt -s histverify

# enable lesspipe
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# colored git status
function _my_git_ps1 {
    local exit=$?
    local staged=false dirty=false conflicts=false untracked=false
    local behind=0 ahead=0 stash=0

    if [ "$(git rev-parse --is-inside-work-tree 2> /dev/null)" == "true" ] ; then
        while IFS='' read -r line ; do
            if [[ $line =~ ^##\ ([[:alnum:]/._+-]+)\.\.\.([[:alnum:]/._+-]+) ]] \
                || [[ $line =~ ^##\ ([[:alnum:]/._+-]+[^.]{2})$ ]] \
                || [[ $line =~ ^##\ (HEAD)\ \(no\ branch\) ]] ; then
                branch="${BASH_REMATCH[1]}"
                upstream_branch="${BASH_REMATCH[2]}"
                commit="$(git rev-parse --short HEAD)"
                [[ $line =~ behind\ ([0-9]+) ]] && behind="${BASH_REMATCH[1]}"
                [[ $line =~ ahead\ ([0-9]+) ]] && ahead="${BASH_REMATCH[1]}"
            elif [[ $line =~ ^##\ No\ commits\ yet\ on\ ([[:alnum:]/._-]+)\.\.\.([[:alnum:]/._-]+) ]] \
                || [[ $line =~ ^##\ No\ commits\ yet\ on\ ([[:alnum:]/._-]+) ]] ; then
                branch="${BASH_REMATCH[1]}"
                upstream_branch="${BASH_REMATCH[2]}"
                commit='initial'
            else
                case "${line:0:2}" in
                    U?|?U|DD|AA) conflicts=true; break ;;
                    \?\?) untracked=true; break ;;
                    M?|A?|D?|R?|C?) staged=true ;;
                    ?M|?D) dirty=true ;;
                esac
            fi
        done < <(git status --porcelain=v1 --branch 2> /dev/null)
        stash="$(git stash list | wc -l)"

        if [ -n "${upstream_branch}" ] ; then
            if [ "${upstream_branch#origin/}" = "${branch}" ] ; then
                printf -- ' (\001\e[4;36m\002'
            else
                printf -- ' (\001\e[0;36m\002'
            fi
        else
            printf -- ' (\001\e[2;36m\002'
        fi
        printf -- '%s\001\e[0m\002@\001\e[0;35m\002%s' "${branch}" "${commit}"
        if ${conflicts} || ${untracked} || ${staged} || ${dirty} ; then
            printf -- ' '
            ${conflicts} && printf -- '\001\e[1;31m\002%s' '!'
            ${untracked} && printf -- '\001\e[1;34m\002%s' '?'
            ${staged} && printf -- '\001\e[1;32m\002%s' '⚑'
            ${dirty} && printf -- '\001\e[1;33m\002%s' '∴'
        fi
        if [ "${behind}" -gt "0" ] || [ "${ahead}" -gt "0" ] || [ "${stash}" -gt "0" ] ; then
            printf -- ' '
            [ "${behind}" -gt "0" ] && printf -- '\001\e[1;32m\002↓%s' "${behind}"
            [ "${ahead}" -gt "0" ] && printf -- '\001\e[1;31m\002↑%s' "${ahead}"
            [ "${stash}" -gt "0" ] && printf -- '\001\e[1;36m\002⚒%s' "${stash}"
        fi
        printf -- '\001\e[0m\002)'
    fi
    return ${exit}
}

# colored exit code
function _my_exit_code {
    local exit=$?
    if [ "${exit}" -gt "0" ] ; then
        printf -- '\001\e[1;31m\002'
    fi
    printf -- '%s\001\e[0m\002' "${exit}"
    return ${exit}
}

# set primary prompt
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    color_prompt=yes
else
    color_prompt=
fi

# last command's run time
# known limitations:
#   - '( sleep 5 )' shows 0s
#   - 'sleep 1 | sleep 2 | sleep 3' shows 3s

function timer_start {
    timer=${timer:-$SECONDS}
}

function timer_stop {
    timer_show=$((SECONDS - timer))
    unset timer
}

trap 'timer_start' DEBUG

PROMPT_COMMAND="${PROMPT_COMMAND:-:}; timer_stop"

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\u@\[\033[01;32m\]\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$(_my_git_ps1) \[\033[00;33m\]#\#\[\033[00m\] ${timer_show}s [$(_my_exit_code)]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w #\# ${timer_show}s [$?]\$ '
fi
unset color_prompt

# colored ls/grep
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# colored man
man() {
env \
LESS_TERMCAP_mb="$(printf '\e[1;32;40m')" \
LESS_TERMCAP_md="$(printf '\e[1;36;40m')" \
LESS_TERMCAP_me="$(printf '\e[0m')" \
LESS_TERMCAP_se="$(printf '\e[0m')" \
LESS_TERMCAP_so="$(printf '\e[1;44;33m')" \
LESS_TERMCAP_us="$(printf '\e[1;37;40m')" \
LESS_TERMCAP_ue="$(printf '\e[0m')" \
man "$@"
}

# alias definitions
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# source ~/.bashrc.local if exists
if [ -f ~/.bashrc.local ]; then
    . ~/.bashrc.local
fi
