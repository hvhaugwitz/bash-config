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
    PS1='${debian_chroot:+($debian_chroot)}\u@\[\033[01;32m\]\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] \[\033[00;33m\]#\#\[\033[00m\] ${timer_show}s [$(_my_exit_code)]\$ '
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
