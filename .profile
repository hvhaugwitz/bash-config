# ~/.profile: executed by the command interpreter for login shells
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login exists

umask 077

# load timezone file if exists
if [ -f "$HOME/.timezone" ]; then
    . "$HOME/.timezone"
fi

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include $HOME/.bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi

    function histview {
        (
        history -c
        history -r "${TTYHISTFILE}"
        history | vim -n -i NONE -
        )
    }
    TTYHISTDIR="$HOME/.bash_history.d"
    [ -d "${TTYHISTDIR}" ] || mkdir "${TTYHISTDIR}"
    tty=$(tty)
    TTYHISTFILE=${TTYHISTDIR}/history${tty//\//_}
    unset tty
    HISTFILE=${TTYHISTFILE}
    history -r "${HOME}/.bash_history"
fi

# set PATH so it includes $HOME/bin
PATH="$HOME/bin:$PATH"

# source ~/.profile.local if exists
if [ -f ~/.profile.local ]; then
    . ~/.profile.local
fi
