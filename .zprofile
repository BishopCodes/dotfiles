
# Workbrew
# export HOMEBREW_BREW_WRAPPER=/opt/workbrew/bin/brew
# export HOMEBREW_FORCE_BREW_WRAPPER=/opt/workbrew/bin/brew

# Homebrew reference using workbrew needs the disable option as well
eval "$(/opt/workbrew/bin/brew shellenv)"

# SDKMan
# export SDKMAN_DIR=$(brew --prefix sdkman-cli)/libexec
# [[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"

### Paths ###
export PATH="$PATH:$HOME/.local/bin"

### NIX ###
export PATH="/run/current-system/sw/bin:$PATH"

# NVM Replacement
eval "$(fnm env --use-on-cd --shell zsh)"
# eval "$(nodenv init - zsh)"

# Oracle
export ORACLE_HOME=$HOME/libs/instantclient_23_3
# export DYLD_LIBRARY_PATH=$HOME/libs/instantclient_23_3:$DYLD_LIBRARY_PATH
export DYLD_LIBRARY_PATH="${DYLD_LIBRARY_PATH}:$(nix eval --raw nixpkgs#libsixel)/lib"
export LD_LIBRARY_PATH=$HOME/libs/instantclient_23_3:$LD_LIBRARY_PATH
export TNS_ADMIN=$HOME/oracle/wallet
export PATH=$HOME/libs/instantclient_23_3:$PATH

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

# go
export GOPATH="$HOME/go"
export PATH="$PATH:${GOPATH}/bin"

# Tmuxifier
export PATH="$HOME/.tmuxifier/bin:$PATH"
export EDITOR=/run/current-system/sw/bin/nvim

# Add .NET Core SDK tools
export PATH="$PATH:$HOME/.dotnet/tools"

# Lua language server can use /opt/homebrew/bin/lua-language-server instead
export PATH="$PATH:/run/current-system/sw/bin/lua-language-server"

# DOCKER for PODMAN
export DOCKER_HOST=$(podman system connection ls --format "{{.URI}}" | grep podman-machine-default)

# OpenSSL
export OPENSSL_DIR=$(nix eval --raw nixpkgs#openssl.dev)
