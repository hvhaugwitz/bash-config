# ~/.bash_logout: executed by bash(1) when login shell exits

[ -e "${TTYHISTFILE}" ] && ( cat "${TTYHISTFILE}" >> "$HOME/.bash_history" && rm -f "${TTYHISTFILE}" )
HISTFILE="${HOME}/.bash_history"

# clear console
if [ "$SHLVL" = 1 ]; then
    [ -x /usr/bin/clear_console ] && /usr/bin/clear_console -q
fi
