#!/bin/bash

################################################################################
# ALIASES
################################################################################

alias grep='grep --color=auto'
alias ls='ls --color=auto'

alias git='hub'

# Decode strings: `strace -f echo asdf | format-strace`
alias format-strace='grep --line-buffered -o '\''".\+[^"]"'\'' | grep --line-buffered -o '\''[^"]*[^"]'\'' | while read -r line; do printf "%b" $line; done | tr "\r\n" "\275\276" | tr -d "[:cntrl:]" | tr "\275\276" "\r\n"'
alias pip2upgrade='pip2 freeze --user | cut -d'=' -f1 | xargs pip2 install --user -U'
alias pip3upgrade='pip3 freeze --user | cut -d'=' -f1 | xargs pip3 install --user -U'

################################################################################
# FUNCTIONS (non-interactive usage)
################################################################################

# gitignore.io
gi() { curl -L -s https://www.gitignore.io/api/$@ ; }

# use like `sleep 10 && nt` to show notification that the task is done
nt() {
  cur_desktop="$(wmctrl -d | grep ' \* ' | cut -d' ' -f1)"
  notify-send -i /usr/share/icons/breeze/emotes/22/face-smile.svg \
    "Command DONE on desktop ${cur_desktop}."
}

################################################################################
# FUNCTIONS (interactive usage)
################################################################################

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# add git repo information to prompt
if [ -e /usr/share/git/completion/git-prompt.sh ]; then
  source /usr/share/git/completion/git-prompt.sh
fi

# before any command is executed
__preCommand() {
  if [ -z "$AT_PROMPT" ]; then
    return
  fi

  unset AT_PROMPT

  tput sgr0
}

# after any command is executed
__postCommand() {
  exitCode="$?"
  AT_PROMPT=1
  GIT_PS1_SHOWDIRTYSTATE=1
  GIT_PS1_SHOWSTASHSTATE=1
  GIT_PS1_SHOWUNTRACKEDFILES=1
  GIT_PS1_SHOWUPSTREAM='auto'

  # generate prompt
  PS1="\$ \[${userNameColor}\]\u$eR \[${hostNameColor}\]\h$eR \[${pathColor}\]\w$eR \[${jobsColor}\]j\j$eR \[${exitCodeColor}\]e\[${exitCode}\]$eR \[${timeColor}\]\t$eR\[${branchColor}\]\$(__git_ps1 \" (%s)\")$eR\n\[${commandStringColor}\]"

  # don't execute on first prompt (when shell starts)
  if [ -n "$FIRST_PROMPT" ]; then
    unset FIRST_PROMPT
    return
  fi

  tput sgr0

  # sync history between terminals
  history -a
  history -c
  history -r
}

################################################################################
# BASH CONFIGURATION
################################################################################

case $TERM in
  linux)
    ;;
  screen)
    ;;
  *-256color)
    ;;
  *)
    export TERM="$TERM-256color"
    ;;
esac

trap "__preCommand" DEBUG

FIRST_PROMPT=1
PROMPT_COMMAND="__postCommand"

# History settings
HISTFILESIZE=50000
HISTCONTROL=ignorespace:ignoredups:erasedups #lines starting with space in the history.
HISTIGNORE='reset:cd ~:cd -:git status:top:ps aux:%:%1:%2:%3:&:ls:pwd:exit:clear:bash:sh:dash:fg:bg:sync:ls -ltr:ls -l'

# Disabled this, since we are already appending history at each prompt.
#HISTSIZE=5000
# append to the history file, don't overwrite it
#shopt -s histappend
unset HISTSIZE

# second "exit" needed if running any jobs
shopt -s checkjobs
# check the window size after each command and, if necessary, update the values of LINES and COLUMNS.
shopt -s checkwinsize
# save multi-line commands in history as single line
shopt -s cmdhist
# expand ** (recursive glob)
shopt -s globstar

# notify when jobs running in background terminate
set -o notify

################################################################################
# COLORS
################################################################################

aFgBlack='\e[30m'
aFgRed='\e[31m'
aFgGreen='\e[32m'
aFgYellow='\e[33m'
aFgBlue='\e[34m'
aFgMagenta='\e[35m'
aFgCyan='\e[36m'
aFgWhite='\e[37m'

aBgBlack='\e[40m'
aBgRed='\e[41m'
aBgGreen='\e[42m'
aBgYellow='\e[43m'
aBgBlue='\e[44m'
aBgMagenta='\e[45m'
aBgCyan='\e[46m'
aBgWhite='\e[47m'

aFgBlackI='\e[1;30m'
aFgRedI='\e[1;31m'
aFgGreenI='\e[1;32m'
aFgYellowI='\e[1;33m'
aFgBlueI='\e[1;34m'
aFgMagentaI='\e[1;35m'
aFgCyanI='\e[1;36m'
aFgWhiteI='\e[1;37m'

R='\e[0m'
sInvert='\e[7m'
sBold='\e[1m'
sUnderline='\e[4m'

eR='\[\e[0m\]'

case "$TERM" in
  # ansi colors for dark tty
  linux*)
    # prompt colors
    rightPromptColor=""
    pathColor="$aFgYellowI"
    jobsColor="$aFgGreenI"
    branchColor="$aFgYellowI"
    userNameColor="$aFgYellowI"
    hostNameColor="$aFgCyanI"
    exitCodeColor="$aFgMagentaI"
    timeColor="$aFgGreenI"
    commandStringColor="$aFgCyanI"
    ;;
  # ansi colors for light (primarily) or dark pts
  *)
    # prompt colors
    rightPromptColor=""
    pathColor="$aFgRedI"
    jobsColor="$aFgBlueI"
    hostNameColor="$aFgGreen"
    branchColor="$aFgGreen"
    userNameColor="$aFgMagentaI"
    exitCodeColor="$aFgCyan"
    commandStringColor="$aFgCyan"
    ;;
esac

# highlighting for `ls` (has to be in .bashrc, in .profile it doesn't work for some reason)
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors.ansi-universal && eval "$(dircolors -b ~/.dircolors.ansi-universal)" || eval "$(dircolors -b)"
fi

################################################################################
# AUTOCOMPLETION
################################################################################

# enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# heroku
#HEROKU_AC_BASH_SETUP_PATH=/home/user1/.cache/heroku/autocomplete/bash_setup\
#  && test -f $HEROKU_AC_BASH_SETUP_PATH && source $HEROKU_AC_BASH_SETUP_PATH
complete -C /usr/local/bin/kustomize kustomize
