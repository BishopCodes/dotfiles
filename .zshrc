# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Homebrew reference
eval "$(/opt/homebrew/bin/brew shellenv)"

# SDKMan
export SDKMAN_DIR=$(brew --prefix sdkman-cli)/libexec
[[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"

### Paths ###
export PATH="$PATH:$HOME/.local/bin"

# Node version manager
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm

# ninja for vscode
export PATH="$HOME/.console-ninja/.bin:$PATH"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

# go
export GOPATH="$HOME/go"
export GOROOT="$(brew --prefix golang)/libexec"
export PATH="$PATH:${GOPATH}/bin:${GOROOT}/bin"

# Tmuxifier
export PATH="$HOME/.tmuxifier/bin:$PATH"
export EDITOR=/opt/homebrew/bin/nvim

# Add .NET Core SDK tools
export PATH="$PATH:$HOME/.dotnet/tools"

# Lua langage server
export PATH="$PATH:/opt/homebrew/bin/lua-language-server"

# ZSH Autosuggest
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^w' autosuggest-execute
bindkey '^e' autosuggest-accept
bindkey '^u' autosuggest-toggle
bindkey '^L' vi-forward-word
bindkey '^k' up-line-or-search
bindkey '^j' down-line-or-search

### Aliases ###

# Aerospace
alias as=aerospace
alias asfzf="aerospace list-windows --all | fzf --bind 'enter:execute(bash -c \"aerospace focus --window-id {1}\")+abort'"

# config shortcuts
alias vscode="/Applications/Visual\ Studio\ Code.app/contents/Resources/app/bin/code"
alias zshconfig="nvim ~/.zshrc"
alias zshsource="source ~/.zshrc"
alias projects="cd ~/projects"
alias nvimconfig="nvim ~/.config/nvim"
alias sshhome="cd ~/.ssh"
alias gitconfig="nvim ~/.gitconfig"

# git shortcuts
# alias gits="git status"
# alias gita"git add ."
# alias gitc="git commit -m"
# alias gitca="git commit -a -m"
# alias gitlog="git log --graph --topo-order --pretty='%w(100,0,6)%C(yellow)%h%C(bold)%C(black)%d %C(cyan)%ar %C(green)%an%n%C(bold)%C(white)%s %N' --abbrev-commit"

# exa
alias la=tree
alias ls="exa"
alias ll="exa -alh"
alias tree="exa --tree"

# bat
if command -v bat > /dev/null; then
    alias cat="bat"
elif command -v batcat > /dev/null; then
    alias cat="batcat"
fi

# Dirs
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."

# HTTP requests with xh!
alias http="xh"

# Copy last command executed to the clipboard
alias copycmd="fc -ln -1 | awk '{$1=$1}1' | pbcopy"

alias esudo='sudo -E env "PATH=$PATH"'

alias vi=nvim
alias vim=nvim
alias docker=podman
alias docker-compose=podman-compose

alias server='python3 -m http.server 4445'
alias tunnel='ngrok http 4445'

alias seshc='sesh connect $(sesh list | fzf)'

fzjq() {
  local input jq_query
  if [ -t 0 ]; then
    # Read input from file if provided
    input=$(cat "$1")
  else
    # Read input from stdin
    input=$(cat)
  fi
  
  # Use fzf to get the jq query interactively
  jq_query=$(echo "Enter jq query:" | fzf --print-query --preview "echo \"$input\" | jq {q}" --preview-window=right:60%)
  
  # Run jq with the query on the input
  echo "$input" | jq "$jq_query"
}

### ZINIT ###
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Grab Zinit if we dont have it already
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Load Zinit
source "${ZINIT_HOME}/zinit.zsh"

# Powerlevel passing depth down for the git clone
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
# zsh-fzf-history-search
zinit ice lucid wait'0'
zinit light joshskidmore/zsh-fzf-history-search

# Snippets ohmyzh without the bloat
zinit snippet OMZP::aws
zinit snippet OMZP::command-not-found
zinit snippet OMZP::git

# Load completions
autoload -U compinit && compinit

# Replay cache completions
zinit cdreplay -q

### Styling ### 
## case-insensitive
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
# FZF
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Faster pasting
pasteinit() {
  OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
  zle -N self-insert url-quote-magic
}

pastefinish() {
  zle -N self-insert $OLD_SELF_INSERT
}
zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish

### Theme stuff ###
# source ~/.p10k.zsh
# ZSH_THEME="powerlevel10k/powerlevel10k"

### History ###
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

### Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

### Keybinds ###
bindkey -v
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# VI Mode!!!
# bindkey jj vi-cmd-mode

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

PATH=~/.console-ninja/.bin:$PATH
# Created by `pipx` on 2024-09-10 14:38:35
export PATH="$PATH:/Users/Dale.Bishop/.local/bin"
