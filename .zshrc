#!/bin/zsh

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block, everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

################################################################################
# ALIASES
################################################################################

# Decode strings: `strace -f echo asdf | format-strace`
alias FormatStrace='grep --line-buffered -o '\''".\+[^"]"'\'' | grep --line-buffered -o '\''[^"]*[^"]'\'' | while read -r line; do printf "%b" $line; done | tr "\r\n" "\275\276" | tr -d "[:cntrl:]" | tr "\275\276" "\r\n"'
alias Pip2Upgrade='pip2 freeze --user | cut -d'=' -f1 | xargs pip2 install --user -U'
alias Pip3Upgrade='pip3 freeze --user | cut -d'=' -f1 | xargs pip3 install --user -U'

################################################################################
# FUNCTIONS (non-interactive usage)
################################################################################

# gitignore.io
Gitignore() { curl -L -s https://www.gitignore.io/api/$@ ; }

# use like `sleep 10 && Notify` to show notification that the task is done
Notify() {
  cur_desktop="$(wmctrl -d | grep ' \* ' | cut -d' ' -f1)"
  notify-send -i /usr/share/icons/breeze/emotes/22/face-smile.svg \
    "Command DONE on desktop ${cur_desktop}."
}

PassGen() {
  tr -dc a-zA-Z0-9 </dev/urandom | head -c$1 ; echo
}

Gitals() {
  gita ll "$1" | awk '{print $1}' | xargs -l gita ls
}

################################################################################
# STANDARD BASH-LIKE BEHAVIOR
################################################################################

# Word breaks (for ^B, ^F and like) like in bash
WORDCHARS="\"'><=;|&(:"

# Make Ctrl-W should delete the whole word to the space
backward-kill-until-space () {
  # Include in wordchars all special symbols, so they count as part of the word
  local WORDCHARS='/*?_-.[]~&;!#$%^(){}<>"=|:'
  zle backward-kill-word
}
zle -N backward-kill-until-space
bindkey '^W' backward-kill-until-space

# ^U shouldn't delete whole line
bindkey \^U backward-kill-line

# Disable autojump to menu on tab
unsetopt automenu
unsetopt autocd
unsetopt autopushd
# pushd allow current and one of the saved be the same
unsetopt pushd_ignore_dups
# Disable command spelling correction
unsetopt correct
# > and >> overwrites again
setopt clobber

# Remove _approximate from completion to disable corrections in autocomplete
zstyle ':completion:*' completer _complete _match

################################################################################
# OTHER
################################################################################

# Bigger history file
SAVEHIST=50000
HISTORY_IGNORE='(reset|cd ~|cd -|git status|top|ps aux|%|%1|%2|%3|&|pwd|exit|clear|bash|sh|dash|zsh|fg|bg|sync|ls|ls -ltr|ls -l)'

# Change path highlightning
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[path]='fg=cyan'

# Greatly improves performance with long lines
ZSH_HIGHLIGHT_MAXLENGTH=600

################################################################################
# AUTOCOMPLETE
################################################################################

# gcloud
if [[ -f "/usr/share/google-cloud-sdk/completion.zsh.inc" ]]; then
  source "/usr/share/google-cloud-sdk/completion.zsh.inc"
fi

# kubectl
if (command -v kubectl 1>/dev/null); then
  source <(kubectl completion zsh)
fi

# helm
if (command -v helm 1>/dev/null); then
  source <(helm completion zsh)
fi

# minikube
if (command -v minikube 1>/dev/null); then
  source <(minikube completion zsh)
fi

# terraform completion autogenerated by --install-autocomplete
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/bin/terraform terraform

# kustomize autogenerated completion
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/bin/kustomize kustomize

# molecule
if (command -v molecule 1>/dev/null); then
  eval "$(_MOLECULE_COMPLETE=source molecule)"
fi

################################################################################
# POST-ACTIONS
################################################################################

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ruby version manager
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"

# node version manager
export NVM_DIR="$([[ -z "${XDG_CONFIG_HOME-}" ]] && printf %s "$HOME/.nvm" || printf %s "$XDG_CONFIG_HOME/nvm")"
[[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"

# pyenv
command -v pyenv 1>/dev/null && eval "$(pyenv init -)"

if [[ "$PLACE" == "work-flant" ]]; then
  # flant ssh keys
  eval $( keychain --eval -q )
  /usr/bin/keychain -q --inherit any --confirm $HOME/.ssh/id_rsa
  /usr/bin/keychain -q --inherit any --confirm $HOME/.ssh/tfadm-id-rsa

  # trdl
  #source $(~/bin/trdl use werf 1.2 alpha)
fi
