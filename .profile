test -e /etc/profile && . /etc/profile

################################################################################
# CUSTOM VARIABLES
################################################################################

# $PAGER needed for some programs
export EDITOR="nvim"
export FILE_MANAGER="ranger"
export GUI_EDITOR="kate"
export GUI_FILE_MANAGER="$TERM_EXEC -e $FILE_MANAGER"
export PAGER="less"
export TERM_EXEC="alacritty"
export VISUAL="$EDITOR"
export WEB_BROWSER="brave"

# password to access vaulted encrypted data
export ANSIBLE_VAULT_PASSWORD_FILE="$HOME/.vault_password"
export GOPATH="$HOME/go"
export PYENV_ROOT="$HOME/.pyenv"
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"

export DOTNET_CLI_TELEMETRY_OPTOUT=1
# for vim-gnupg
export GPG_TTY='tty'
# stupid virsh connects to a user qemu instance instead of system qemu by default
export LIBVIRT_DEFAULT_URI=qemu:///system

# export env variables from environment.d
env_dir="$HOME/.config/environment.d"
if [ -d "$env_dir" ] && [ -r "$env_dir" ] \
  && [ "$(ls -1 "$env_dir" | wc -l)" -gt 0 ]; then
  set -a
  for file in $env_dir/*.conf; do . "$file"; done
  set +a
fi

################################################################################
# UPDATING PATHS TO BINARIES AND CONFIGS
################################################################################

# base PATH
export PATH="$HOME/.local/bin:/usr/local/bin:/usr/local/sbin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/games:/usr/games"

# nix
if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then . $HOME/.nix-profile/etc/profile.d/nix.sh; fi

# snap
export PATH="/snap/bin:$PATH"

# umake
export PATH="$HOME/.local/share/umake/bin:$PATH"

# golang
export PATH="/usr/local/go/bin:$PATH"
export PATH="$GOPATH/bin:$PATH"

# pyenv
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# nodejs
export PATH="$HOME/.node_modules/bin:$PATH"

# ruby
export PATH="$(find ~/.gem/ruby/ -maxdepth 2 -mindepth 2 -name bin -type d 2>/dev/null | xargs printf '%s:')$PATH"

# rust
export PATH="$HOME/.cargo/bin:$PATH"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

# goland
if [ -e "$HOME/opt/goland/bin" ]; then
  export PATH="$HOME/opt/goland/bin:$PATH"
fi

# webstorm
if [ -e "$HOME/opt/webstorm/bin" ]; then
  export PATH="$HOME/opt/webstorm/bin:$PATH"
fi

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

export PATH="$HOME/bin:$PATH"
